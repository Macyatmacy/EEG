function [EEG_new] = norm_epoch(file_path,norm_type)
%UNTITLED17 Summary of this function goes here
%   Detailed explanation goes here
load(file_path);
if norm_type == "Robust"
    EEG_new.data  = RobustScaler(EEG.data);
    EEG_new.label = EEG.label;
end
