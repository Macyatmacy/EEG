function get_gdf(data_paths, file_name,hi_pass,lo_pass,ica_true)
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
for idx = 1:length(data_paths)
    file_path = data_paths{idx};
    cd(file_path);
    EEG = pop_loadset( file_name);close;
        cd('e:\document\MATLAB\GDF');
        if ica_true
            band_folder = append(erase(string(hi_pass),'.'),'_',string(lo_pass),'_ica');
        else
            band_folder = append(erase(string(hi_pass),'.'),'_',string(lo_pass));
        end
        mkdir(band_folder);
        cd(append('e:\document\MATLAB\GDF\',band_folder));
        sub_folder_name = append('Subj_',string(idx));
        mkdir(sub_folder_name);
        save_name = append('e:\document\MATLAB\GDF\',band_folder,'\',sub_folder_name,'\EEG.gdf');
        pop_writeeeg(EEG, save_name, 'TYPE','GDF');
        eeglab redraw;
end

end