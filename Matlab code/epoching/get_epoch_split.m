function [train_epochs_paths,test_epochs_paths] = get_epoch_split(data_paths,epoched_paths,save_train_folder_name,save_test_folder_name,train_ratio)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    clear file_path;
    %mkdir(save_folder_name);
    files = dir(epoched_paths{idx});
    [~, msg, ~]  = mkdir(save_train_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_train_folder_name,'s')
        mkdir(save_train_folder_name);
    end
    [~, msg, ~]  = mkdir(save_test_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_test_folder_name,'s')
        mkdir(save_test_folder_name);
    end
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            [train_data,test_data] = split_train_test(file_path,train_ratio);
            save([save_train_folder_name,'\',files(f).name(1:end-4),'_train.mat'],'train_data');
            save([save_test_folder_name,'\',files(f).name(1:end-4),'_test.mat'],'test_data');
        end
    end
end

train_epochs_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_train_folder_name);
    train_epochs_paths{idx} = path;
end
test_epochs_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_test_folder_name);
    test_epochs_paths{idx} = path;
end
end