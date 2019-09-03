%% Demo demonstrating the algorithm result formats for COCO
clear variables; close all; clc

%% Load parameters
loadConfigParameters
addpath([sDatasetFolder, '/cocoapi/MatlabAPI/']);
groundTruthDir='../dataset/COCO/cocoapi';
dataType='val2017';
imagesDir=['/home/gines/devel/images/', dataType, '/'];
jsonsDir='/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/evaluation/coco_val_jsons/';
prefix='instances';

%% My resulting JSON files
% dataDir='../';
jsonFileName = '1_4.json';
% jsonFileName = '1_4_MAX.json';
jsonFile = [jsonsDir, jsonFileName];
% jsonFile = '/media/posefs3b/Users/gines/openpose_train/training_results/2_19_42/pose/body_19/4scales/pose_iter_730000.caffemodel_4.json';
isFoot = false;

% jsonFile = '/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/evaluation/coco_val_jsons/1_foot.json';
% isFoot = true;

% % Face
% jsonFile = '/media/posefs3b/Users/gines/openpose_train/training_results/1_135NewTrainTest/pose/body_135/faceMask_1scale/pose_iter_8000.caffemodel_1.json';
% annFile = '/media/posefs3b/Users/gines/openpose_train/dataset/COCO/cocoapi/annotations/face_mask_out_val.json';
% imageFolder = '/home/gines/devel/images/face_mask_out_val/%s';
% isFoot = false;

% % Hand
% jsonFile = '/media/posefs3b/Users/gines/openpose_train/training_results/1_135NewTrainTest/pose/body_135/hand_mpii_1scale/pose_iter_8000.caffemodel_1.json';
% annFile = '/media/posefs3b/Users/gines/openpose_train/dataset/COCO/cocoapi/annotations/hand42_mpii_val.json';
% imageFolder = '/home/gines/devel/images/hand_mpii_val/%s';
% isFoot = false;


%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{3}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);

%% initialize COCO ground truth api
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end
% Body
if ~exist('annFile','var')
    annFile=sprintf('%s/annotations/%s_%s.json',groundTruthDir,prefix,dataType);
end
cocoGt = CocoApi(annFile);
% Foot
% (Re)initialize COCO ground truth api
annFile=sprintf('%s/annotations/%s_%s%s.json',groundTruthDir,prefix,dataType, '_foot');
cocoGtFoot = CocoApi(annFile);
if isFoot
    cocoGt = cocoGtFoot;
end

%% initialize COCO detections api
cocoDt=cocoGt.loadRes(jsonFile);
% This should read only the used indexes (problem: only where people
% located)
% imgIds = unique([cocoDt.data.annotations.image_id])';
% imgIds = sort(imgIds); % <5000 images
% Use next line instead (it can be don before the for loop) if I want to
% do sequential image reading
imgIds = sort(cocoGt.getImgIds()); % 5000 images
for i=1:numel(imgIds)
    imgId = imgIds(i);
    display(' ')
    display(['Image ', int2str(i-1), ', id: ', int2str(imgId)])

    %% run COCO evaluation code (see CocoEval.m)
    cocoEval=CocoEval(cocoGt,cocoDt,type);
    cocoEval.params.imgIds=imgId;
    cocoEval.evaluate();
    cocoEval.accumulate();
    cocoEval.summarize();
    if isnan(cocoEval.stats(1)) || isnan(cocoEval.stats(6))
        display('Skipped');
        continue;
    end

    %% generate Derek Hoiem style analyis of false positives (slow)
    if(0), cocoEval.analyze(); movefile('analyze', ['analyze_', int2str(i)]); end

    %% Read image
    imageStruct = cocoGt.loadImgs(imgId);
    if ~exist('imageFolder','var')
        imageFilePath = sprintf('%s/images/%s/%s', groundTruthDir, dataType, imageStruct.file_name);
    else
        imageFilePath = sprintf(imageFolder, imageStruct.file_name);
    end
%     fprintf(imageFilePath);
%     fprintf('\n');
    image = imread(imageFilePath);

    %% Loading annotations
    annotationIds = cocoGt.getAnnIds('imgIds',imgId);
    annotationsGroundTruth = cocoGt.loadAnns(annotationIds);
    annotationIds = cocoDt.getAnnIds('imgIds',imgId);
    annotationsEstimated = cocoDt.loadAnns(annotationIds);
    colorReal = [0,1,0];
    colorEstimated = [1,0,0];

    %% Display results
    % GT
    subplot(1,2,1); imagesc(image); axis('image'); axis off;
    title(['Ground truth id= ', int2str(imgId), ', #', int2str(i), '/', int2str(numel(imgIds))])
    if isFoot
        for imageId = 1:numel(annotationsGroundTruth)
            annotationsGroundTruth(imageId).num_keypoints = 6;
        end
    end
    if ~isFoot
        cocoGt.showAnns(annotationsGroundTruth);
    end
    % Estimated
    subplot(1,2,2); imagesc(image); axis('image'); axis off;
    title(['Result id= ', int2str(imgId), ', #', int2str(i), '/', int2str(numel(imgIds))])
    if ~isFoot
        cocoDt.showAnns(annotationsEstimated);
    end
    % Verbose
    disp('GT:')
    for imageId = 1:numel(annotationsGroundTruth)
        disp(annotationsGroundTruth(imageId).keypoints);
    end
    disp('Estimated:')
    for imageId = 1:numel(annotationsEstimated)
        disp(round(annotationsEstimated(imageId).keypoints));
    end
    % Pause
    pause
end
