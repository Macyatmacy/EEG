function [data_paths_new] = get_loreta_erp(topfolder,data_paths,save_folder_name,read_file,type,sub_range)
cd(topfolder);
[~, msg, ~]  = mkdir(save_folder_name);
if strcmp(msg,'Directory already exists.')
    rmdir(save_folder_name,'s')
    mkdir(save_folder_name);
end
save_path = append(topfolder,'\',save_folder_name);
for idx = sub_range
    idx
    file_path = data_paths{idx};
    cd(append(file_path,'\','epoch'));
    load(read_file);
    
    cd(save_path)
    data = EEG.data;
    erp = mean(data,3);
    savename = append(type,'subj_',string(idx),'.asc');
    save(savename,'erp','-ascii');
end
data_paths_new = save_path;
end