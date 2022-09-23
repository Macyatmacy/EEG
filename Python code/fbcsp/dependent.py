import importlib
import logging
import json
import random
from copy import deepcopy
from os.path import join as pjoin
from fbcsp.experiment import CSPExperiment, TrainTestCSPExperiment
import numpy as np
import argparse
import mne
from braindecode.datautil.signalproc import exponential_running_standardize
from braindecode.mne_ext.signalproc import concatenate_raws_with_events, mne_apply

parser = argparse.ArgumentParser(
    description='FBCSP.')
parser.add_argument('-type', type=str, help='Narrow or wilder band range data')
parser.add_argument('-data_path', type=str, help='Path to gdf data')
parser.add_argument('-out_path', type=str, help='Subj folder name')
parser.add_argument('-seed', type=int, help='Subj folder name')


args = parser.parse_args()
model_type = args.type
seed = args.seed
datapath = args.data_path
outpath = args.out_path
importlib.reload(logging)
log = logging.getLogger()
log.setLevel('DEBUG')
import sys
logging.basicConfig(format='%(asctime)s %(levelname)s : %(message)s',
                     level=logging.DEBUG, stream=sys.stdout)

import os
from collections import OrderedDict
os.sys.path.append('D:\PycharmProjects\eeg_adapt_3\\fbcsp')
os.sys.path.append('D:\PycharmProjects\eeg_adapt_3\\braindecode')



import matplotlib

matplotlib.rcParams['figure.figsize'] = (12.0, 1.0)
matplotlib.rcParams['font.size'] = 7
epoch_ival_ms = [0,5000]
train_subjs = ['Subj_1','Subj_2','Subj_3','Subj_4','Subj_5','Subj_6','Subj_7','Subj_8','Subj_9','Subj_10','Subj_11','Subj_12','Subj_13']
name_to_start_codes = OrderedDict([('Chinese', [2,3,4,5,6,7,8,16]),
                                  ('English', [1,9,10,11,12,13,14,15])])
eng_array = np.array([2,3,4,5,6,7,8,16])
chi_array = np.array([1,9,10,11,12,13,14,15])
rng = np.random.RandomState(seed=seed)


log = logging.getLogger()
log.setLevel('DEBUG')

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

for subj in range(1,14):
    print(subj)
    print([train_subjs[subj-1]])
    cnt = gen_cnt([train_subjs[subj-1]],datapath)
    cnt = concatenate_raws_with_events(cnt)
    cnt = mne_apply(lambda a: exponential_running_standardize(
            a.T, init_block_size=1280, factor_new=0.001, eps=1e-4).T,
                        cnt)
    idx_chi = np.in1d(cnt.info['events'][:,2], chi_array).nonzero()[0].tolist()
    random.shuffle(idx_chi)
    idx_eng = np.in1d(cnt.info['events'][:,2], eng_array).nonzero()[0].tolist()
    random.shuffle(idx_eng)
    n_train_chi = round(len(idx_chi)*0.8)
    n_test_chi = len(idx_chi) - n_train_chi
    n_train_eng = round(len(idx_eng)*0.8)
    n_test_eng = len(idx_eng) - n_train_eng
    train_chi = cnt.info['events'][idx_chi[:n_train_chi],:]
    train_eng = cnt.info['events'][idx_eng[:n_train_eng],:]
    train_eve = np.concatenate((train_chi ,train_eng),axis=0)
    np.sort(train_eve, axis=0, kind=None, order=None)
    test_chi = cnt.info['events'][idx_chi[n_train_chi:],:]
    test_eng = cnt.info['events'][idx_eng[n_train_chi:],:]
    test_eve = np.concatenate((test_chi ,test_eng),axis=0)
    np.sort(test_eve, axis=0, kind=None, order=None)
    train_cnt = deepcopy(cnt)
    train_cnt.info['events']= train_eve
    test_cnt = deepcopy(cnt)
    test_cnt.info['events']= test_eve
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
                                     min_freq=1,
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
    output = dict()
    output['test_accuracy'] = np.mean(exp.multi_class.test_accuracy)
    with open(pjoin(outpath, 'test_subj_' + str(subj) + '.json'), 'w') as f:
        json.dump(output, f)
