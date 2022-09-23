function get_gdf(data_paths, hi_pass,lo_pass)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    %{
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    %load('EEG.mat');
    %}
    
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
        cd('e:\document\MATLAB\GDF');
        band_folder = append(string(hi_pass),'_',string(lo_pass));
        mkdir(band_folder);
        cd(append('e:\document\MATLAB\GDF\',band_folder));
        sub_folder_name = append('Subj_',string(idx));
        mkdir(save_folder_name);
        save_name = append('e:\document\MATLAB\GDF\',band_folder,'\',sub_folder_name,'\EEG.gdf');
        pop_writeeeg(EEG, save_name, 'TYPE','GDF');
        eeglab redraw;
        %save(append(save_folder_name,'\','EEG_epoch_',type{t},'_chi.mat'),'EEG');
    end
end

end