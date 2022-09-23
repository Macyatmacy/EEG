function [psd_paths,rpsd_paths] = PSD_RPSD(data_paths, epoch_ica_longer_paths,baseline_windows,rpsd_folder_name,psd_folder_name)
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    clear file_path;
    files = dir(epoch_ica_longer_paths{idx});
    [~, msg, ~]  = mkdir(rpsd_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(rpsd_folder_name,'s')
        mkdir(rpsd_folder_name);
    end
    [~, msg, ~]  = mkdir(psd_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(psd_folder_name,'s')
        mkdir(psd_folder_name);
    end
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            [chan_psd,chan_rpsd] = chan_rpsd_rm_base(EEG,baseline_windows);
            save_name1= append(rpsd_folder_name,'\',files(f).name(1:end-4),'_RPSD.mat');
            save_name2= append(psd_folder_name,'\',files(f).name(1:end-4),'_PSD.mat');
            save(save_name1,'chan_rpsd');
            save(save_name2,'chan_psd');
        end
    end
end

rpsd_paths = cell(length(data_paths),1);
psd_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path1 = append(data_paths{idx},'\',rpsd_folder_name);
    rpsd_paths{idx} = path1;
    path2 = append(data_paths{idx},'\',psd_folder_name);
    psd_paths{idx} = path2;
end

end