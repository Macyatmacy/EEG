function [data_paths_new] = get_epoched_feis(data_paths, save_folder_name,str,time_lock)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
for idx = 1%:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    load('EEG.mat');
    

        EEG = pop_loadset( 'EEG.set');
        [EEG, ~] = pop_epoch( EEG,str,time_lock, ...
        'epochinfo', 'yes');
        EEG_new.data = double(EEG.data);
        label_list = [];
        for i = 1:length(EEG.event)
            label_list = [label_list;string(EEG.event(i).type)];
        end
        EEG_new.label = label_list;
        EEG = EEG_new;
        save(append(save_folder_name,'\','EEG_epoch.mat'),'EEG');



end
data_paths_new = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_folder_name);
    data_paths_new{idx} = path;
end
end