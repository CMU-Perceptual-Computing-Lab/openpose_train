%% Script splitting test2015/ images into test2015_dev/
clear variables; close all; clc

%% Time measurement
tic

%% Default paths
addpath('../matlab_utilities/')
yearString = '2017';
datasetPath = '../dataset/COCO/';
testDevFilePath = [datasetPath, 'coco/annotations/image_info_test-dev', yearString, '.json'];
testFolder = [datasetPath, 'images/test', yearString, '/'];
testDevFolder = [datasetPath, 'images/test', yearString, '_dev/'];

%% Read JSON text
fileID = fopen(testDevFilePath);
formatSpec = '%s'; % Text Array
jsonTextString = fscanf(fileID, formatSpec);

%% JSON string to image paths
fprintf('JSON string to image paths...\n');
jsonStruct = jsondecode(jsonTextString);
jsonImagesStruct = jsonStruct.images;
imageFileNames = cell(numel(numel(jsonImagesStruct)), 1);
for imageIndex = 1:numel(jsonImagesStruct)
    imageFileNames{imageIndex} = jsonImagesStruct(imageIndex).file_name;
end

%% Create testDevFolder
fprintf('Creating test dev folder...\n');
[status, msg, msgID] = mkdir(testDevFolder);
if status ~= 1
    error(['Error when creating folder. Message: ', msg, '. Message ID: ', int2str(msgID)]);
end

%% Copy images
fprintf('Copying images...\n');
numberAnnotations = numel(imageFileNames);
logEveryXFrames = round(numberAnnotations / 50);
for imageIndex = 1:numel(imageFileNames)
    fileName = imageFileNames{imageIndex};
    imageTestPath = [testFolder, fileName];
    imageTestDevPath = [testDevFolder, fileName];
    [status, msg, msgID] = copyfile(imageTestPath, imageTestDevPath);
    if status ~= 1
        error(['Error when creating folder. Message: ', msg, '. Message ID: ', int2str(msgID)]);
    end
    % Display progress
    progressDisplay(imageIndex, logEveryXFrames, numberAnnotations);
end
fprintf('\nFinished copying images!\n\n');

%% Time measurement
printToc(toc);
