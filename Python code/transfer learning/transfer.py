import argparse
import json
import logging
import sys
from os.path import join as pjoin
import mne
import numpy as np
import torch
import torch.nn.functional as F
from choose_model import choose_model
from braindecode.torch_ext.optimizers import AdamW
from braindecode.torch_ext.util import set_random_seeds
from torchmetrics import F1Score
from braindecode.experiments.stopcriteria import MaxEpochs, NoDecrease
from braindecode.experiments.stopcriteria import Or
from braindecode.torch_ext.util import np_to_var
from braindecode.datautil.iterators import CropsFromTrialsIterator
from braindecode.experiments import monitors
from braindecode.experiments.experiment import Experiment
from braindecode.experiments.monitors import RuntimeMonitor, LossMonitor, CroppedTrialMisclassMonitor, MisclassMonitor
import torch as th
from braindecode.datautil.splitters import split_into_train_valid_test
from braindecode.datautil.trial_segment import create_signal_target_from_raw_mne
from braindecode.datautil.signalproc import exponential_running_standardize
from braindecode.mne_ext.signalproc import concatenate_raws_with_events, mne_apply
from collections import OrderedDict
########################################################################################################################
def reset_model(checkpoint,scheme,lr,weight_decay):
    model.network.load_state_dict(checkpoint['model_state_dict'])

    if scheme == 3:
        try:
            # Unfreeze the conv_time and conv_spat layers
            for param in model.network.parameters():
                param.requires_grad = False
            for param in model.network.conv_5.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_5.parameters():
                param.requires_grad = True
            for param in model.network.conv_6.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_6.parameters():
                param.requires_grad = True
        except:
            for param in model.network.parameters():
                param.requires_grad = False
            for param in model.network.conv_3.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_3.parameters():
                param.requires_grad = True
            for param in model.network.conv_4.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_4.parameters():
                param.requires_grad = True

    if scheme == 4:
            # Unfreeze the conv_time and conv_spat layers
            for param in model.network.parameters():
                param.requires_grad = False
            for param in model.network.conv_classifier.parameters():
                param.requires_grad = True

    if scheme == 5:
        try:
            # Unfreeze the conv_time and conv_spat layers
            for param in model.network.parameters():
                param.requires_grad = False
            for param in model.network.conv_classifier.parameters():
                param.requires_grad = True
            for param in model.network.conv_5.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_5.parameters():
                param.requires_grad = True
            for param in model.network.conv_6.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_6.parameters():
                param.requires_grad = True
        except:
            for param in model.network.parameters():
                param.requires_grad = False
            for param in model.network.conv_classifier.parameters():
                param.requires_grad = True
            for param in model.network.conv_3.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_3.parameters():
                param.requires_grad = True
            for param in model.network.conv_4.parameters():
                param.requires_grad = True
            for param in model.network.bnorm_4.parameters():
                param.requires_grad = True


    if scheme == 6:
            # Unfreeze the conv_time and conv_spat layers
            for param in model.network.parameters():
                param.requires_grad = False
            for param in model.network.conv_time.parameters():
                param.requires_grad = True
            for param in model.network.conv_spat.parameters():
                param.requires_grad = True
            for param in model.network.bnorm.parameters():
                param.requires_grad = True

    if scheme == 7:
            # Unfreeze all
            for param in model.network.parameters():
                param.requires_grad = True


    optimizer = AdamW(filter(lambda p: p.requires_grad, model.network.parameters()),
                      lr=lr, weight_decay=weight_decay)
    model.compile(loss=F.nll_loss, optimizer=optimizer, iterator_seed=seed, cropped=True)
########################################################################################################################
def gen_cnt(subjs,datapath):
    new_cnts = []
    not_cals = True
    for s in subjs:
        path = datapath + s + '\EEG.gdf'
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
    description='Subject-adaptative classification')
parser.add_argument('-out_path', type=str, help='Path to the result folder')
parser.add_argument('-data_path', type=str, help='Path to gdf data')
parser.add_argument('-model_path', type=str, help='Path to models')
parser.add_argument('-fold', type=int, help='fold subject')
parser.add_argument('-seed', type=int, help='random seed')
parser.add_argument('-model_type', type=str,
                    help='Choose shallownet, deep4net or eegnet to train',default="shallow")
parser.add_argument('-scheme', type=int, help='Adaptation scheme', default=4)
args = parser.parse_args()
datapath = args.data_path
outpath = args.out_path
modelpath = args.model_path
scheme = args.scheme
seed = args.seed
model_type = args.model_type
fold = args.fold
########################################################################################################################
# ### 1 Setup logging to see outputs
logging.basicConfig(format='%(asctime)s %(levelname)s : %(message)s',
                     level=logging.DEBUG, stream=sys.stdout)
log = logging.getLogger()
########################################################################################################################
### parameters
in_chans = 14
n_classes = 2
input_time_length = 1280
gpu = 0
BATCH_SIZE = 32
input_window_samples = 1280
checkpoint = torch.load(pjoin(modelpath, 'model_f' + str(fold) + '.pt'),
                                map_location='cuda:' + str(gpu))
cuda_true = True
max_epochs = 300
max_increase_epochs = 50
name_to_start_codes = OrderedDict([('Chinese', [2,3,4,5,6,7,8,16]),
                                  ('English', [1,9,10,11,12,13,14,15])])
segment_ival_ms = [0,5000]
fold_index = [[0,3,4,6,9],[1,3,10,12],[2,3,4,5,8,9,11],[3,0,1,2,6,7,9,10,11,12],
[4,0,2,5,8,9,11],[5,2,4,6,7,8,9],[6,0,3,5,7,8,9,11],[7,3,5,6,9,11],[8,2,4,5,6,11],
[9,0,2,3,4,5,6,7,11],[10,1,3,11,12],[11,2,3,4,6,7,8,9,10,12],[12,1,3,10,11]]
subj_names = ['David','Arindam','Nuria','Vlad1','Vlad2','Wik','cy2','xiaojun','hongzhi','chi','yezi','wanjun','123']
########################################################################################################################
### Generate data
fold_index = fold_index[fold]
suffix = 's' + str(fold_index[0])
test_subj = subj_names[fold_index[0]]
cnt = gen_cnt([test_subj],datapath)
cnt = concatenate_raws_with_events(cnt)
cnt = mne_apply(lambda a: exponential_running_standardize(
            a.T, init_block_size=1280, factor_new=0.001, eps=1e-4).T,
                        cnt)
test_set = create_signal_target_from_raw_mne(cnt, name_to_start_codes, segment_ival_ms)
rng = np.random.RandomState(seed=seed)
train_set, valid_set, test_set = split_into_train_valid_test(test_set, 5, 0, rng)
########################################################################################################################
### choose model
model,lr,weight_decay = choose_model(model_type,in_chans,n_classes,input_time_length)
lr = 1 * 0.001
weight_decay = 0
########################################################################################################################
### Reset model
reset_model(checkpoint,scheme,lr,weight_decay)
X_train = np.zeros(test_set.X[:2].shape).astype(np.float32)
Y_train = np.zeros(test_set.y[:2].shape).astype(np.int64)
model.fit(X_train, Y_train, 0, BATCH_SIZE,input_time_length=input_window_samples)
########################################################################################################################
### calculate n_preds_per_input
test_input = np_to_var(np.ones((2, 14, input_time_length, 1), dtype=np.float32))
if cuda_true:
        test_input = test_input.cuda()
out = model.network(test_input)
n_preds_per_input = out.cpu().data.numpy().shape[2]
########################################################################################################################
### Set up experiment
iterator = CropsFromTrialsIterator(batch_size=64, input_time_length=input_time_length,
                                       n_preds_per_input=n_preds_per_input)
optimizer = AdamW(model.parameters(), lr=lr, weight_decay=weight_decay)
loss_function = lambda preds, targets: F.nll_loss(th.mean(preds, dim=2).squeeze(), targets)
model_constraint = None
monitors = [LossMonitor(), MisclassMonitor(col_suffix='sample_misclass'),
                CroppedTrialMisclassMonitor(input_time_length), RuntimeMonitor(), ]
stop_criterion = Or([MaxEpochs(max_epochs),
                         NoDecrease('valid_misclass', max_increase_epochs)])
exp = Experiment(model.network, train_set, valid_set, test_set, iterator, loss_function, optimizer,
                     model_constraint,
                     monitors, stop_criterion, remember_best_column='valid_misclass',
                     run_after_early_stop=True, batch_modifier=None, cuda=True)
exp.run()
########################################################################################################################
### write outputs
output = model.evaluate(test_set.X, test_set.y)
exp.before_stop_df.to_csv(pjoin(outpath, 'epochs_' + suffix + '.csv'))
with open(pjoin(outpath, 'test_subj_' + str(fold_index[0]) + '.json'), 'w') as f:
            json.dump(output,f)

