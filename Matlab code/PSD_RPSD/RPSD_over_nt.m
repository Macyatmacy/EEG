function [rpsd_nt_paths] = RPSD_over_nt(data_paths, tranformed_rpsd_paths,save_folder_name)
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    clear file_path;
    files = dir(tranformed_rpsd_paths{idx});
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    rpsd_ct = [];
    rpsd_et = [];
    for f = 5:6
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            if mod((f-2),2)==0
                rpsd_et = cat(3,rpsd_et,chan_rpsd);
            else
                rpsd_ct = cat(3,rpsd_ct,chan_rpsd);
            end
        end
    end
     mean_rpsd_et = mean(rpsd_et,3);
            mean_rpsd_ct = mean(rpsd_ct,3);
            save_name= append(data_paths{idx},'\',save_folder_name,'\','mean_rpsd_et.mat');
            save(save_name,'mean_rpsd_et');
            save_name= append(data_paths{idx},'\',save_folder_name,'\','mean_rpsd_ct.mat');
            save(save_name,'mean_rpsd_ct');
end

rpsd_nt_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path1 = append(data_paths{idx},'\',save_folder_name);
    rpsd_nt_paths{idx} = path1;
end

end