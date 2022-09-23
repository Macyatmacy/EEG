function [combined_svm_output_folder] = combined_output(topfolder,svm_output_paths,save_folder_name)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
acc_list = [];
cd(topfolder)
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
for i = 1:length(svm_output_paths)
    epoched_path = svm_output_paths{i};
    files = dir(epoched_path);
    acc_sub_list = [];
    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            %[all_trials_flatten, label,padding_ratio] = window_flatten(file_path,window_size);
            load(file_path);
            acc_sub_list = [acc_sub_list,output];
        end
    end
    acc_list = [acc_list;acc_sub_list];
end
save(append(save_folder_name,'\','_comb_output.mat'),'acc_list');
combined_svm_output_folder = save_folder_name;
end