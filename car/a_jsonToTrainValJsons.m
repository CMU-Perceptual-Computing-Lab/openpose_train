%% COCO JSON to Mat format
% Convert the COCO JSON to a Mat file
% Main difference:
% element / individual (COCO JSON) vs. element / pic with > 0 people (Mat file)
close all; clear variables; clc;

% Time measurement
tic

% Useful information
% This lines can be executed after the code has finished
% numberImages = 118287 (train2017) & 5000 (val2017)
% numberImagesWithPeople = numel(unique(extractfield(jsonAnnotations, 'image_id')))
% numberPeople = numel(extractfield(jsonAnnotations, 'image_id'))

% User-configurable parameters
loadConfigParameters

% Add COCO Matlab API folder (in order to use its API)
addpath(sCocoMatlabApiFolder);
addpath('../matlab_utilities/'); % progressDisplay

% Create folder where results will be saved
mkdir(sMatFolder)

% COCO options
annTypes = {'instances', 'captions', 'person_keypoints'};
annType = annTypes{3}; % specify dataType/annType

% Converting and saving validation and training JSON data into MAT format
fprintf('Converting and saving JSON into MAT format\n');
% Load COCO API with desired (validation vs. training) keypoint annotations
dataType = 'car2018_v1';
annotationsFile = [sDatasetFolder, 'car_dataset/car_fifth.json'];
for mode=0:1
    coco = CocoApi(annotationsFile);
    % Load JSON Annotations
    jsonAnnotations = jsondecode(fileread([sDatasetFolder, 'car_dataset/car_fifth.json']));
    % Train/test - Car
    % Annotations
    numberAnnotationsAll = numel(jsonAnnotations.annotations)
    for i = numberAnnotationsAll:-1:1
        jsonAnnotations.annotations(i).image_id = int64(jsonAnnotations.annotations(i).image_id);
        % Training
        if mode==0
            if jsonAnnotations.annotations(i).image_id > 1900000 % All but last camera for train
                jsonAnnotations.annotations(i) = [];
            end
        % Validation
        else
            if jsonAnnotations.annotations(i).image_id < 1900000 % Last camera for validation
                jsonAnnotations.annotations(i) = [];
            end
        end
    end
    numberAnnotationsFinal = numel(jsonAnnotations.annotations)
    % Images
    numberImagesAll = numel(jsonAnnotations.images)
    for i = numberImagesAll:-1:1
        jsonAnnotations.images(i).id = int64(jsonAnnotations.images(i).id);
        % Training
        if mode==0
            if jsonAnnotations.images(i).id > 1900000 % All but last camera for train
                jsonAnnotations.images(i) = [];
            end
        % Validation
        else
            if jsonAnnotations.images(i).id < 1900000 % Last camera for validation
                jsonAnnotations.images(i) = [];
            end
        end
    end
    numberImagesFinal = numel(jsonAnnotations.images)
    % Save JSON file
    if mode==0
        fileName = [sDatasetFolder, 'car_dataset/car_v1_train.json'];
    else
        fileName = [sDatasetFolder, 'car_dataset/car_v1_val.json'];
    end
    finalJson = jsonencode(jsonAnnotations);
    fid = fopen(fileName, 'wt');
    fprintf(fid, finalJson);
    fclose(fid);
end
