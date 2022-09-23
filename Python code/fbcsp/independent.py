import importlib
from collections import OrderedDict
import argparse
import sys
import os
import matplotlib
from fbcsp.gen_cnt import gen_cnt
from braindecode.mne_ext.signalproc import concatenate_raws_with_events, mne_apply
import numpy as np
from fbcsp.experiment import CSPExperiment, TrainTestCSPExperiment
import logging


parser = argparse.ArgumentParser(
    description='FBCSP.')
parser.add_argument('type', type=str, help='Narrow or wilder band range data')
parser.add_argument('fold', type=int, help='Subj to fold')

args = parser.parse_args()
model_type = args.type
fold = args.fold

importlib.reload(logging) # see https://stackoverflow.com/a/21475297/1469195
log = logging.getLogger()
log.setLevel('DEBUG')
logging.basicConfig(format='%(asctime)s %(levelname)s : %(message)s',
                     level=logging.DEBUG, stream=sys.stdout)

os.sys.path.append('D:\PycharmProjects\eeg_adapt_3\\fbcsp')
os.sys.path.append('D:\PycharmProjects\eeg_adapt_3\\braindecode')

matplotlib.rcParams['figure.figsize'] = (12.0, 1.0)
matplotlib.rcParams['font.size'] = 7

log = logging.getLogger()
log.setLevel('DEBUG')

subjs = [6, 12, 8, 1, 4, 0, 11, 9, 3, 5, 10, 7, 2]
train_subjs = ['Subj_1','Subj_2','Subj_3','Subj_4','Subj_5','Subj_6','Subj_7','Subj_8','Subj_9','Subj_10','Subj_11','Subj_12','Subj_13']

test_subj = subj_fold[subjs[fold]]
test_cnt = gen_cnt([test_subj])
print('fold: ',test_subj)
new_list = subj_fold.copy()
new_list.remove(test_subj)
train_subjs = new_list
print('trained subjds: ',train_subjs)
name_to_start_codes = OrderedDict([('Chinese', [2,3,4,5,6,7,8,16]),
                                  ('English', [1,9,10,11,12,13,14,15])])

train_cnt = gen_cnt(train_subjs)
epoch_ival_ms = [1,5000]
train_cnt = concatenate_raws_with_events(train_cnt)
test_cnt = concatenate_raws_with_events(test_cnt)
test_cnt._cals = train_cnt._cals

if model_type=='wide':
    exp = TrainTestCSPExperiment(train_cnt,test_cnt,
                        name_to_start_codes,
                        epoch_ival_ms,
                        min_freq = 0.5,
                        max_freq=93.500000+15, last_low_freq=42.500000+6,
                        low_width=6,
                        high_width=30,
                        low_overlap=3,
                        high_overlap=15,
                        filt_order=4,  #SHOULD NOT BE HIGHER THAN 4
                        n_folds=None,
                        n_top_bottom_csp_filters=10,
                        n_selected_filterbands=None,
                        n_selected_features=30,
                        forward_steps=2,
                        backward_steps=1,
                        shuffle=True,
                        stop_when_no_improvement=False)

elif model_type=='narrow':
    exp = TrainTestCSPExperiment(train_cnt, test_cnt,
                                 name_to_start_codes,
                                 epoch_ival_ms,
                                 min_freq=2,
                                 max_freq=41, last_low_freq=13,
                                 low_width=6,
                                 high_width=8,
                                 low_overlap=3,
                                 high_overlap=4,
                                 filt_order=4,  # SHOULD NOT BE HIGHER THAN 4
                                 n_folds=None,
                                 n_top_bottom_csp_filters=10,
                                 n_selected_filterbands=None,
                                 n_selected_features=30,
                                 forward_steps=2,
                                 backward_steps=1,
                                 shuffle=True,
                                 stop_when_no_improvement=False)

exp.run()

print(np.mean(exp.multi_class.test_accuracy))