function [RPSD_paths] = RPSD(data_paths, epoched_paths, save_folder_name)
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
            [EEG] = RPSD_single(file_path);
            save_name = append(save_folder_name,'\',files(f).name(1:end-4),'_RPSD.mat');
            save(save_name,'EEG');
        end
    end
end

RPSD_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_folder_name);
    RPSD_paths{idx} = path;
end

end