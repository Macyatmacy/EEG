import logging
from choose_model import choose_model
from braindecode.torch_ext.util import np_to_var
import mne
import numpy as np
from braindecode.datautil.signalproc import exponential_running_standardize
from braindecode.datautil.splitters import split_into_train_valid_test
from braindecode.datautil.trial_segment import create_signal_target_from_raw_mne
from braindecode.mne_ext.signalproc import concatenate_raws_with_events, mne_apply
import sys
from braindecode.models.util import to_dense_prediction_model
import torch as th
from braindecode.datautil.iterators import CropsFromTrialsIterator
import importlib
from braindecode.experiments.stopcriteria import MaxEpochs, NoDecrease, Or, And
importlib.reload(logging)
log = logging.getLogger()
log.setLevel('INFO')
import argparse
import json
from os.path import join as pjoin
import torch.nn.functional as F
from braindecode.torch_ext.optimizers import AdamW
from braindecode.torch_ext.util import set_random_seeds
from braindecode.experiments.experiment import Experiment
from braindecode.experiments.monitors import RuntimeMonitor, LossMonitor, CroppedTrialMisclassMonitor, MisclassMonitor
from braindecode.experiments.stopcriteria import MaxEpochs
from collections import OrderedDict
########################################################################################################################
def gen_cnt(subjs,datapath):
    new_cnts = []
    not_cals = True
    for s in subjs:
        path = datapath +s+'\EEG.gdf'
        raw_edf = mne.io.read_raw_gdf(path, stim_channel="auto")
        raw_edf.info['ch_names']
        raw_edf.load_data()
        data = raw_edf.get_data()
        for i_chan in range(data.shape[0]):
            this_chan = data[i_chan]
            data[i_chan] = np.where(
            this_chan == np.min(this_chan), np.nan, this_chan)
            mask = np.isnan(data[i_chan])
            chan_mean = np.nanmean(data[i_chan])
            data[i_chan, mask] = chan_mean
        edf_events = mne.events_from_annotations(raw_edf)
        raw_edf = mne.io.RawArray(data, raw_edf.info, verbose="WARNING")
        raw_edf.info["edf_events"] = edf_events
        cnt = raw_edf
        events, name_to_code = cnt.info["edf_events"]
        trial_codes=range(1,17)
        trial_mask = [ev_code in trial_codes for ev_code in events[:, 2]]
        trial_events = events[trial_mask]
        cnt.info["events"] = trial_events
        if not_cals:
            _cals = cnt._cals
            not_cals = False
        else:
            cnt._cals = _cals
        new_cnts.append(cnt)
    return new_cnts
########################################################################################################################
parser = argparse.ArgumentParser(
    description='Subject-specific classification with KU Data')
parser.add_argument('-out_path', type=str, help='Path to the result folder')
parser.add_argument('-model_type', type=str,
                    help='Choose shallownet, deep4net or eegnet to train',default="shallow")
parser.add_argument('-gpu', type=int,
                    help='The gpu device index to use', default=0)
parser.add_argument('-data_path', type=str, help='Path to gdf data')
parser.add_argument('-seed', type=int,
                    help='The gpu device index to use', default=0)
parser.add_argument('-start', type=int,
                    help='Start of the subject index', default=1)
parser.add_argument(
    '-end', type=int, help='End of the subject index (not inclusive)', default=14)
########################################################################################################################
# ### 1 Setup logging to see outputs
logging.basicConfig(format='%(asctime)s %(levelname)s : %(message)s',
                     level=logging.DEBUG, stream=sys.stdout)
log = logging.getLogger()
########################################################################################################################
# parameters
load_sensor_names=None
cuda = True
input_time_length = 1280
in_chans = 14
## change these two lines to change classification task
n_classes = 8
name_to_start_codes = OrderedDict([('Chinese', [2,3,4,5,6,7,8,16]),
                                  ('English', [1,9,10,11,12,13,14,15])])
print(name_to_start_codes)
segment_ival_ms = [0,5000]
max_epochs = 200
max_increase_epochs = 50
########################################################################################################################
set_random_seeds(seed=20220910, cuda=cuda)
args = parser.parse_args()
seed = args.seed
datapath = args.data_path
outpath = args.out_path
model_type = args.model_type
start = args.start
end = args.end
assert(start < end)
subjs = range(start, end)
rng = np.random.RandomState(seed=seed)
########################################################################################################################
### Subject data folder names
train_subjs = ['Subj_1','Subj_2','Subj_3','Subj_4','Subj_5','Subj_6','Subj_7','Subj_8','Subj_9','Subj_10','Subj_11','Subj_12','Subj_13']
########################################################################################################################
#choose model
model,lr,weight_decay = choose_model(model_type,in_chans,n_classes,input_time_length)
########################################################################################################################
to_dense_prediction_model(model.network)
########################################################################################################################
#calculate n_preds_per_input
test_input = np_to_var(np.ones((2, 14, input_time_length, 1), dtype=np.float32))
if cuda:
    test_input = test_input.cuda()
out = model.network(test_input)
n_preds_per_input = out.cpu().data.numpy().shape[2]
print("{:d} predictions per input/trial".format(n_preds_per_input))
iterator = CropsFromTrialsIterator(batch_size=32,input_time_length=input_time_length,
                                  n_preds_per_input=n_preds_per_input)
optimizer = AdamW(model.parameters(), lr=lr, weight_decay=weight_decay)
loss_function = lambda preds, targets: F.nll_loss(th.mean(preds, dim=2).squeeze(), targets)
model_constraint = None
monitors = [LossMonitor(), MisclassMonitor(col_suffix='sample_misclass'),
            CroppedTrialMisclassMonitor(input_time_length), RuntimeMonitor(),]
stop_criterion = Or([MaxEpochs(max_epochs),
                         NoDecrease('valid_misclass', max_increase_epochs)])

for subj in subjs:
    subj_folder  = train_subjs[subj-1]
    print('sub',subj_folder)
    cnt = gen_cnt([subj_folder],datapath)
    cnt = concatenate_raws_with_events(cnt)
    cnt = mne_apply(lambda a: exponential_running_standardize(
        a.T, init_block_size=1280, factor_new=0.001, eps=1e-4).T,
                    cnt)
    train_set = create_signal_target_from_raw_mne(cnt, name_to_start_codes, segment_ival_ms)
    train_set, valid_set, test_set = split_into_train_valid_test(train_set, 5, 0, rng)
    suffix = 's' + str(subj)
    exp = Experiment(model.network, train_set, valid_set, test_set, iterator, loss_function, optimizer, model_constraint,
                     monitors, stop_criterion, remember_best_column='valid_misclass',
                     run_after_early_stop=True, batch_modifier=None, cuda=cuda)
    exp.run()
    output=dict()
    model.compile(loss = F.nll_loss, optimizer=optimizer, cropped=True)
    model.monitors = monitors
    model.iterator = iterator
    output = model.evaluate(test_set.X, test_set.y)
    exp.before_stop_df.to_csv(pjoin(outpath, 'epochs_' + suffix + '.csv'))
    with open(pjoin(outpath, 'test_subj_' + str(subj) + '.json'), 'w') as f:
            json.dump(output,f)

