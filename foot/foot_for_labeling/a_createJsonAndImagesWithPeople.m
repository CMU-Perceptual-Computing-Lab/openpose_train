%% Evaluate COCO images
% MatCaffe requires Matlab to be run from bash:
% matlab &
close all; clear variables; clc

%% Time measurement
tic

%% Load parameters
loadConfigParameters

%% Dependencies
addpath(sMatlabUtilitiesPath);
% addpath([sMatlabUtilitiesPath, 'jsonlab/']);
addpath(sCocoMatlabApiFolder);

%% Load Coco validation image paths
maxWidth = 0;
minWidth = Inf;
maxHeight = 0;
minHeight = Inf;
for mode = 0:0
    %% Load COCO API with desired (validation vs. training) keypoint annotations
    if mode == 0
        dataType = 'train2017';
        load([sMatFolder, 'coco_kpt']);
        cocoStruct = coco_kpt;
    else
        dataType = 'val2017';
        load([sMatFolder, 'coco_val']);
        cocoStruct = coco_val;
    end
    annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], 'person_keypoints', dataType);
    coco = CocoApi(annotationsFile);
    %% Create folders
    baseFolder = '/0_foot_for_clickworker/';
    imageFolderBasePath = [dataType, baseFolder, 'original/'];
    imageFolder = [sBaseFootFolder, imageFolderBasePath];
    imageAnnotatedFolderBasePath = [dataType, baseFolder, 'annotated/'];
    imageAnnotatedFolder = [sBaseFootFolder, imageAnnotatedFolderBasePath];
    jsonFolder = [sBaseFootFolder, dataType, baseFolder, 'json/'];
    mkdir(imageFolder);
    mkdir(imageAnnotatedFolder);
    mkdir(jsonFolder);
    %% Loading images with people on them
    numberImages = numel(cocoStruct); % Images with people: 2693 in val2017, 64115 in train2017
%     numberImages = 50; % Debugging
    logEveryXFrames = max(1, round(numberImages / 10));
    imageIds = zeros(numberImages, 1);
    imagePaths = cell(numberImages, 1);
    validImages = 0;
    validAnnotations = 0;
    for imageId = 1:numberImages
        % Display progress
        progressDisplay(imageId, logEveryXFrames, numberImages);
        % Image path
        imageIds(imageId) = cocoStruct(imageId).image_id;
        imageFileName = coco.loadImgs(imageIds(imageId)).file_name;
        imagePaths{imageId} = [sImagesFolder, dataType, '/', imageFileName];
        % Image annotations
        annotationsIds = coco.getAnnIds('imgIds', imageIds(imageId));
        annotations = coco.loadAnns(annotationsIds);
        % Remove annotations without foot
        removeImage = false;
        for annotationId = numel(annotations):-1:1
            % If no keypoints or if foot occluded or not visible
            if annotations(annotationId).num_keypoints <= 0 ...
                    || annotations(annotationId).keypoints(3*16) ~= 2 ...
                    || annotations(annotationId).keypoints(3*17) ~= 2
                annotations(annotationId) = [];
                removeImage = true;
            end
        end
        if ~removeImage
            validImages = validImages + 1;
            validAnnotations = validAnnotations + numel(annotations);
            image = imread(imagePaths{imageId});
            % Max/min
            maxWidth = max(maxWidth, size(image, 2));
            minWidth = min(minWidth, size(image, 2));
            maxHeight = max(maxHeight, size(image, 1));
            minHeight = min(minHeight, size(image, 1));
            % Generate output
            % Copy file
            imagePath = [imageFolder, imageFileName];
            if ~exist(imagePath, 'file')
                copyfile(imagePaths{imageId}, imagePath);
            end
            % JSON + annotated image
            [~, imageFileNameBase, imageFileNameExtension] = fileparts(imageFileName);
            baseJsonPath = [jsonFolder, imageFileNameBase];
            baseImageAnnPath = [imageAnnotatedFolder, imageFileNameBase];
            for annotationId = 1:numel(annotations)
                annotationString = sprintf('%012d', annotations(annotationId).id);
                imageAnnPath = [baseImageAnnPath, '_', annotationString, imageFileNameExtension];
                jsonPath = [baseJsonPath, '_', annotationString, '.json'];
                % Security checks
                assert(imageIds(imageId) == annotations(annotationId).image_id);
                keypoints = round(annotations(annotationId).keypoints);
                % Generate & copy annotated image
                if ~exist(imageAnnPath, 'file')
                    imageModified = image;
                    % Draw bounding box and ankles
                    width = max(1, round(0.003*max(size(image,1), size(image,2))));
                    rect = round(annotations(annotationId).bbox);
                    indexesW = rect(1)-width:rect(1)+width;
                    indexesH = rect(2)-width:rect(2)+width;
                    widthK = 3*width;
                    for channel = 1:3
                        % Bounding box
                        channelColor = (3-channel)*100;
                        imageModified(min(size(image,1), max(1, (rect(2):rect(2)+rect(4)))), ...
                                      min(size(image,2), max(1, [indexesW, indexesW+rect(3)])), ...
                                      channel) = channelColor;
                        imageModified(min(size(image,1), max(1, [indexesH, indexesH+rect(4)])), ...
                                      min(size(image,2), max(1, (rect(1):rect(1)+rect(3)))), ...
                                      channel) = channelColor;
                        % Keypoints
                        for keypointIndex = 1:17
                            x = keypoints(3*keypointIndex-2);
                            y = keypoints(3*keypointIndex-1);
                            imageModified(min(size(image,1), max(1, y-widthK:y+widthK)), ...
                                          min(size(image,2), max(1, x-widthK:x+widthK)), ...
                                          channel) = channelColor;
                        end
                    end
                    imwrite(imageModified, imageAnnPath);
%                     % Debugging - Display modified image
%                     figure(2), imshow(imageModified); figure(1);
                end
                % JSON
                if ~exist(jsonPath, 'file')
                    [~, imagePathName, imageExtension] = fileparts(imagePath);
                    [~, annImagePath, annImageExtension] = fileparts(imageAnnPath);
                    jsonStruct = struct('image_path', [imageFolderBasePath, imagePathName, imageExtension], ...
                                        'image_path_annotated', [imageAnnotatedFolderBasePath, annImagePath, annImageExtension], ...
                                        'image_id', imageIds(imageId), ...
                                        'id', annotations(annotationId).id, ...
                                        'bbox', round(annotations(annotationId).bbox), ...
                                        'body_keypoints', round(keypoints), ...
                                        'keypoints', -1*ones(6*3, 1));
                    jsonString = jsonencode(jsonStruct);
                    fileId = fopen(jsonPath,'wt');
                    fprintf(fileId, jsonString);
                    fclose(fileId);
                end
            end
%             % Debugging - Display image with annotations
%             imshow(image), hold on;
%             rectangle('Position', annotations(annotationId).bbox, 'EdgeColor','r', 'LineWidth',3);
%             coco.showAnns(annotations(annotationId));
%             hold off;
%             % Debugging - Pause
%             pause();
        end
    end
    fprintf(['\nFinished  ', dataType, '!\n\n']);
    disp(['Number of valid images: ', int2str(validImages)]);
    disp(['Number of valid annotations: ', int2str(validAnnotations)]);
    disp(['Max/min width: ', int2str([maxWidth, minWidth])]);
    disp(['Max/min height: ', int2str([maxHeight, minHeight])]);
    disp(' ');
end

%% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
