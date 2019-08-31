%% Copy all validation images into 3 folders for testing with fileName = fileId
clear variables; close all; clc;

% Time measurement
tic

% Add COCO Matlab API folder (in order to use its API)
addpath('../matlab_utilities/'); % progressDisplay

baseFolder = '/media/posefs4b/User/hidrees/forGines/VehiclePoseEstimation/';
outputFolder = '/home/gines/devel/images/';

jsonPaths = {
    'processed_carfusion_val.json';
    'processed_pascal3dplus_val.json';
    'processed_veri776_val.json';
};
datasetPaths = {
    'car-fusion';
    'pascal3d+';
    'veri-776';
};

% For each dataset
for d = 1:numel(jsonPaths)
    % Read JSON
    jsonStruct = jsondecode(fileread([baseFolder, jsonPaths{d}]));
    % Verbose
    numberAnnotations = numel(jsonStruct.images);
    logEveryXFrames = max(1, round(numberAnnotations / 25));
    % Create output directory
    outputDirectory = [outputFolder, datasetPaths{d}, '_val/'];
    [status, msg, msgID] = mkdir(outputDirectory);
    % Sanity check
    assert(status, [msg, ' - ', msgID]);

    % For each image on that dataset
    disp(['Dataset: ', datasetPaths{d}])
    for i = 1:numberAnnotations
        % Display progress
        progressDisplay(i, logEveryXFrames, numberAnnotations);
        % Get image input and output paths
        imageStruct = jsonStruct.images(i);
        imageFullPath = fullfile(baseFolder, datasetPaths{d}, '/', imageStruct.file_path);
        [~, ~, extension] = fileparts(imageStruct.file_path);
        outputFileName = [outputDirectory, sprintf('%012d',imageStruct.id), extension];
        % Sanity check
        assert(exist(imageFullPath, 'file') == 2, 'exist(imageFullPath, file) == 2');
        % Copy file
        [status, msg] = copyfile(imageFullPath, outputFileName);
        assert(status, [msg, ' - ', msgID]);
%         % Debug - Display images
%         I = imread(imageFullPath);
%         imshow(I);
    end
    disp(' ')
end

% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
