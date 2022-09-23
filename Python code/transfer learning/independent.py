import logging
from os import makedirs
from shutil import copy2
from sklearn.model_selection import KFold
from choose_model import choose_model
from braindecode.torch_ext.util import np_to_var
import mne
import numpy as np
from braindecode.datautil.signalproc import exponential_running_standardize
from braindecode.datautil.trial_segment import create_signal_target_from_raw_mne
from braindecode.mne_ext.signalproc import concatenate_raws_with_events, mne_apply
import sys
from braindecode.models.util import to_dense_prediction_model
import torch as th
from braindecode.datautil.iterators import CropsFromTrialsIterator
import importlib
from braindecode.experiments.stopcriteria import NoDecrease, Or
import argparse
from os.path import join as pjoin
import torch
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
parser.add_argument('-start', type=int,
                    help='Start of the subject index', default=1)
parser.add_argument(
    '-end', type=int, help='End of the subject index (not inclusive)', default=14)
parser.add_argument('-data_path', type=str, help='Path to gdf data')
parser.add_argument('-fold', type=int,
                    help='k-fold index, starts with 0', required=True)
########################################################################################################################
# ### 1 Setup logging to see outputs
importlib.reload(logging)
log = logging.getLogger()
log.setLevel('INFO')
logging.basicConfig(format='%(asctime)s %(levelname)s : %(message)s',
                     level=logging.DEBUG, stream=sys.stdout)
log = logging.getLogger()
########################################################################################################################
# parameters
load_sensor_names=None
cuda = True
input_time_length = 1280
in_chans = 14
n_classes = 2
name_to_start_codes = OrderedDict([('Chinese', [2,3,4,5,6,7,8,16]),
                                  ('English', [1,9,10,11,12,13,14,15])])

segment_ival_ms = [0,5000]
max_epochs = 300
max_increase_epochs = 50
rng = np.random.RandomState(seed=1)
## positive correlation list
fold_index = [[0,3,4,6,9],[1,3,10,12],[2,3,4,5,8,9,11],[3,0,1,2,6,7,9,10,11,12],
[4,0,2,5,8,9,11],[5,2,4,6,7,8,9],[6,0,3,5,7,8,9,11],[7,3,5,6,9,11],[8,2,4,5,6,11],
[9,0,2,3,4,5,6,7,11],[10,1,3,11,12],[11,2,3,4,6,7,8,9,10,12],[12,1,3,10,11]]

full_list = list(range(0,13))
fold_index = []
for idx in range(0,13):
    append_list = [idx]
    for j in range(0,13):
        if j != idx:
            append_list.append(j)
    fold_index.append(append_list)
batch_size=128
########################################################################################################################
set_random_seeds(seed=20220910, cuda=cuda)
args = parser.parse_args()
outpath = args.out_path
model_type = args.model_type
start = args.start
end = args.end
datapath = args.data_path
fold = args.fold
print('fold',fold)
assert(start < end)
subjs = range(start, end)
fold_index = fold_index[fold]
if len(fold_index) < 6:
    kf = KFold(n_splits=len(fold_index)-1)
else:
    kf = KFold(n_splits=5)
########################################################################################################################
### Subject data folder name (the .gdf data)
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
iterator = CropsFromTrialsIterator(batch_size=batch_size,input_time_length=input_time_length,
                                  n_preds_per_input=n_preds_per_input)
optimizer = AdamW(model.parameters(), lr=lr, weight_decay=weight_decay)
loss_function = lambda preds, targets: F.nll_loss(th.mean(preds, dim=2).squeeze(), targets)
model_constraint = None
monitors = [LossMonitor(), MisclassMonitor(col_suffix='sample_misclass'),
            CroppedTrialMisclassMonitor(input_time_length), RuntimeMonitor(),]
stop_criterion = Or([MaxEpochs(max_epochs),
                         NoDecrease('valid_misclass', max_increase_epochs)])
cv_set = np.array(fold_index[1:])
cv_loss = []

for cv_index, (train_index, test_index) in enumerate(kf.split(cv_set)):
        train_subjs =[subj_names[cv_set[i]] for i in train_index]

        valid_subjs =[subj_names[cv_set[i]] for i in test_index]
        test_subj = subj_names[fold_index[0]]
        print('train_subjs',train_subjs)
        print('valid_subjs',valid_subjs)
        print('test_subjs',test_subj)
        cnt = gen_cnt(train_subjs,datapath)
        cnt = concatenate_raws_with_events(cnt)
        cnt = mne_apply(lambda a: exponential_running_standardize(
            a.T, init_block_size=1280, factor_new=0.001, eps=1e-4).T,
                        cnt)
        train_set = create_signal_target_from_raw_mne(cnt, name_to_start_codes, segment_ival_ms)

        cnt = gen_cnt(valid_subjs,datapath)
        cnt = concatenate_raws_with_events(cnt)
        cnt = mne_apply(lambda a: exponential_running_standardize(
            a.T, init_block_size=1280, factor_new=0.001, eps=1e-4).T,
                        cnt)
        valid_set = create_signal_target_from_raw_mne(cnt, name_to_start_codes, segment_ival_ms)


        cnt = gen_cnt([test_subj],datapath)
        cnt = concatenate_raws_with_events(cnt)
        cnt = mne_apply(lambda a: exponential_running_standardize(
            a.T, init_block_size=1280, factor_new=0.001, eps=1e-4).T,
                        cnt)
        test_set = create_signal_target_from_raw_mne(cnt, name_to_start_codes, segment_ival_ms)

        exp = Experiment(model.network, train_set, valid_set, test_set, iterator, loss_function, optimizer, model_constraint,
                         monitors, stop_criterion, remember_best_column='valid_misclass',
                         run_after_early_stop=True, batch_modifier=None, cuda=cuda)
        exp.run()
        rememberer = exp.rememberer

        base_model_param = {
            'epoch': rememberer.best_epoch,
            'model_state_dict': rememberer.model_state_dict,
            'optimizer_state_dict': rememberer.optimizer_state_dict,
            'loss': rememberer.lowest_val
        }
        torch.save(base_model_param, pjoin(
            outpath, 'model_f{}_cv{}.pt'.format(fold, cv_index)))
        exp.epochs_df.to_csv(
            pjoin(outpath, 'epochs_f{}_cv{}.csv'.format(fold, cv_index)))
        cv_loss.append(rememberer.lowest_val)

best_cv = np.argmin(cv_loss)
best_dir = pjoin(outpath, "best")
makedirs(best_dir, exist_ok=True)
with open(pjoin(best_dir, "fold_bestcv.txt"), 'a') as f:
    f.write("{}, {}\n".format(fold, best_cv))
copy2(pjoin(outpath, 'model_f{}_cv{}.pt'.format(fold, best_cv)),
          pjoin(best_dir, 'model_f{}.pt'.format(fold)))
copy2(pjoin(outpath, 'epochs_f{}_cv{}.csv'.format(fold, best_cv)),
          pjoin(best_dir, 'epochs_f{}.csv'.format(fold)))


