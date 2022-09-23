function [RPSD_mean_paths] = RPSD_mean(data_paths, RPSD_paths, save_folder_name)
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    clear file_path;
    files = dir(RPSD_paths{idx});
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            EEG.rpsd_trial_mean = mean(EEG.rpsd,3);
            EEG.rpsd_trial_chan_mean = mean(mean(EEG.rpsd,3));
            save_name = append(save_folder_name,'\',files(f).name(1:end-4),'_mean.mat');
            save(save_name,'EEG');
        end
    end
end

RPSD_mean_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_folder_name);
    RPSD_mean_paths{idx} = path;
end

end