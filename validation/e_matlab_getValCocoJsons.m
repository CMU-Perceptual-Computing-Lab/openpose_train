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

%% Load Coco validation image paths
% % Option a) (Zhe's version): Only loading images with people on them
% dataType = 'val2014';
% annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], 'person_keypoints', dataType);
% coco = CocoApi(annotationsFile);
% load(sCocoMatPath);
% numberImages = 3558; % Ideally = numel(coco_val);
% numberImages = 31; % Debugging
% imageIds = zeros(numberImages, 1);
% imagePaths = cell(numberImages, 1);
% for imageId = 1:numberImages
%     imageIds(imageId) = coco_val(imageId).image_id;
%     imageFileName = coco.loadImgs(imageIds(imageId)).file_name;
%     imagePaths{imageId} = [sImagesFolder, dataType, '/', imageFileName];
% end
% Option b) Load real Coco validation image paths
dataType = 'val2014';
annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], 'person_keypoints', dataType);
coco = CocoApi(annotationsFile);
lastImageNumber = 50006;    % = 3559 images
% lastImageNumber = 74;    % Debugging
imageIds = sort(coco.getImgIds());
imageIds = imageIds(1:find(imageIds==lastImageNumber));
numberImages = numel(imageIds);
imagePaths = cell(numberImages, 1);
for imageId = 1:numberImages
    imageFileName = coco.loadImgs(imageIds(imageId)).file_name;
    imagePaths{imageId} = [sImagesFolder, dataType, '/', imageFileName];
end

%% Process images
predictions = getPoseKeypoints(imagePaths, sNumberGpus, sNumberGpusStart);

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
