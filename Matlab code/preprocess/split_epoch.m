function [EEG] = split_epoch(file_path)
%UNTITLED20 Summary of this function goes here
%   Detailed explanation goes here
load(file_path);
data = EEG.data;
label_list = EEG.label;
epoch_length = round(length(data(1,:,1))/5);
cut_idx = (1:5) .* epoch_length;
%output_data = zeros(14,epoch_length,5*length(data(:,:,1)));
stack_data = [];
stack_label = [];
for i = 1:length(data(1,1,:))
    data_trial = data(:,:,i);
    for j  = 1:length(cut_idx)
        stack_data = cat(3,stack_data,data_trial(:,(cut_idx(j)-255):cut_idx(j)));
        stack_label = [stack_label,label_list(i)];
    end
end
EEG.data = stack_data;
EEG.label = stack_label;
end