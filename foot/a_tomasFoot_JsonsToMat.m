%% Foot JSON to Mat format
% Copied from `training/a2_coco_jsonToMat.m` 
close all; clear variables; clc;

% Time measurement
tic

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

% Read all JSONs
fprintf('Reading image names...\n');
footJsonPaths = getFilesInFolder(sServerJsonFolder, 'json');
[footJsonPaths, ~] = sort_nat(footJsonPaths); % Matlab sorted: a1, a20, a3. sort_nat: a1, a3, a20
footFileIndex = 0;
footPeopleCounter = 0;
hasFoot = false;

% Converting and saving validation and training JSON data into MAT format
fprintf('Converting and saving JSON into MAT format\n');
debugging = 0;
for mode = 1:1
    % Load COCO API with desired (validation vs. training) keypoint annotations
    if mode == 0
        dataType = 'val2014';
    else
        dataType = 'train2014';
    end
    fprintf(['Converting ', dataType, '\n']);
    annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], annType, dataType);
    coco = CocoApi(annotationsFile);
    % Load JSON Annotations
    jsonAnnotations = coco.data.annotations;
    % Auxiliary parameters
    previousImageId = -1;
    imageCounter = 0;
    numberAnnotations = numel(jsonAnnotations);
    logEveryXFrames = round(numberAnnotations / 50);
    % Initialize matAnnotations (no memory allocation)
    matAnnotations = [];
    % JSON to MAT format
    for i = 1:numberAnnotations
        % Display progress
        progressDisplay(i, logEveryXFrames, numberAnnotations);
        % Get next foot file
        footImageChanged = false;
        if footFileIndex >= numel(footJsonPaths)
            break;
        end
        while ~hasFoot
            % Read foot file
            footFileIndex = footFileIndex + 1;
            fileID = fopen(footJsonPaths{footFileIndex}, 'r');
            footJsonString = fscanf(fileID, '%s');
            fclose(fileID);
            % Json struct
            footJsonStruct = jsondecode(footJsonString);
            try
                feet = reshape(footJsonStruct.vertices, 3, [])';
                hasFoot = true;
            catch
                hasFoot = false;
            end
            if hasFoot
                footPeopleCounter = footPeopleCounter + 1;
                footImageChanged = true;
                % Image path
                imagePath = [sImageFolder, dataType, '/COCO_', dataType, '_', sprintf('%012d', footJsonStruct.image_id), '.jpg'];
                % Image
                image = imread(imagePath);
                % Clean feet points outside image
                width = size(image,2);
                height = size(image,1);
                factor = 0.075;
                absoluteZero = (feet(:,1) < 1 & feet(:,2) < 1) ...
                                | (feet(:,1) < -width*factor) ...
                                | (feet(:,2) < -height*factor) ...
                                | (feet(:,1) > width+width*factor) ...
                                | (feet(:,2) > height+height*factor);
                % Visibility
                feet(:, 3) = 2;
                feet(absoluteZero, 3) = 0;
                % Set left-over-outside-image points to image limits
                feet(absoluteZero, 1:2) = 0;
                feet(feet(:,1) < 1 & feet(:,2) > 1, 1) = 1;
                feet(feet(:,2) < 1 & feet(:,1) > 1, 2) = 1;
                feet(feet(:,1) > width, 1) = width;
                feet(feet(:,2) > height, 2) = height;
                pureFeet = reshape(feet(3:end, :)', 1, []);
%                 % Debugging - Display image + keypoints
%                 if debugging
%                     % Keypoints
%                     annotationsGroundTruth = coco.loadAnns(footJsonStruct.id);
%                     % To get all annotations in same image
% %                     annotationIds = coco.getAnnIds('imgIds', jsonStruct.image_id);
% %                     annotationsGroundTruth = coco.loadAnns(annotationIds);
%                     % Display image
%                     hold off, imshow(image), hold on
%                     % COCO Keypoints
%                     coco.showAnns(annotationsGroundTruth);
%                     % Foot
%                     colors = {[1 1 1],[0.33 0.33 0.33],[1 0 0],[0 0 1],[0.15 0 0],[0 0 0.10]};
%                     centers = feet(:,1:2);
%                     for c = 1:size(centers,1)
%                         center = centers(c,:);
%                         if sum(center < 1) == 0
%                           viscircles(center, 5*ones(size(center,1), 1),'Color',colors{c}, 'LineWidth',10);
%                         end
%                     end
%                     % Pause
%                     pause
%                 end
            end
        end

        % ImageId
        imageId = jsonAnnotations(i).image_id;
        % ImageId vs. footJSON id
        assert(imageId <= footJsonStruct.image_id);
        if imageId == footJsonStruct.image_id
%             if jsonAnnotations(i).id ~= footJsonStruct.id
%                 continue
%             end
            if jsonAnnotations(i).id == footJsonStruct.id
                hasFoot = false;
            end
            if imageId == previousImageId
                personCounter = personCounter + 1;
            else
                personCounter = 1;
                imageCounter = imageCounter + 1;
                % Remember last image id
                previousImageId = imageId;
            end
            assert(imageId == footJsonStruct.image_id);
%             assert(jsonAnnotations(i).id == footJsonStruct.id);

            matAnnotations(imageCounter).image_id = imageId;
            matAnnotations(imageCounter).annorect(personCounter).bbox = jsonAnnotations(i).bbox;
            matAnnotations(imageCounter).annorect(personCounter).segmentation = jsonAnnotations(i).segmentation;
            matAnnotations(imageCounter).annorect(personCounter).area = jsonAnnotations(i).area;
            matAnnotations(imageCounter).annorect(personCounter).id = jsonAnnotations(i).id;
            matAnnotations(imageCounter).annorect(personCounter).iscrowd = jsonAnnotations(i).iscrowd;
            if hasFoot
                keypoints = [jsonAnnotations(i).keypoints, zeros(1, 3*4)];
            else
                keypoints = [jsonAnnotations(i).keypoints, pureFeet];
            end
            matAnnotations(imageCounter).annorect(personCounter).keypoints = keypoints;
            matAnnotations(imageCounter).annorect(personCounter).num_keypoints = jsonAnnotations(i).num_keypoints;
            matAnnotations(imageCounter).annorect(personCounter).img_width = coco.loadImgs(imageId).width;
            matAnnotations(imageCounter).annorect(personCounter).img_height = coco.loadImgs(imageId).height;
%             % Debugging - Display image + keypoints
%             if debugging
%                 % Display image
%                 hold off, imshow(image), hold on
%                 % Keypoints
%                 keypointsReshaped = reshape(keypoints, 3, [])';
%                 keypointsReshaped(keypointsReshaped(:,3) < 0.5, :) = [];
%                 centers = keypointsReshaped(:,1:2);
%                 viscircles(centers, 3*ones(size(centers,1), 1), 'LineWidth',5);
%                 % Pause
%                 pause
%             end
        end
    end
    fprintf(['\nFinished converting ', dataType, '!\n\n']);
    % Save MAT format file
    foot = matAnnotations;
    save([sMatFolder, 'foot_coco2014.mat'], 'foot');
end

fprintf('%d foot annotations were read!\n', footPeopleCounter);

% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
