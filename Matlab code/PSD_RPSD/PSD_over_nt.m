function [psd_nt_paths] = PSD_over_nt(data_paths, tranformed_psd_paths,save_folder_name)
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    clear file_path;
    files = dir(tranformed_psd_paths{idx});
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    psd_ct = [];
    psd_et = [];
    for f = 5:6
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            if mod((f-2),2)==0
                psd_et = cat(3,psd_et,chan_psd);
            else
                psd_ct = cat(3,psd_ct,chan_psd);
            end
        end
    end
     mean_psd_et = mean(psd_et,3);
            mean_psd_ct = mean(psd_ct,3);
            save_name= append(data_paths{idx},'\',save_folder_name,'\','mean_psd_et.mat');
            save(save_name,'mean_psd_et');
            save_name= append(data_paths{idx},'\',save_folder_name,'\','mean_psd_ct.mat');
            save(save_name,'mean_psd_ct');
end

psd_nt_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path1 = append(data_paths{idx},'\',save_folder_name);
    psd_nt_paths{idx} = path1;
end

end