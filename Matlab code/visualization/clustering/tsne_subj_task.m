function tsne_data_path = tsne_subj_task(topfolder, epoched_paths,save_folder_name)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
cd(topfolder)
[~, msg, ~]  = mkdir(save_folder_name);
if strcmp(msg,'Directory already exists.')
    rmdir(save_folder_name,'s')
    mkdir(save_folder_name);
end
tsne_data_matrix = [];
tsne_data_label = [];

for i = 1:length(epoched_paths)
    epoched_path = epoched_paths{i};
    files = dir(epoched_path);
    if i < 10
        subj_id = append('0',string(i));
    else
        subj_id = string(i);
    end

    for f = 1:length(files)
        if contains(files(f).name,'.mat')
            file_path = [files(f).folder,'\',files(f).name];
            load(file_path);
            if f == 3
                label = append("hear_chi_",subj_id);
            elseif f == 4
                label = append("hear_eng_",subj_id);
            elseif f == 5
                label = append("inner_chi_",subj_id);
            elseif f == 6
                label = append("inner_eng_",subj_id);
            elseif f == 7
                label = append("speak_chi_",subj_id);
            elseif f == 8
                label = append("speak_eng_",subj_id);
            end
            file_path = [files(f).folder,'\',files(f).name];
                %[all_trials_flatten, label,padding_ratio] = window_flatten(file_path,window_size);
            load(file_path);
            data = flt_tensor(EEG.data);
            if ~isempty(tsne_data_matrix)
                if length(tsne_data_matrix(1,:)) < length(data)
                    data = data(1:length(tsne_data_matrix(1,:)));
                elseif length(tsne_data_matrix(1,:)) > length(data)
                    tsne_data_matrix = tsne_data_matrix(:,1:length(data));
                end
            end
            tsne_data_matrix = [tsne_data_matrix;data];
            tsne_data_label = [tsne_data_label;label];
        end
    end
end

save_name = append(topfolder,'\',save_folder_name,'\',"tsne_data_label.mat");
save(save_name,'tsne_data_matrix',"tsne_data_label");
tsne_data_path = append(topfolder,'\',save_folder_name);
end
