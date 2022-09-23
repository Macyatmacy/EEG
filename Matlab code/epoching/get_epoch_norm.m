function [epochs_norm_paths] = get_epoch_norm(data_paths,epoched_paths,save_folder_name,norm_type)

for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    clear file_path;
    files = dir(epoched_paths{idx});
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            [EEG] = norm_epoch(file_path,norm_type);
            save_name = append(save_folder_name,'\',files(f).name(1:end-4),'_epoch_norm.mat');
            save(save_name,'EEG');
        end
    end
end

epochs_norm_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_folder_name);
    epochs_norm_paths{idx} = path;
end

end