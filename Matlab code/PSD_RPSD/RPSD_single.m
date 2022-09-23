function [EEG] = RPSD_single(file_path)
%UNTITLED18 Summary of this function goes here
%   Detailed explanation goes here
load(file_path);
data = EEG.data;
%ch_labels = {'AF3','F7','F3','FC5','T7','P7','O1','O2','P8','T8','FC6','F4','F8','AF4'};
ch_labels= {'dummy'};
feature_set={'spectral_relative_power'};
feat_tensor = [];
for i = 1:length(data(1,1,:))
    feat_matrix = [];
    for c= 1:14
        chan_signal.eeg_data = data(c,:,i);
        chan_signal.Fs = 256;
        chan_signal.ch_labels = ch_labels ;
	    feat_st=generate_all_features(chan_signal,[],feature_set);
        feat = feat_st.spectral_relative_power;
        feat_matrix = [feat_matrix;feat];
    end
    feat_tensor = cat(3,feat_tensor,feat_matrix);
end
EEG.rpsd = feat_tensor;
end