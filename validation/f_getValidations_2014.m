%% Demo demonstrating the algorithm result formats for COCO
clear variables; close all; clc

%% Load parameters
loadConfigParameters
addpath([sDatasetFolder, '/cocoapi/MatlabAPI/']);
groundTruthDir='../dataset/COCO/cocoapi';
dataType='val2014';
imagesDir=['/home/gines/devel/images/', dataType, '/'];
jsonsDir='/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/evaluation/coco_val_jsons/';
prefix='instances';

%% My resulting JSON files
% dataDir='../';
% If resFile no selected, it uses a default dammy example
jsonFileNames = {
%     'rt_pose_original.json'; 'rt_pose.json';
%     'matlab_1.json';
    'OpenPose_1_2_0.json';
    '1.json';
    ... % 3 scales
    'OpenPose_1_2_0_3.json';
    '1_3.json';
%     ... % 4 scales
%     'matlab_4.json';
    'OpenPose_1_2_0_4.json';
    '1_4.json';
};
% Notes:
% rt_pose_original --> original rt_pose
% rt_pose --> rt_pose at January 2017
lastImageNumber = 50006;    % = 3559 images
% lastImageNumber = 208;

%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{3}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);

%% initialize COCO ground truth api
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end
annFile=sprintf('%s/annotations/%s_%s.json',groundTruthDir,prefix,dataType);
cocoGt = CocoApi(annFile);

for i=1:numel(jsonFileNames)
    %% initialize COCO detections api
    jsonFile = [jsonsDir, jsonFileNames{i}];
    cocoDt=cocoGt.loadRes(jsonFile);
    % This should read only the used indexes (problem: only where people
    % located)
    % imgIds = unique([cocoDt.data.annotations.image_id])';
    % Use next line instead (it can be don before the for loop) if I want to
    % do sequential image reading
    imgIds = sort(cocoGt.getImgIds());
    imgIds = imgIds(1:find(imgIds==lastImageNumber));

    %% run COCO evaluation code (see CocoEval.m)
    cocoEval=CocoEval(cocoGt,cocoDt,type);
    cocoEval.params.imgIds=imgIds;
    cocoEval.evaluate();
    cocoEval.accumulate();
    cocoEval.summarize();

    %% generate Derek Hoiem style analyis of false positives (slow)
    if(0), cocoEval.analyze(); movefile('analyze', ['analyze_', int2str(i)]); end
end
