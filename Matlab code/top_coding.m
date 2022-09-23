clear all;
clc;
%% Switch Workspace
topfolder = pwd;
%% Back to topfolder
cd(topfolder);
%% Parameters
fil_folder_name = 'fil_05_125';
channel_location_path = 'G:\EEG-prepocessing\emotiv.ced';
ICA_folder_name = 'ica';
epoch_folder_name = 'epoch';
% 8 prompts
str_chi = {'zuo','you','shang','xia','shi','fou','hao','huai'};
str_eng = {'left','right','up','down','yes','no','good','bad'};
% each pair of prompts
str_chi1 = {'zuo','you'};
str_eng1 = {'left','right'};
str_chi2 = {'shang','xia'};
str_eng2 = {'up','down'};
str_chi3 = {'shi','fou'};
str_eng3 = {'yes','no'};
str_chi4 = {'hao','huai'};
str_eng4 = {'good','bad'};
%% Get raw data path
[raw_paths] = get_raw_path(topfolder);
save([topfolder,'\','raw_paths.mat'],'raw_paths');
%% Read raw data
read_raw_data(raw_paths);
%% Processing with EEGLab: import data, channels, event tags, re-reference, filter, generate .mat file
lo_pass = 0.5;
hi_pass=125;
[EEG_paths] = eeglab_process_group(raw_paths,fil_folder_name,lo_pass,hi_pass,channel_location_path);
save([topfolder,'\','EEG_paths.mat'],'EEG_paths');
%% get gdf (need to change output folder in the function)
ica_true = false;
get_gdf(EEG_paths,'EEG.set',lo_pass,hi_pass,ica_true);
%save([topfolder,'\','epoched_paths.mat'],'epoched_paths');
%% Processing with EEGLab: import data, channels, event tags, re-reference, filter, generate gdf file
eeglab_process_group_gdf(raw_paths,2,40,channel_location_path);
%% Compute ICA weights
[ICA_paths] = ICA_decompose(raw_paths,EEG_paths,ICA_folder_name);
save([topfolder,'\','ICA_paths.mat'],'ICA_paths');
%% Get paths of subject preprocessed data
[data_paths] = get_EEG_path(topfolder,fil_folder_name,false,"ica_removed"); % ica = true/false
save([topfolder,'\','data_paths.mat'],'data_paths');
%% Prepare data for loreta
save_eng_loreta_name = 'Eng_loreta_speak_removed_ica';
read_file = 'EEG_epoch_speak_eng.mat';
type = "eng_spk";
sub_range = 1:13;
[loreata_eng_paths] = get_loreta(topfolder,data_paths,save_eng_loreta_name,read_file,type,sub_range); 
save([topfolder,'\','loreata_eng_paths.mat'],'loreata_eng_paths');
%% Prepare data for loreta
save_eng_loreta_name = 'Eng_loreta_img_erp_removed_ica';
read_file = 'EEG_epoch_imagine_eng.mat';
type = "eng_img";
sub_range = 1:13;
[loreata_eng_paths] = get_loreta_erp(topfolder,data_paths,save_eng_loreta_name,read_file,type,sub_range); 
save([topfolder,'\','loreata_eng_paths.mat'],'loreata_eng_paths');
%% Prepare data for loreta
save_eng_loreta_name = 'Chi_loreta_img_erp_removed_ica';
read_file = 'EEG_epoch_imagine_chi.mat';
type = "chi_img";
sub_range = 1:13;
[loreata_eng_paths] = get_loreta_erp(topfolder,data_paths,save_eng_loreta_name,read_file,type,sub_range); 
save([topfolder,'\','loreata_chi_paths.mat'],'loreata_chi_paths');
%% Prepare data for loreta
save_eng_loreta_name = 'Chi_loreta_img_tone_3_removed_ica';
read_file = 'EEG_epoch_imagine_chi.mat';
type = "chi_img_tone_3";
tone = 3;
sub_range = 1:13;
[loreata_eng_paths] = get_loreta_tone(topfolder,data_paths,save_eng_loreta_name,read_file,type,sub_range,tone); 
save([topfolder,'\','loreata_chi_paths.mat'],'loreata_chi_paths');
%% Prepare data for loreta
save_eng_loreta_name = 'Chi_loreta_img_tone_4_removed_ica';
read_file = 'EEG_epoch_imagine_chi.mat';
type = "chi_img_tone_4";
tone = 4;
sub_range = 1:13;
[loreata_eng_paths] = get_loreta_tone(topfolder,data_paths,save_eng_loreta_name,read_file,type,sub_range,tone); 
save([topfolder,'\','loreata_chi_paths.mat'],'loreata_chi_paths');
%% Prepare data for loreta
save_eng_loreta_name = 'Chi_loreta_speak_removed_ica';
read_file = 'EEG_epoch_speak_chi.mat';
type = "chi_spk";
sub_range = 1:13;
[loreata_chi_paths] = get_loreta(topfolder,data_paths,save_eng_loreta_name,read_file,type,sub_range); 
save([topfolder,'\','loreata_chi_paths.mat'],'loreata_chi_paths');
%% epoching data
[epoched_paths] = get_epoched(data_paths, epoch_folder_name, str_chi1, str_eng1,[0 5]);
save([topfolder,'\','epoched_paths.mat'],'epoched_paths');
%% get gdf, generate gdf file with EEG.set
ica_true = false;
get_gdf(EEG_paths,'EEG.set',0.5,4,ica_true);
%% calculating correlation between subjects
save_folder_name = "subj_corr";
[subj_corr_paths] = get_subject_corr(data_paths,epoched_paths,save_folder_name);
%% normalize data 
norm_type = "Robust";
save_folder_name = "epoch_norm";
if norm_type == "Robust"
    [epochs_norm_paths] = get_epoch_norm(data_paths,epoched_paths,save_folder_name,norm_type);
end
save([topfolder,'\','epochs_norm_paths.mat'],'epochs_norm_paths');
%% 3.0 split epochs into training and test sets
save_train_folder_name = 'train_epoch';
save_test_folder_name = 'test_epoch';
[train_epochs_paths,test_epochs_paths] = get_epoch_split(data_paths,epoched_paths,save_train_folder_name,save_test_folder_name,0.8);
save([topfolder,'\','train_epochs_paths.mat'],'train_epochs_paths');
save([topfolder,'\','test_epochs_paths.mat'],'test_epochs_paths');
%% Calculate RPSD
RPSD_fname = "RPSD";
[RPSD_paths] = RPSD(data_paths, epoched_paths, RPSD_fname);
save([topfolder,'\','RPSD_paths.mat'],'RPSD_paths');
%% mean RPSD over trials
RPSD_mean_fname = "RPSD_mean";
[RPSD_mean_paths] = RPSD_mean(data_paths, RPSD_paths, RPSD_mean_fname);
save([topfolder,'\','RPSD_mean_paths.mat'],'RPSD_mean_paths');
%% mean RPSD over groups
RPSD_mean_fname = ["RPSD_mean_en","RPSD_mean_cn"];
[RPSD_mean_nl_paths] = RPSD_mean_nl(topfolder,data_paths, RPSD_mean_paths, RPSD_mean_fname);
save([topfolder,'\','RPSD_mean_nl_paths.mat'],'RPSD_mean_nl_paths');
%% train svm
save_folder_name = "classifier_output";
label_order = {'left_imagine','right_imagine','up_imagine','down_imagine','yes_imagine','no_imagine','good_imagine','bad_imagine'};
tic
[classifier_output_paths] = train_classifier(data_paths,feature_norm_train_paths,feature_norm_test_paths,save_folder_name,true,label_order);
toc
%% combine svm output
combined_svm_output_folder = "comb_svm_output";
[combined_svm_output_paths] = combined_output(topfolder,svm_output_paths,combined_svm_output_folder);