function [data_paths] = get_EEG_path(topLevelFolder,fil_folder,ica,ica_removed_folder)
%topLevelFolder = 'G:\EEG-prepocessing\subject_data';
files = dir(topLevelFolder);
sub_folders = {};
for i = 1:length(files)
    if contains(files(i).name,'Sub')
        sub_folders = [sub_folders;append(files(i).folder,'\',files(i).name)];
    end
end


data_paths = cell(length(sub_folders),1);
for idx = 1:length(sub_folders)
    if ica
        path = append(sub_folders{idx},'\',ica_removed_folder);
    else
        path = append(sub_folders{idx},'\',fil_folder);
    end
    data_paths{idx} = path;
end


