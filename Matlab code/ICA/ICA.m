function [ICA_paths] = ICA_decompose(raw_paths,EEG_paths,save_folder_name)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
ICA_paths = cell(length(raw_paths),1);
for idx = 1:length(raw_paths)
    path = append(raw_paths{idx},'\',save_folder_name);
    ICA_paths{idx} = path;
end
for i = 1:length(EEG_paths)
    EEG_path = EEG_paths{i};
    %files = dir(EEG_path);
    cd(raw_paths{i})
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    [EEG] = ICA_decompose_single(EEG_path);
    save([ICA_paths{i},'\','EEG.mat'],'EEG')
end
end