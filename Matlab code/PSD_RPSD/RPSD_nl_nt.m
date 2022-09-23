function [rpsd_nl_nt_paths] = RPSD_nl_nt(topfolder,data_paths, tranformed_rpsd_paths,save_folder_name)
cd(topfolder);
[~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
rpsd_en_ct = [];
rpsd_en_et = [];
for idx = 1:6
    file_path = data_paths{idx};
    files = dir(tranformed_rpsd_paths{idx});
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            if mod((f-2),2)==0
                rpsd_en_et = cat(3,rpsd_en_et,mean_rpsd_et);
            else
                rpsd_en_ct = cat(3,rpsd_en_ct,mean_rpsd_ct);
            end
        end
    end
end
save_name= append(topfolder,'\',save_folder_name,'\','rpsd_en_ct.mat');
            save(save_name,'rpsd_en_ct');
            save_name= append(topfolder,'\',save_folder_name,'\','rpsd_en_et.mat');
            save(save_name,'rpsd_en_et');



rpsd_cn_ct = [];
rpsd_cn_et = [];
for idx = 7:13
    file_path = data_paths{idx};
    files = dir(tranformed_rpsd_paths{idx});
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            if mod((f-2),2)==0
                rpsd_cn_et = cat(3,rpsd_cn_et,mean_rpsd_et);
            else
                rpsd_cn_ct = cat(3,rpsd_cn_ct,mean_rpsd_ct);
            end
        end
    end
end
            save_name= append(topfolder,'\',save_folder_name,'\','rpsd_cn_ct.mat');
            save(save_name,'rpsd_cn_ct');
            save_name= append(topfolder,'\',save_folder_name,'\','rpsd_cn_et.mat');
            save(save_name,'rpsd_cn_et');





rpsd_nl_nt_paths = append(topfolder,'\',save_folder_name);



end