function [psd_nl_nt_paths] = PSD_nl_nt(topfolder,data_paths, psd_paths,save_folder_name)
cd(topfolder);
[~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
psd_en_ct = [];
psd_en_et = [];
for idx = 1:6
    file_path = data_paths{idx};
    files = dir(psd_paths{idx});
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            if mod((f-2),2)==0
                psd_en_et = cat(3,psd_en_et,mean_psd_et);
            else
                psd_en_ct = cat(3,psd_en_ct,mean_psd_ct);
            end
        end
    end
end
save_name= append(topfolder,'\',save_folder_name,'\','psd_en_ct.mat');
            save(save_name,'psd_en_ct');
            save_name= append(topfolder,'\',save_folder_name,'\','psd_en_et.mat');
            save(save_name,'psd_en_et');



psd_cn_ct = [];
psd_cn_et = [];
for idx = 7:13
    file_path = data_paths{idx};
    files = dir(psd_paths{idx});
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            if mod((f-2),2)==0
                psd_cn_et = cat(3,psd_cn_et,mean_psd_et);
            else
                psd_cn_ct = cat(3,psd_cn_ct,mean_psd_ct);
            end
        end
    end
end
            save_name= append(topfolder,'\',save_folder_name,'\','psd_cn_ct.mat');
            save(save_name,'psd_cn_ct');
            save_name= append(topfolder,'\',save_folder_name,'\','psd_cn_et.mat');
            save(save_name,'psd_cn_et');





psd_nl_nt_paths = append(topfolder,'\',save_folder_name);



end