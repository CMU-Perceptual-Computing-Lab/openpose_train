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

% NOTE:
% person_keypoints_train2017_foot has ALL COCO + 6 keypoints
% person_keypoints_val2017_foot ONLY has 6 keypoints

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
for mode = 0:0
    % Load COCO API with desired (validation vs. training) keypoint annotations
    if mode == 0
        dataType = 'val2017';
    elseif mode == 1
        dataType = 'train2017';
    else
        assert(false, 'Unknown mode.');
    end
    fprintf(['Converting ', dataType, '\n']);
    annotationFile = sprintf([sAnnotationsFolder, '%s_%s.json'], annType, dataType);
    outputAnnotationFile = sprintf([sAnnotationsFolder, '%s_%s.json'], annType, [dataType, '_foot']);
    cocoAux = CocoApi(annotationFile);
    coco = jsonToStruct(annotationFile);
    % Foot JSON data
    if mode == 0
%         % Version 1
%         footJsonFolder = [s3KeypointJsonFolder1, dataType, s3KeypointJsonFolder2, dataType, s3KeypointJsonFolder3];
        % Version 2
        footJsonFolder = [s3KeypointJsonFolder1, dataType, '_cleaned/', '2_output_clickworker_recleaned/', dataType, s3KeypointJsonFolder3];
    else
        footJsonFolder = [s3KeypointJsonFolder1, dataType, s3KeypointJsonFolder2, dataType, s3KeypointJsonFolder3];
    end
    % Load JSON Annotations
    jsonAnnotations = coco.annotations;
    % Auxiliary parameters
    numberAnnotations = numel(jsonAnnotations);
    logEveryXFrames = max(1, round(numberAnnotations / 25));
    indexesWithFoot = [];
    % JSON to MAT format
    for index = 1:numberAnnotations
        % Display progress
        progressDisplay(index, logEveryXFrames, numberAnnotations);
        % ImageId
        imageId = jsonAnnotations(index).image_id;
        % Read image
        [possibleFootJsonFile, footFileExists] = getFootJsonPath(footJsonFolder, jsonAnnotations, index);
        if ~footFileExists
%             % Debugging - Display image + keypoints
%             % Image path
%             imagePath = [sImageFolder, dataType, '/', sprintf('%012d', imageId), '.jpg'];
%             % Image
%             image = imread(imagePath);
%             imshow(image);
            % No-people image? If so, save image in validation dataset
            if size(coco.annotations(index).keypoints, 1) == 0
                stop % This should never happen, handled previously
            % Otherwise, remove image from final coco entry
            else
                for idAuxiliary = 1:numel(coco.images)
                    if coco.images(idAuxiliary).id == imageId
                        coco.images(idAuxiliary) = [];
                        if mod(numel(coco.images), 100) == 0
                            disp([int2str(numel(coco.images)), ' images left'])
                        end
                        break
                    end
                end
            end
            % Continue
            continue;
        end
        % Foot - Make sure all annotations for image have foot annotations
        firstSample = index;
        allAnnotationsHasFoot = true;
        % LastSample with same imageId
        for increment = [-1,1]
            lastSample = index + increment; % Avoid reading 3 times index-th json file
            while imageId == jsonAnnotations(lastSample).image_id
                [~, footFileExists] = getFootJsonPath(footJsonFolder, jsonAnnotations, lastSample);
                if ~footFileExists
                    allAnnotationsHasFoot = false;
                    break;
                end
                lastSample = lastSample + increment;
            end
            if ~allAnnotationsHasFoot
                break
            end
        end
        % Next image if no all of them has foot
        if ~allAnnotationsHasFoot
            continue
        end
        % Load image struct
        imageStruct = cocoAux.loadImgs(imageId);
        width = imageStruct.width;
        height = imageStruct.height;
        % Keypoints
        % Read foot file
        footJsonStruct = jsonToStruct(possibleFootJsonFile);
        % Reshape foot data
        feet = reshape(round(footJsonStruct.keypoints), 3, [])';
        % Clean feet points outside image
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
        assert(sum(feet(:,3)) ~= -6);
        pureFeet = reshape(feet(1:end, :)', 1, []);
        % Check for errors in data
        if (numel(pureFeet) > 18)
            if (sum(pureFeet(19:end)) > 0)
                footJsonPaths{footFileIndex}
                feet
                system(['subl ', footJsonPaths{footFileIndex}]);
            end
            assert(sum(pureFeet(19:end)) == 0);
            pureFeet = pureFeet(1:18);
        end
        if mode == 0
            keypoints = pureFeet';
            assert(numel(keypoints)/3 == 6, 'numel(keypoints)/3 == 6');
        else
            keypoints = [jsonAnnotations(index).keypoints; pureFeet'];
            assert(numel(keypoints)/3 == 23, 'numel(keypoints)/3 == 23');
        end
%         % Debugging - Display image + keypoints
%         % Image path
%         imagePath = [sImageFolder, dataType, '/', sprintf('%012d', footJsonStruct.image_id), '.jpg'];
%         % Image
%         image = imread(imagePath);
%         if debugging
%             figure(1)
%             % Keypoints
%             annotationsGroundTruth = coco.loadAnns(footJsonStruct.id);
%             % To get all annotations in same image
% %                 annotationIds = coco.getAnnIds('imgIds', jsonStruct.image_id);
% %                 annotationsGroundTruth = coco.loadAnns(annotationIds);
%             % Display image
%             hold off, imshow(image), hold on
%             % COCO Keypoints
%             coco.showAnns(annotationsGroundTruth);
%             % Foot
%             colors = {[1 1 1],[0.5 0.5 0.5],[0.25 0.25 0.25],[1 0 0],[0.4 0 0],[0.15 0 0]};
%             centers = feet(:,1:2);
%             for c = 1:size(centers,1)
%                 center = centers(c,:);
%                 if sum(center < 1) == 0
%                   viscircles(center, 5*ones(size(center,1), 1),'Color',colors{c}, 'LineWidth',10);
%                 end
%             end
%             figure(2)
%             % Display image
%             hold off, imshow(image), hold on
%             % Keypoints
%             keypointsReshaped = reshape(keypoints, 3, [])';
%             keypointsReshaped(keypointsReshaped(:,3) < 0.5, :) = [];
%             centers = keypointsReshaped(:,1:2);
%             viscircles(centers, 3*ones(size(centers,1), 1), 'LineWidth',5);
%             % Pause
%             pause
%         end
        % Add foot data end
        coco.annotations(index).keypoints = keypoints;
        indexesWithFoot = [indexesWithFoot, index];
    end
    fprintf(['\nFinished converting ', dataType, '!\n']);
    % Cropping
    coco.annotations = coco.annotations(indexesWithFoot);
    %% Remove empty keypoints (some labeled people might have 0 foot keypoints)
    removedPeople = 0;
    for indexRm=numel(coco.annotations):-1:1
        if sum(coco.annotations(indexRm).keypoints(3:3:end)) == 0
            coco.annotations(indexRm) = [];
            removedPeople = removedPeople+1;
        end
    end
    fprintf(['Removed ', int2str(removedPeople), ' people!\n']);
    %% Save JSON file
    fprintf('Saving JSON (it might take several minutes or even a few hours...)\n');
    structToJson(outputAnnotationFile, coco);
    fprintf('\nFinished saving JSON!\n\n');
    %% Create validation folder
    fprintf('\nCreating validation folder!\n\n');
    mkdir(sFootValFolder);
    for i = 1:numel(coco.images)
        copyfile(...
            [sBodyValFolder, sprintf('%012d', coco.images(i).id), '.jpg'], ...
            [sFootValFolder, sprintf('%012d', coco.images(i).id), '.jpg'] ...
        );
    end
    fprintf('\nFinished creating validation folder!\n\n');
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
