function [output_paths] = train_classifier(data_paths,feature_train_paths,feature_test_paths,save_folder_name,fast,label_order,N)
%UNTITLED11 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(data_paths)
    train_files_path = feature_train_paths{i};
    train_files = dir(train_files_path);
    test_files_path = feature_test_paths{i};
    test_files = dir(test_files_path);
    cd(data_paths{i})
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    for f = 1:length(train_files)
        if contains(train_files(f).name,'.mat')
            train_file_path = [train_files(f).folder,'\',train_files(f).name];
            test_file_path = [test_files(f).folder,'\',test_files(f).name];
            [output,yfit1,yfit2] = optimized_classifier(train_file_path,test_file_path,fast,label_order,N);
            save_name = append(save_folder_name,'\',train_files(f).name(1:end-4),'_SVM.mat');
            save(save_name,'output');
        end
    end
end
output_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_folder_name);
    output_paths{idx} = path;
end
end