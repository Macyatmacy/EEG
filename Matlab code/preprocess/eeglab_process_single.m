function eeglab_process_single_gdf(raw_path,save_folder_name,channel_location_path,hi_pass,lo_pass)
EEG = pop_importdata('dataformat','matlab','nbchan',14,'data',[raw_path,'\','eeglab_input.mat'],'srate',256,'pnts',0,'xmin',0,'chanlocs',channel_location_path);
EEG.setname='data';
EEG = eeg_checkset( EEG );
EEG = pop_importevent( EEG, 'event',[raw_path,'\','events.txt'],'fields',{'latency','duration','type'},'skipline',1,'timeunit',1);
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
EEG = eeg_checkset( EEG );
EEG = pop_eegfiltnew(EEG, 'locutoff',hi_pass,'hicutoff',lo_pass,'plotfreqz',1,'plotfreqz',0);
EEG = eeg_checkset( EEG );
EEG = pop_reref( EEG, []);
EEG = eeg_checkset( EEG );
EEG = pop_saveset( EEG, 'filename','EEG.set','filepath',[raw_path,'\',save_folder_name,'\']);
EEG = eeg_checkset( EEG );
save([raw_path,'\',save_folder_name,'\','EEG.mat'],'EEG');
end