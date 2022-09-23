function [EEG_paths] = eeglab_process_group(raw_paths,save_folder_name,hi_pass,lo_pass,channel_location_path)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(raw_paths)
    raw_path = raw_paths{i};
    %files = dir(raw_path);
    cd(raw_paths{i})
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    eeglab_process_single_feis(raw_path,channel_location_path,hi_pass,lo_pass);
end

EEG_paths = cell(length(raw_paths),1);
for idx = 1:length(raw_paths)
    path = append(raw_paths{idx},'\',save_folder_name);
    EEG_paths{idx} = path;
end
end