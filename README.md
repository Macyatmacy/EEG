This is a repo for a project on inner speech decoding with EEG data. In the project, we have compiled a novel dataset to compared two languages: English and Chinese. Different neural representations of two native language groups have been explored with paired t tests, topographies and 3D localasation (with the software sLoreta).
Furthermore, both conventional methods (feature-based) and neural networks (end-to-end) have been evaluated on the the dataset, involving within-subject training, subject-independent training and transfer learning.

Content:
1. Language-specific neural decoding
2. Classification with feature-based methods and end-to-end methods (neural networks).

####################################################################################

5 English native speakers and 7 Chinese native speakers were recruited in the project. We collected about one-hour EEG data for each participant. 
One of the English speakers has participanted twice.

paradigm:
similar to the FEIS dataset but with different prompts:

![alt text](https://github.com/Macyatmacy/EEG/blob/main/Images/prompts.png)
####################################################################################

## We have compared datasets with different preprocessing:

2 ~ 40 Hz without ICA applied

2 ~ 40 Hz with ICA applied

0.5 ~ 125 Hz without ICA applied

0.5 ~ 125 Hz with ICA applied

####################################################################################

## 7 band groups are used to compare neural representations

delta (0.5 ~ 4 Hz)

theta (4 ~ 8 Hz)

alpha (8 ~ 12 Hz)

beta (12 ~ 30 Hz)

low gamma (30 ~ 50 Hz)

median gamma (50 ~ 70 Hz)

high gamma (70 ~ 125 Hz)

####################################################################################

## Three classification tasks and 6 models have been evaluated in content 2:

#### tasks

binary classification: binary classification for each pair of prompts with the opposite meaning in each language.

multi-class classification: 8-class classification for the 8 prompts in each language.

combined binary classification: binary classification for "English vs. Chinese" prompts.

###########################


#### models:

##### feature-based:

a regularized common spatial patterns (RCSP) method

filter bank common spatial patterns (FBCSP) method

##### neural networks:

Shallow FBCSP

Deep4Net

two extensions of Deep4Net

####################################################################################

## Implementation of the codes:

### Data: 

the 2~40 Hz data (without ICA): https://drive.google.com/drive/folders/1xwJEw1Da1R6QRPJjAojCsR_7ZgIVLVa4

we are uploading the other preprocessed data to the google drive and will update soon.

### Code:

The Matlab code is mainly for preprocessing and visulization, and the Python code for model training.

There is a 'top_coding.m' file which controls the processing pipeline from raw data to the data input for training, with most input and output in the cells to be data paths.

### How to use:

1. Add the whole code folder to Matlab path.
2. Put the raw '.csv' files of each subject into a single folder. And put the folders with subject data into a folder. Change matlab path to that folder and strart from 'topfolder = pwd;'; or start with the data in the google drive and set:
fil_folder_name = 'fil_2_40' and update EEG_paths;
3. Follow the instruction in the 'top_coding.m' file to do any processing.

For RCSP, it is implemented in matlab and the functions are in the RCSP folder.

For FBCSP and any neural networks, data should be prepared with Matlab into '.gdf' format, and input into the Python code.

When comparing neural networks, we add two extensions of the Deep4Net into the Braindecode module.

###########################

#### To run RCSP:

##### binary classification: 

RCSP_pair_run.mlx

##### combined binary classification: 

RCSP_comb_run.mlx

###########################

#### To run FBCSP:

##### dependent:

python dependent.py -out_path out_path -type model_type -seed seed -data_path data_path


##### independent:

python independent.py -out_path out_path -type model_type -fold fold_index -seed seed


###########################

#### To run neural networks:

Define the model to train with parameter "model_type".


##### dependent:

python dependent.py -out_path out_path -model_type model_type -data_path data_path -seed seed


##### independent: 

python independent.py -out_path out_path -data_path data_path -model_type model_type -fold fold_index


##### transfer learning:

python transfer.py -data_path data_path -model_type model_type -model_path model_path -out_path out_path -scheme scheme -fold fold_index -seed seed


####################################################################################

Refenrence codes:

transfer learning pipeline adapted from: https://github.com/zhangks98/eeg-adapt

braindecode library(0.4.85 version): https://robintibor.github.io/braindecode/

FBCSP adapted from: https://github.com/TNTLFreiburg/fbcsp

other reference: https://github.com/Macyatmacy/imagined_speech_cnns

####################################################################################

Ref

Zhang, K., Robinson, N., Lee, S. W., & Guan, C. (2021). Adaptive transfer learning for EEG motor imagery classification with deep Convolutional Neural Network. Neural Networks, 136, 1-10.

Schirrmeister, R. T., Springenberg, J. T., Fiederer, L. D. J., Glasstetter, M., Eggensperger, K., Tangermann, M., ... & Ball, T. (2017). Deep learning with convolutional neural networks for EEG decoding and visualization. Human brain mapping, 38(11), 5391-5420.

Cooney, C., Folli, R., & Coyle, D. (2019, October). Optimizing layers improves CNN generalization and transfer learning for imagined speech decoding from EEG. In 2019 IEEE international conference on systems, man and cybernetics (SMC) (pp. 1311-1316). IEEE.
