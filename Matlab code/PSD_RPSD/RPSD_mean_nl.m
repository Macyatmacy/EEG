function [RPSD_mean_nl_paths] = RPSD_mean_nl(topfolder,data_paths, RPSD_mean_paths, save_folder_name)
cd(topfolder);
    [~, msg, ~]  = mkdir(save_folder_name(1));
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name(1),'s')
        mkdir(save_folder_name(1));
    end
[~, msg, ~]  = mkdir(save_folder_name(2));
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name(2),'s')
        mkdir(save_folder_name(2));
    end
rpsd_trial_mean_tensor = [];
rpsd_trial_chan_mean_tensor = [];
for group = 1:2
    if group == 1
        range = 1:6;
        name = '_en';
    else
        range = 7:13;
        name = '_cn';
    end
    for idx = range
        file_path = data_paths{idx};
        cd(file_path);
        files = dir(RPSD_mean_paths{idx});
        for f = 1:length(files)
            if contains(files(f).name,'.mat')
                file_path = [files(f).folder,'\',files(f).name];
                load(file_path);
    
                %rpsd_trial_mean = EEG.rpsd_trial_mean;
                try
                    trial_mean = chan_rpsd;
                    trial_chan_mean = mean(chan_rpsd);
                catch exception
                    trial_mean = chan_psd;
                    trial_chan_mean = mean(chan_psd);
                end
                rpsd_trial_mean_tensor = cat(3,rpsd_trial_mean_tensor,trial_mean);
                rpsd_trial_chan_mean_tensor = cat(3,rpsd_trial_chan_mean_tensor,trial_chan_mean);
                EEG.rpsd_trial_nl_mean = mean(rpsd_trial_mean_tensor,3);
    EEG.rpsd_trial_chan_nl_mean = mean(rpsd_trial_chan_mean_tensor,3);
    save_name = append(topfolder,'\',save_folder_name(group),'\',files(f).name(1:end-4),name,'.mat');
    save(save_name,'EEG');
            end
        end
    end
end
RPSD_mean_nl_paths = cell(2,1);
for idx = 1:2
    path = append(topfolder,'\',save_folder_name(idx));
    RPSD_mean_nl_paths{idx} = path;
end

end