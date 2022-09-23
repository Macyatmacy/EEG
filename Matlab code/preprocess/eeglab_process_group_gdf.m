function eeglab_process_group_gdf(raw_paths,hi_pass,lo_pass,channel_location_path)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

for i = 1:length(raw_paths)
    raw_path = raw_paths{i};
    %files = dir(raw_path);
    cd(raw_paths{i})
    %{
    [~, msg, ~]  = mkdir(save_folder_name);
    if strcmp(msg,'Directory already exists.')
        rmdir(save_folder_name,'s')
        mkdir(save_folder_name);
    end
    %}
    sub_folder_name = append('Subj_',string(i));
    eeglab_process_single_gdf(raw_path,sub_folder_name,channel_location_path,hi_pass,lo_pass);
end

end