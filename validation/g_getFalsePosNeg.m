%% Demo demonstrating the algorithm result formats for COCO
close all; clear variables; clc

%% Load parameters
loadConfigParameters
addpath('../matlab_utilities/');
addpath('../matlab_utilities/openpose/');
addpath([sDatasetFolder, '/cocoapi/MatlabAPI/']);
groundTruthDir='../dataset/COCO/cocoapi';
imagesDir='/home/gines/devel/images/val2017/';
jsonsDir='/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/evaluation/coco_val_jsons/';
% prefix='instances';
dataType='val2017';

%% Select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{3}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);

%% Initialize COCO ground truth api
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end
groundTruthJson=sprintf('%s/annotations/%s_%s.json', groundTruthDir, prefix, dataType);
cocoGroundTruth = CocoApi(groundTruthJson);

%% Initialize COCO detections api
estimatedJson = [jsonsDir, 'OpenPose_1_2_0_4.json'];
cocoEstimated = cocoGroundTruth.loadRes(estimatedJson);

% Image ids to process
imageIds = sort(cocoGroundTruth.getImgIds());
% imageIds = imageIds(1:100);

for imageIdIndex=1:numel(imageIds)
    %% Read image
    imageId = imageIds(imageIdIndex);
    imageStruct = cocoGroundTruth.loadImgs(imageId);
    imageFilePath = sprintf('%s/images/%s/%s', groundTruthDir, dataType, imageStruct.file_name);
    fprintf(imageFilePath);
    fprintf('\n');
    image = imread(imageFilePath);

    %% Loading annotations
    annotationIds = cocoGroundTruth.getAnnIds('imgIds',imageId);
    annotationsGroundTruth = cocoGroundTruth.loadAnns(annotationIds);
    annotationIds = cocoEstimated.getAnnIds('imgIds',imageId);
    annotationsEstimated = cocoEstimated.loadAnns(annotationIds);
    colorReal = [0,1,0];
    colorEstimated = [1,0,0];

    %% False negatives
    for annotationId = 1:numel(annotationsGroundTruth)
        % Get max IoU
        realPerson = annotationsGroundTruth(annotationId);
        realRectangle = getKeypointsRectangle(realPerson.keypoints);
        % If keypoints annotated in ground truth
        if numel(realRectangle) > 0 && getNumberKeypoints(realPerson.keypoints) > 2
            IoUs = zeros(numel(annotationsEstimated), 1);
            for annotationEstimatedId = 1:numel(annotationsEstimated)
                estimatedPerson = annotationsEstimated(annotationEstimatedId);
                estimatedRectangle = getKeypointsRectangle(estimatedPerson.keypoints);
                IoUs(annotationEstimatedId) = getIoU(realRectangle, estimatedRectangle);
            end
            [IoU, index] = max(IoUs);
            % Visualizing bad IoUs
            if numel(IoU) == 0 || IoU < 0.1
                %% Visualizing all
                % Ground truth
                figure(1);
                plotSize = 4;
                plotSize = 2^ceil(log2(plotSize)); % plotSize must be 2^n
                subplot(plotSize,plotSize,1:plotSize/2); imagesc(image); axis('image'); axis off;
                title('Ground truth')
                cocoGroundTruth.showAnns(annotationsGroundTruth);
                % Estimated
                subplot(plotSize,plotSize,plotSize/2+1:plotSize); imagesc(image); axis('image'); axis off;
                title('Results')
                cocoEstimated.showAnns(annotationsEstimated);
                subplot(plotSize,plotSize,plotSize+1:plotSize*plotSize)
                %% Visualizing errors
                % Figure
                imagesc(image); axis('image'); axis off; % Slower: imshow(image)
                title({['FALSE NEGATIVES (red = estimated)  -  ', num2str(imageStruct.file_name), '  -  IoU: ', num2str(IoU)]}, 'Interpreter', 'none')
                % Ground truth
                cocoGroundTruth.showAnns(cocoGroundTruth.loadAnns(realPerson.id), 0.5*colorReal);
                rectangle('Position', realRectangle, 'LineWidth', 3, 'EdgeColor', colorReal);
                % Estimated
                if numel(index) > 0
                    estimatedPerson = annotationsEstimated(index);
                    estimatedRectangle = getKeypointsRectangle(estimatedPerson.keypoints);
                    cocoEstimated.showAnns(cocoEstimated.loadAnns(estimatedPerson.id), 0.5*colorEstimated);
                    rectangle('Position', estimatedRectangle, 'LineWidth', 3, 'EdgeColor', colorEstimated)
                end
                % Pause to visualize
                pause;
            end
        end
    end

    %% False positives
    for annotationEstimatedId = 1:numel(annotationsEstimated)
        % Get max IoU
        estimatedPerson = annotationsEstimated(annotationEstimatedId);
        estimatedRectangle = getKeypointsRectangle(estimatedPerson.keypoints);
        % If keypoints annotated
        if numel(estimatedRectangle) > 0 && getNumberKeypoints(estimatedPerson.keypoints) > 2
            IoUs = zeros(numel(annotationsGroundTruth), 1);
            for annotationId = 1:numel(annotationsGroundTruth)
                realPerson = annotationsGroundTruth(annotationId);
                realRectangle = getKeypointsRectangle(realPerson.keypoints);
                % No keypoints annotated -> use bbox
                if numel(realRectangle) == 0
                    realRectangle = realPerson.bbox;
                end
                IoUs(annotationId) = getIoU(realRectangle, estimatedRectangle);
            end
            [IoU, index] = max(IoUs);
            % Visualizing bad IoUs
            if numel(IoU) == 0 || IoU < 0.1
                %% Visualizing all
                % Ground truth
                figure(1);
                plotSize = 4;
                plotSize = 2^ceil(log2(plotSize)); % plotSize must be 2^n
                subplot(plotSize,plotSize,1:plotSize/2); imagesc(image); axis('image'); axis off;
                title('Ground truth')
                cocoGroundTruth.showAnns(annotationsGroundTruth);
                % Estimated
                subplot(plotSize,plotSize,plotSize/2+1:plotSize); imagesc(image); axis('image'); axis off;
                title('Results')
                cocoEstimated.showAnns(annotationsEstimated);
                subplot(plotSize,plotSize,plotSize+1:plotSize*plotSize)
                %% Visualizing errors
                % Figure
                imagesc(image); axis('image'); axis off; % Slower: imshow(image)
                title({['FALSE POSITIVES (red = estimated)  -  ', num2str(imageStruct.file_name), '  -  IoU: ', num2str(IoU)]}, 'Interpreter', 'none')
                % Ground truth
                if numel(index) > 0
                    realPerson = annotationsGroundTruth(index);
                    realRectangle = getKeypointsRectangle(realPerson.keypoints);
                    % No keypoints annotated -> use bbox
                    if numel(realRectangle) == 0
                        realRectangle = realPerson.bbox;
                    end
                    cocoGroundTruth.showAnns(cocoGroundTruth.loadAnns(realPerson.id), 0.5*colorReal);
                    rectangle('Position', realRectangle, 'LineWidth', 3, 'EdgeColor', colorReal);
                end
                % Estimated
                cocoEstimated.showAnns(cocoEstimated.loadAnns(estimatedPerson.id), 0.5*colorEstimated);
                rectangle('Position', estimatedRectangle, 'LineWidth', 3, 'EdgeColor', colorEstimated)
                % Pause to visualize
                pause;
            end
        end
    end
end
