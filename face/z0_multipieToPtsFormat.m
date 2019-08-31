%% Transform MultiPIE *.mat into *.pts
clear variables, close all, clc

% Time measurement
tic

% Add testing paths
addpath('../matlab_utilities/'); % progressDisplay

baseFolder = '/media/posefs3b/Users/gines/Datasets/face/tomas_ready/multipie/mpie_train/';
baseFolderMat = '/media/posefs3b/Users/gines/Datasets/face/tomas_ready/multipie/others/mpie_train_mat/';

matFilePaths = dir([baseFolderMat, '*.mat']);
numberMatFiles = numel(matFilePaths);
logEveryXFrames = round(numberMatFiles / 40);

disp(['Processing ', int2str(numberMatFiles), ' mat files...'])

% for i = 1:numberMatFiles
for i = 1:1 % Debug
    % Display progress
    progressDisplay(i, logEveryXFrames, numberMatFiles);
    % Input/output files
    matFilePath = [baseFolderMat, matFilePaths(i).name];
    ptsFilePath = [baseFolder, matFilePaths(i).name(1:end-4), '.pts'];
    % Load keypoints
    load(matFilePath) % pts
    pts = pts(:,1:2);
    % Save pts file
    fileID = fopen(ptsFilePath,'w');
    fprintf(fileID,['version: 1\nn_points:  ', int2str(size(pts,1)), '\n{\n']);
    for pt = 1:size(pts,1)
        fprintf(fileID, '%6.6f %6.6f', pts(pt, 1), pts(pt, 2));
        % % Equivalent but keeping an space at the end of each line
        % fprintf(fileID, '%6.6f ', pts(pt, :));
        fprintf(fileID, '\n');
    end
    fprintf(fileID,'}');
    fclose(fileID);
end

% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
