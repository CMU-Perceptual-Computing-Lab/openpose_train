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
for mode = 0:1 % Body
% for mode = 2:3 % Foot
% for mode = 4 % Car14
% for mode = 5:7 % Car22
% for mode = 8:10 % Face70 as COCO format
% for mode = 11:12 % Hand21, Hand42 as COCO format
% for mode = 13 % Dome135
    % Load COCO API with desired (validation vs. training) keypoint annotations
    % COCO val
    if mode == 0 || mode == 2
        dataType = 'val2017';
    % COCO train
    elseif mode == 1 || mode == 3
        dataType = 'train2017';
    % Car14
    elseif mode == 4
        dataType = 'car2018_v1';
    % Car22
    elseif mode == 5
        dataType = 'carfusion_train';
    elseif mode == 6
        dataType = 'pascal3dplus_train';
    elseif mode == 7
        dataType = 'veri776_train';
    % Face70
    elseif (mode >= 8 && mode <= 10)
        % frgc
        if mode == 8
            dataType = 'frgc_train';
        % multipie
        elseif mode == 9
            dataType = 'multipie_train';
        % face_mask_out
        elseif mode == 10
            dataType = 'face_mask_out_train';
        end
    % Hand21
    elseif mode == 11
        dataType = 'dome';
    % Hand42
    elseif mode == 12
        dataType = 'mpii';
    % Dome135
    elseif mode == 13
        dataType = 'dome';
    % Unknown
    else
        assert(false, 'Unknown mode.');
    end
    % Foot
    if (mode == 2 || mode == 3)
        dataType = [dataType, '_foot_v2'];
        numberKeyPoints = 23;
    % COCO
    elseif (mode == 0 || mode == 1)
        numberKeyPoints = 17;
    % Car14
    elseif mode == 4
        numberKeyPoints = 14;
    % Car22
    elseif mode >= 5 && mode <= 7
        numberKeyPoints = 22;
    % Face70
    elseif (mode >= 8 && mode <= 10)
        numberKeyPoints = 70;
    % Hand21
    elseif mode == 11
        numberKeyPoints = 21;
    % Hand42
    elseif mode == 12
        numberKeyPoints = 42;
    % Dome135
    elseif mode == 13
        numberKeyPoints = 135;
    % Unknown
    else
        assert(false, 'Unknown mode.');
    end
    fprintf(['Converting ', dataType, '\n']);
    % Car14
    if mode == 4
        annotationsFile = [sDatasetFolder, 'car_dataset/car_v1_train.json'];
    % Car22
    elseif mode >= 5 && mode <= 7
        annotationsFile = ['/media/posefs4b/User/hidrees/VehiclePoseEstimation/processed_', dataType, '.json'];
    % Face70
    elseif (mode >= 8 && mode <= 10)
        annotationsFile = ['/media/posefs3b/Users/gines/Datasets/face/tomas_ready/', dataType, '.json'];
    % Hand21
    elseif mode == 11
%         annotationsFile = [sDatasetBaseFolder, 'hand/json/hand21_', dataType, '_train.json'];
%         annotationsFile = [sDatasetBaseFolder, 'hand/json_bbox_v1/hand21_', dataType, '_train.json'];
        annotationsFile = [sDatasetBaseFolder, 'hand/hand21_', dataType, '_train.json'];
    % Hand42
    elseif mode == 12
%         annotationsFile = [sDatasetBaseFolder, 'hand/json/hand42_', dataType, '_train.json'];
%         annotationsFile = [sDatasetBaseFolder, 'hand/json_bbox_v1/hand42_', dataType, '_train.json'];
        annotationsFile = [sDatasetBaseFolder, 'hand/hand42_', dataType, '_train.json'];
    % Hand135
    elseif mode == 13
        annotationsFile = [sDatasetBaseFolder, 'dome/dome135_train_v1.json'];
    % Any other
    else
        annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], annType, dataType);
    end
    coco = CocoApi(annotationsFile);
    % Load JSON Annotations
    jsonAnnotations = coco.data.annotations;
    % Auxiliary parameters
    previousImageId = -1;
    imageCounter = 0;
    numberAnnotations = numel(jsonAnnotations);
    logEveryXFrames = max(1, round(numberAnnotations / 25));
    % Initialize matAnnotations (no memory allocation)
    matAnnotations = [];
%     % Initialize matAnnotations (avoid memory allocation warning) (it's actually slower!!!)
%     numberImagesWithPeople = numel(unique(extractfield(jsonAnnotations, 'image_id')));
%     matAnnotations = struct('image_id', []);
%     matAnnotations(numberImagesWithPeople).image_id = [];
    % JSON to MAT format
    for i = 1:numberAnnotations
        % Display progress
        progressDisplay(i, logEveryXFrames, numberAnnotations);
        % ImageId
        imageId = jsonAnnotations(i).image_id;
        % Same image, new person annotation
        if imageId == previousImageId
            personCounter = personCounter + 1;
        % New image
        else
            personCounter = 1;
            imageCounter = imageCounter + 1;
            % Image
            imageStruct = coco.loadImgs(imageId);
            % Car22
            if mode >= 5 && mode <= 7
                % Find file_path for image_id
                matAnnotations(imageCounter).image_path = imageStruct.file_path;
%                 [fileFolder, fileName, ext] = fileparts(imageStruct.file_path);
%                 matAnnotations(imageCounter).image_path = [fileName, ext];
            % Face70, Hand21, Hand42, Dome135
            elseif (mode >= 8 && mode <= 13)
                matAnnotations(imageCounter).image_path = imageStruct.file_name;
            end
        end
        matAnnotations(imageCounter).image_id = imageId;
        matAnnotations(imageCounter).annorect(personCounter).bbox = jsonAnnotations(i).bbox;
        matAnnotations(imageCounter).annorect(personCounter).segmentation = jsonAnnotations(i).segmentation;
        matAnnotations(imageCounter).annorect(personCounter).area = jsonAnnotations(i).area;
        matAnnotations(imageCounter).annorect(personCounter).id = jsonAnnotations(i).id;
        matAnnotations(imageCounter).annorect(personCounter).iscrowd = jsonAnnotations(i).iscrowd;
        matAnnotations(imageCounter).annorect(personCounter).num_keypoints = jsonAnnotations(i).num_keypoints;
        width = imageStruct.width;
        height = imageStruct.height;
        matAnnotations(imageCounter).annorect(personCounter).img_width = width;
        matAnnotations(imageCounter).annorect(personCounter).img_height = height;
        % Remember last image id
        previousImageId = imageId;
        % Keypoints
        keypoints = jsonAnnotations(i).keypoints;
        % Car22
        if mode >= 5 && mode <= 7
            % Ignore keypoint #23
            keypoints = keypoints(1:end-3);
        end
if (numel(keypoints)/3 == 42 && mode == 11)
'TEMPORARY CODE'
    keypoints = keypoints(1:end/2);
end
        assert(numel(keypoints)/3 == numberKeyPoints, ...
            ['Required: numel(keypoints)/3 = ', int2str(numel(keypoints)/3), ' == ', int2str(numberKeyPoints)]);
        matAnnotations(imageCounter).annorect(personCounter).keypoints = keypoints;
    end
    fprintf(['\nFinished converting ', dataType, '!\n']);
    % Save MAT format file
    fprintf(['Saving ', dataType, '\n']);
    % Body (validation)
    if mode == 0
        coco_val = matAnnotations;
        save([sMatFolder, 'coco_val.mat'], 'coco_val');
    % Body (train)
    elseif mode == 1
        coco_kpt = matAnnotations;
        save([sMatFolder, 'coco_kpt.mat'], 'coco_kpt');
    % Foot
    elseif mode == 2
        coco_val = matAnnotations;
        save([sMatFolder, 'coco2017_val_foot.mat'], 'coco_val');
    elseif mode == 3
        coco_kpt = matAnnotations;
        save([sMatFolder, 'coco_kpt_foot.mat'], 'coco_kpt');
    % Car14
    elseif mode == 4
        car_v1 = matAnnotations;
        save([sMatFolder, 'car_v1.mat'], 'car_v1');
    % Car22
    elseif mode == 5
        car_kpt = matAnnotations;
        save([sMatFolder, 'car22_carfusion.mat'], 'car_kpt');
    elseif mode == 6
        car_kpt = matAnnotations;
        save([sMatFolder, 'car22_pascal3dplus.mat'], 'car_kpt');
    elseif mode == 7
        car_kpt = matAnnotations;
        save([sMatFolder, 'car22_veri776.mat'], 'car_kpt');
    % Face70
    elseif (mode >= 8 && mode <= 10)
        coco_kpt = matAnnotations;
        save([sMatFolder, 'face70_', dataType, '.mat'], 'coco_kpt');
    % Hand21
    elseif mode == 11
        coco_kpt = matAnnotations;
        save([sMatFolder, 'hand21_', dataType, '.mat'], 'coco_kpt');
    % Hand42
    elseif mode == 12
        coco_kpt = matAnnotations;
        save([sMatFolder, 'hand42_', dataType, '.mat'], 'coco_kpt');
    % Dome135
    elseif mode == 13
        coco_kpt = matAnnotations;
        save([sMatFolder, 'dome135.mat'], 'coco_kpt');
    % Unknown
    else
        assert(false, 'Unknown mode.');
    end
    fprintf(['Finished saving ', dataType, '!\n\n']);
end
% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);

% Extra functions
function [footJsonFile, exists] = getFootJsonPath(footJsonFolder, jsonAnnotations, i)
    footJsonFile = [footJsonFolder, sprintf('%012d', jsonAnnotations(i).image_id), ...
                                            '_', sprintf('%012d', ...
                                            jsonAnnotations(i).id), '.json'];
    exists = (exist(footJsonFile, 'file') == 2);
end
