function [trans_rpsd_paths] = PSD_2_RPSD(data_paths, psd_paths,save_folder_name)
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    clear file_path;
    files = dir(psd_paths{idx});
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            chan_psd = abs(chan_psd);
            %min_psd = min(chan_psd(:));
            %chan_psd = chan_psd-min_psd;
            chan_rpsd = [];
            sum_chan_psd = sum(chan_psd,2);
            for i=1:14
                chan_rpsd(i,:) = chan_psd(i,:)./sum_chan_psd(i);
            end
            save_name= append(data_paths{idx},'\',save_folder_name,'\',files(f).name(1:end-4),'_2_RPSD.mat');
            save(save_name,'chan_rpsd');
        end
    end
end

trans_rpsd_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path1 = append(data_paths{idx},'\',save_folder_name);
    trans_rpsd_paths{idx} = path1;


end

end