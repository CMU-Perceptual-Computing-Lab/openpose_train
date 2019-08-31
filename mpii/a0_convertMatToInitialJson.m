%% MPII Mat to JSON format
close all; clear variables; clc;
% Time measurement
tic
% Data
sMpiiFolder = '../dataset/MPII/mpii_human_pose_v1_u12_2/';
% Load MPII file (Mat file)
disp('Loading Mat file...');
load([sMpiiFolder, 'mpii_human_pose_v1_u12_1.mat']); % It provides a struct: `RELEASE`
% Generate JSON encoding
disp('Generating JSON encoding...');
text = jsonencode(RELEASE);
text = strrep(text,'\/','/');
% Save as JSON file
disp('Saving JSON file...');
fileID = fopen([sMpiiFolder, '/mpii_human_pose_v1_u12_1','.json'],'w');
fprintf(fileID,text);
fclose(fileID);
% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
