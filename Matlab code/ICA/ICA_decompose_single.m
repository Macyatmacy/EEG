function [EEG] = ICA_decompose_single(raw_path,file_path)
%UNTITLED21 Summary of this function goes here
%   Detailed explanation goes here
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename','EEG.set','filepath',file_path);close;
[ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
EEG = eeg_checkset( EEG );
EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');close;
[ALLEEG EEG] = eeg_store(ALLEEG, EEG, CURRENTSET);
eeglab redraw;
EEG = pop_saveset( EEG, 'filename','EEG.set','filepath',[raw_path,'\ica\']);
EEG = eeg_checkset( EEG );
end