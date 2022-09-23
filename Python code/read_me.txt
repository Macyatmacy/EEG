The Matlab code is for preprocessing and visualization, and the Python code for model training.

There is a 'top_coding.m' file which controls the processing pipeline from raw data, with most input and output in the cells being data path.

How to use:
1. Add the whole code folder to Matlab path.
2. Put the raw '.csv' files of each subject into a single folder. And put the folders with subject data into a folder. Change matlab path to that folder and strart from 'topfolder = pwd;'
3. Follow the instruction in the 'top_coding.m' file to do any processing.

For RCSP, it is implemented in matlab and the functions are in the RCSP folder.

For FBCSP and any neural networks, data should be prepared with Matlab into '.gdf' format, and input into the Python code.

FBCSP implementation: Python code/fbcsp
depend on this package: https://github.com/TNTLFreiburg/fbcsp

transfer learning pipeline: 
adapted from :https://github.com/zhangks98/eeg-adapt

classifier in Matlab code is adapted from standard classifier scripts from Mathworks.