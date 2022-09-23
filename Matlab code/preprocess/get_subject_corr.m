function [subj_corr_paths] = get_subject_corr(data_paths,epoched_paths,save_folder_name)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

for idx = 1:length(data_paths)
    cd(data_paths{idx})
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    corr_matrix = zeros(6,13);
    files1 = dir(epoched_paths{idx});
    for f = 1:length(files1)
        if contains(files1(f).name,'.mat')
            file_path = [files1(f).folder,'\',files1(f).name];
            load(file_path);
            data1 = flt_tensor(EEG.data);
            for idx_idx = 1:length(epoched_paths)
                if idx_idx ~= idx
                    cd(epoched_paths{idx_idx});
                    files2 = dir(epoched_paths{idx_idx});
                    for ff = 1:length(files2)
                        if contains(files2(f).name,'.mat')
                            file_path = [files2(f).folder,'\',files2(f).name];
                            load(file_path);
                            data2 = flt_tensor(EEG.data);
                            min_len = min(length(data1),length(data2));
                            corr = corrcoef(data1(1:min_len),data2(1:min_len));
                            corr_matrix(f-2,idx_idx) = corr(1,2);
                        end
                    end
                end
            end
        end
    end
    save_name = append(data_paths{idx},'\',save_folder_name,'\','corr.mat');
    save(save_name,'corr_matrix');
end
subj_corr_paths = cell(length(data_paths),1);
for idx = 1:length(data_paths)
    path = append(data_paths{idx},'\',save_folder_name);
    subj_corr_paths{idx} = path;
end
end