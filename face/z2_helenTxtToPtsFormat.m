%% Transform MultiPIE *.mat into *.pts
clear variables, close all, clc

% Time measurement
tic

% Add testing paths
addpath('../matlab_utilities/'); % progressDisplay

baseFolderTrain = '/media/posefs3b/Users/gines/Datasets/face/tomas_ready/helen/other/train_194/';
baseFolderTest = '/media/posefs3b/Users/gines/Datasets/face/tomas_ready/helen/other/test_194/';
baseFolderTxt = '/media/posefs3b/Users/gines/Datasets/face/tomas_ready/helen/other/annotation/';

txtFilePaths = dir([baseFolderTxt, '*.txt']);
numberMatFiles = numel(txtFilePaths);
logEveryXFrames = round(numberMatFiles / 40);

disp(['Processing ', int2str(numberMatFiles), ' txt files...'])

for i = 1:numberMatFiles
% for i = 1:1 % Debug
    % Display progress
    progressDisplay(i, logEveryXFrames, numberMatFiles);
    % Input file
    txtFilePath = [baseFolderTxt, txtFilePaths(i).name];
    txtString = fileread(txtFilePath);
    txtStrings = strsplit(txtString, '\n');
    % Remove `\n` at the end of each element + remove empty elements (last one)
    for j=numel(txtStrings):-1:1
        if numel(txtStrings{j}) == 0
            txtStrings(j) = [];
        else
            txtStrings{j} = txtStrings{j}(1:end-1);
        end
    end
    % Output file
    trainImageEquivalent = [baseFolderTrain, txtStrings{j}, '.jpg'];
    if isfile(trainImageEquivalent)
        ptsFilePath = [baseFolderTrain, txtStrings{j}, '.pts'];
    else
        ptsFilePath = [baseFolderTest, txtStrings{j}, '.pts'];
    end
    % Remove first element
    txtStrings(1) = [];
    % Load keypoints
    pts = [];
    for j=1:numel(txtStrings)
        row = textscan(txtStrings{j}, '%f','delimiter',',');
        pts = [pts, row{1}];
    end
    pts = pts';
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
