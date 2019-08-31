%% Evaluate COCO images
% MatCaffe requires Matlab to be run from bash:
% matlab &
close all; clear variables; clc

%% Time measurement
tic

%% Load parameters
loadConfigParameters

%% Dependencies
addpath('../matlab_utilities/');
addpath('../matlab_utilities/jsonlab/');
addpath('../matlab_utilities/openpose/');
addpath([sCocoApiFolder, 'MatlabAPI/']);

%% Load Coco test2016 / test2017 image paths
% dataType = 'val2014';
% dataType = 'test2016';
% annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], 'person_keypoints', dataType);
% coco = CocoApi(annotationsFile);
% load(sCocoMatPath);
% numberImages = 3558; % Ideally = numel(coco_val);
% imageIds = zeros(numberImages, 1);
% imageFilePaths = cell(numberImages, 1);
% for imageId = 1:numberImages
%     imageIds(imageId) = coco_val(imageId).image_id;
%     imageFileName = coco.loadImgs(imageIds(imageId)).file_name;
%     imageFilePaths{imageId} = [sImagesFolder, dataType, '/', imageFileName];
% end

%% Process images
predictions = getPoseKeypoints(imageFilePaths);

%% Process and generate JSON file
cocoJsonStruct = getCocoJsonStruct(predictions, imageIds);

%% Writting COCO JSON file
fprintf('Writting COCO JSON file...\n');
jsonFolder = 'results/';
mkdir(jsonFolder)
param = config();
numberScales = numel(param.scale_search);
jsonFileName = [jsonFolder, ['matlab_', int2str(numberScales), '.json']];
writeJson(cocoJsonStruct, jsonFileName);
fprintf('COCO JSON file written!\n\n');

%% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
