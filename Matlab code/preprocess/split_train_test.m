function [train_data,test_data] = split_train_test(file_path,train_ratio)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here
load(file_path);
data = EEG.data;
label_list = EEG.label;
train_data.data = [];
train_data.label = [];
test_data.data = [];
test_data.label = [];
label_unique = unique(label_list);
for j = 1:length(label_unique)
    idx = find(label_list==label_unique(j));
    cutoff = round(length(idx)*train_ratio);
    idx_train = idx(1:cutoff);
    idx_test = idx(cutoff+1:end);
    train_data.data = cat(3,train_data.data,data(:,:,idx_train));
    train_data.label = [train_data.label;label_list(idx_train)];
    test_data.data = cat(3,test_data.data,data(:,:,idx_test));
    test_data.label = [test_data.label;label_list(idx_test)];
end
end