function [data_paths_new] = get_loreta(topfolder,data_paths,save_folder_name,read_file,type,sub_range)
cd(topfolder);
[~, msg, ~]  = mkdir(save_folder_name);
if strcmp(msg,'Directory already exists.')
    rmdir(save_folder_name,'s')
    mkdir(save_folder_name);
end
save_path = append(topfolder,'\',save_folder_name);
for idx = sub_range
    file_path = data_paths{idx};
    cd(append(file_path,'\','epoch'));
    load(read_file);
    
    cd(save_path)
    sub_folder_name = append('Subj_',string(idx));
    [~, msg, ~]  = mkdir(sub_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(sub_folder_name,'s')
        mkdir(sub_folder_name);
    end
    cd(sub_folder_name)
    data = EEG.data;
    for i = 1:length(data(1,1,:))
        slide = data(:,:,i)';
        savename = append(type,'subj_08_',string(i),'.asc');
        save(savename,'slide','-ascii');
    end
data_paths_new = save_path;
end