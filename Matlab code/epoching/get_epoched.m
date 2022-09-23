function [data_paths_new] = get_epoched_combined(data_paths, save_folder_name, str_chi, str_eng,time_lock)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
type = {'audio','imagine','speak'};
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    load('EEG.mat');
    
    for t = 1:length(type)
        for i = 1:length(str_chi)
            type_chi(1,i) = append(str_chi(i),'_',type(t));
        end
        for i = 1:length(str_eng)
            type_eng(1,i) = append(str_eng(i),'_',type(t));
        end
        EEG = pop_loadset( 'EEG.set');
        [EEG, ~] = pop_epoch( EEG,type_eng ,time_lock, ...
        'epochinfo', 'yes');
        EEG.data = double(EEG.data);
        label_list = [];
        for i = 1:length(EEG.event)
            label_list = [label_list;string(EEG.event(i).type)];
        end
        EEG.label = label_list;
        save(append(save_folder_name,'\','EEG_epoch_',type{t},'_eng.mat'),'EEG');

        EEG = pop_loadset( 'EEG.set');
        [EEG, ~] = pop_epoch( EEG,type_chi ,time_lock, ...
        'epochinfo', 'yes');
        EEG.data = double(EEG.data);
        label_list = [];
        for i = 1:length(EEG.event)
            label_list = [label_list;string(EEG.event(i).type)];
        end
        EEG.label = label_list;
        save(append(save_folder_name,'\','EEG_epoch_',type{t},'_chi.mat'),'EEG');
    end
end
data_paths_new = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_folder_name);
    data_paths_new{idx} = path;
end
end