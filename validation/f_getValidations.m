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
% If resFile no selected, it uses a default dammy example
jsonFileNames = {
% % Car
%     % Previously: '_car12'
%     {'processed_carfusion_val_1.json', 'car22cf'};
%     {'processed_pascal3dplus_val_1.json', 'car22p3'};
%     {'processed_veri776_val_1.json', 'car22a7'};
% Foot
    {'1_foot.json', '_foot'};
    {'1_foot_no_neg.json', '_foot'};
% % Face
%     {'/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/openpose/mpie_face.json', 'mpie'};
%     {'/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/openpose/frgc_face.json', 'frgc'};
% Body 1 scale
%     {'OpenPose_1_4_0_cocoChallenge.json', ''};
    {'OpenPose_1_5_0.json', ''};
    {'1.json', ''};
%     {'1_E.json', ''};
%     {'1_E_max.json', ''};
%     {'1_max.json', ''};
% % Body 4 scales
% %     {'OpenPose_1_5_0_4.json', ''};
% %     {'1_4E.json', ''};
% %     {'1_4E_max.json', ''};
% %     {'1_4 BEST.json', ''};
%     {'1_4_max.json', ''};
%     {'1_4.json', ''};
% Body 3 scales
%     {'OpenPose_1_2_0_3.json', ''};
%     {'1_3.json', ''};
% % Specific models
    {'/media/posefs3b/Users/gines/openpose_train/training_results/1_25BBkg/best_810k/pose/body_25b/pose_iter_810000.caffemodel_4.json', ''};
    {'/media/posefs3b/Users/gines/openpose_train/training_results/1_25BBkg/best_810k/pose/body_25b/pose_iter_810000.caffemodel_4_foot.json', '_foot'};
    {'/media/posefs3b/Users/gines/openpose_train/training_results/5_25BSuperModel31DeepAndHM/best_586k/pose/body_25b/pose_iter_586000.caffemodel_4.json', ''};
    {'/media/posefs3b/Users/gines/openpose_train/training_results/5_25BSuperModel31DeepAndHM/best_586k/pose/body_25b/pose_iter_586000.caffemodel_4_foot.json', '_foot'};
    {'/media/posefs3b/Users/gines/openpose_train/training_results/1_135NewTrainTest/best_756k/pose/body_135/pose_iter_756000.caffemodel_4.json', ''};
    {'/media/posefs3b/Users/gines/openpose_train/training_results/1_135NewTrainTest/best_756k/pose/body_135/pose_iter_756000.caffemodel_4_foot.json', '_foot'};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/2_25E/best_818k/1_4_max.json', ''};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/1_25E41/best_866k/1_4_max.json', ''};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/2_25E_HM_PAF/best_794k/1_4_max.json', ''};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/1_25E31/best_722k/1_4_max.json', ''};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/7_25E51/best_894k/1_4_max.json', ''};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/2_19E_51/best_638k/1_4_max.json', ''};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/2_25E51Repeat/best_702k/pose/body_25e/pose_iter_702000.caffemodel_4.json', ''};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/2_25E51Repeat/best_702k/pose/body_25e/pose_iter_702000.caffemodel_4_foot.json', '_foot'};
%     {'/media/posefs3b/Users/gines/openpose_train/training_results/2_25EMixedBatch/best_714k/4_foot.json', '_foot'};
};
firstImage = 1;
lastImage = Inf;
% lastImage = 1000;
% lastImage = 500;
% lastImage = 150;
% Notes:
% rt_pose_original --> original rt_pose
% rt_pose --> rt_pose at January 2017

%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{3}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);

%% initialize COCO ground truth api
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end

for i=1:numel(jsonFileNames)
    % (Re)initialize COCO ground truth api
    dataTypeExtra = jsonFileNames{i}{2};
    sameLenght = (i > 1 && numel(dataTypeExtra) ~= numel(jsonFileNames{i-1}{2}));
    if (i == 1 || (i > 1 && sameLenght || norm(dataTypeExtra - jsonFileNames{i-1}{2}) ~= 0))
        % Car22
        if numel(dataTypeExtra) == 7 && sum(dataTypeExtra(1:5) == 'car22') == 5
            if sum(dataTypeExtra == 'car22cf') == 7
                prefix = 'processed_carfusion_val';
            elseif sum(dataTypeExtra == 'car22p3') == 7
                prefix = 'processed_pascal3dplus_val';
            elseif sum(dataTypeExtra == 'car22a7') == 7
                prefix = 'processed_veri776_val';
            end
            annFile = sprintf('%s/annotations/%s_cocoapi.json',groundTruthDir,prefix)
        % Face frgc
        elseif numel(dataTypeExtra) == 4 && sum(dataTypeExtra(1:4) == 'frgc') == 4
            annFile = sprintf('%s/annotations/%s.json',groundTruthDir,'frgc_val');
        % Face multipie
        elseif numel(dataTypeExtra) == 4 && sum(dataTypeExtra(1:4) == 'mpie') == 4
            annFile = sprintf('%s/annotations/%s.json',groundTruthDir,'multipie_val');
        % Person / Car12
        else
            prefix = 'person_keypoints';
            annFile=sprintf('%s/annotations/%s_%s%s.json',groundTruthDir,prefix,dataType, dataTypeExtra);
        end
        cocoGt = CocoApi(annFile);
    end
    %% initialize COCO detections api
    if jsonFileNames{i}{1}(1) ~= '/'
        jsonFile = [jsonsDir, jsonFileNames{i}{1}];
    else
        jsonFile = jsonFileNames{i}{1};
    end
    cocoDt=cocoGt.loadRes(jsonFile);
    % This should read only the used indexes (problem: only where people
    % located)
    % imgIds = unique([cocoDt.data.annotations.image_id])';
    % Use next line instead (it can be don before the for loop) if I want to
    % do sequential image reading
    imgIds = sort(cocoGt.getImgIds()); % 5000 images
    if lastImage < numel(imgIds)
        imgIds = imgIds(firstImage:lastImage);
    end

    %% run COCO evaluation code (see CocoEval.m)
    cocoEval=CocoEval(cocoGt,cocoDt,type);
    cocoEval.params.imgIds=imgIds;
    cocoEval.evaluate();
    cocoEval.accumulate();
    cocoEval.summarize();

    %% generate Derek Hoiem style analyis of false positives (slow)
    if(0), cocoEval.analyze(); movefile('analyze', ['analyze_', int2str(i)]); end
end
