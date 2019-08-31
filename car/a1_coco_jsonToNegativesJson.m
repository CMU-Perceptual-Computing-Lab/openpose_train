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
addpath('../matlab_utilities/');
addpath('../matlab_utilities/sort_nat/');

% Create folder where results will be saved
mkdir(sMatFolder)

% COCO options
annTypes = {'instances', 'captions', 'person_keypoints'};
annType = annTypes{1}; % specify dataType/annType

%% Converting and saving validation and training JSON data into MAT format
fprintf('Converting and saving JSON into MAT format\n');
imagePaths = cell(2, 1);

% Load COCO API with desired (validation vs. training) keypoint annotations
dataType = 'train2017';

%% Read images
fprintf('Reading image names...\n');
imageFilePaths = getFilesInFolder([sImageFolder, dataType], 'jpg');
[imageFilePaths, ~] = sort_nat(imageFilePaths); % Matlab sorted: a1, a20, a3. sort_nat: a1, a3, a20
numberImages = numel(imageFilePaths);
imageIds = zeros(numberImages, 1);
for i=1:numberImages
    imageIds(i) = str2num(imageFilePaths{i}(end-15:end-4));
end
%% Load JSON Annotations
fprintf('Reading JSON people annotations...\n');
annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], annType, dataType);
coco = CocoApi(annotationsFile);
jsonPeopleAnnotations = coco.data.annotations;
numberAnnotations = numel(jsonPeopleAnnotations);
% imageNoCarIds = zeros(numberAnnotations, 1);
imageNoCarIds = [];
i = 1;
disp('Analyzing images...')
while i < numberAnnotations
    % Get range of labels for same image
    i_end = i;
    id = jsonPeopleAnnotations(i).image_id;
    while i_end < numberAnnotations && id == jsonPeopleAnnotations(i_end+1).image_id
        i_end = i_end+1;
    end
    % Vehicles on that image?
    addId = true;
    for subId = i:i_end
        % Note:
        % 1 'person'
        % 2 'bicycle'
        % 3 'car'
        % 4 'motorcycle'
        % 5 'airplane'
        % 6 'bus'
        % 7 'train'
        % 8 'truck'
        % 9 'boat'
        if jsonPeopleAnnotations(i).category_id >= 2 ...
                && jsonPeopleAnnotations(i).category_id <= 9
            addId = false;
            break;
        end
    end
    % Add image only if no cars on it
    if addId
        imageNoCarIds = [imageNoCarIds, id];
    end
    % Update i
    i = i_end + 1;
end
disp('Images analyzed...')
numberAnnotations = numel(imageNoCarIds);
%% Images without people on them
imageNoCarIds = setdiff(imageIds, imageNoCarIds);
numberImagesNoPeople = numel(imageNoCarIds);
%% Image without people paths
imagePaths = cell(numberImagesNoPeople, 1);
for i = 1:numberImagesNoPeople
    imagePaths{i} = sprintf('%012d.jpg', imageNoCarIds(i));
end

%% Saving JSON
jsonString = jsonencode(imagePaths);
fileId = fopen([sJsonFolder, 'coco_negatives_cars.json'], 'wt');
fprintf(fileId, jsonString);
fclose(fileId);

%% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
