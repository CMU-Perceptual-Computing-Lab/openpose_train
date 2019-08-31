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
jsonFileName = '1.json';

%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{3}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);

%% initialize COCO ground truth api
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end
annFile=sprintf('%s/annotations/%s_%s.json',groundTruthDir,prefix,dataType);
cocoGt = CocoApi(annFile);

% Modified
% cocoGt

% cocoGt.data.images
% I need id
for i = 1:numel(cocoGt.data.images)
    cocoGt.data.images(i).license = [];
    cocoGt.data.images(i).file_name = [];
    cocoGt.data.images(i).coco_url = [];
    cocoGt.data.images(i).height = [];
    cocoGt.data.images(i).width = [];
    cocoGt.data.images(i).date_captured = [];
    cocoGt.data.images(i).flickr_url = [];
%     cocoGt.data.images(i).id = [];
end

% cocoGt.data.annotations
for i = 1:numel(cocoGt.data.annotations)
    cocoGt.data.annotations(i).segmentation = [];
%     cocoGt.data.annotations(i).num_keypoints % = sum(cocoGt.data.annotations(i).keypoints(3:3:end) > 0)
%     cocoGt.data.annotations(i).area
%     cocoGt.data.annotations(i).iscrowd % 0s
%     cocoGt.data.annotations(i).keypoints
% cocoGt.data.annotations(i).keypoints = [cocoGt.data.annotations(i).keypoints, 0,0,0];
% If #keypoints are changed, there will be an assertion in CocoEval.oks,
% where I'll be able to change the sigmas!
    cocoGt.data.annotations(i).image_id = [];
%     cocoGt.data.annotations(i).bbox
    cocoGt.data.annotations(i).category_id = [];
%     cocoGt.data.annotations(i).id
%     % Area meaning?
%     if cocoGt.data.annotations(i).num_keypoints > 0
%         k = reshape(cocoGt.data.annotations(i).keypoints, 3, [])';
%         k(k(:,3) < 1, :) = []
%         A = (max(k(:,1))-min(k(:,1))) * (max(k(:,2))-min(k(:,2)))
%         cocoGt.data.annotations(i).area
%     end
%     cocoGt.data.annotations(i).area = 1e3;
end

%%

% cocoGt.data.categories
cocoGt.data.categories.keypoints
cocoGt.data.categories = struct(...
...    'supercategory', cocoGt.data.categories.supercategory, ...
    'id', cocoGt.data.categories.id ... % 1
...    'name', cocoGt.data.categories.name, ...
...    'keypoints', cocoGt.data.categories.keypoints, ... % This shows keypoint ordering!
...    'skeleton', cocoGt.data.categories.skeleton ...
);

% cocoGt.data
cocoGt.data = struct(...
...    'info', cocoGt.data.info, ...
...    'licenses', cocoGt.data.licenses, ...
    'images', cocoGt.data.images, ...
    'annotations', cocoGt.data.annotations, ...
    'categories', cocoGt.data.categories ...
);

cocoGt.inds = struct(...
    'imgIds', cocoGt.inds.imgIds, ...
...    'imgIdsMap', cocoGt.inds.imgIdsMap, ...
    'annCatIds', cocoGt.inds.annCatIds, ... % Vector of 1s
...    'annAreas', cocoGt.inds.annAreas, ...
...    'annIscrowd', cocoGt.inds.annIscrowd, ...
...    'annIds', cocoGt.inds.annIds, ...
    'annImgIds', cocoGt.inds.annImgIds ...
...    'annIdsMap', cocoGt.inds.annIdsMap, ...
...    'imgAnnIdsMap', cocoGt.inds.imgAnnIdsMap, ...
...    'catIds', cocoGt.inds.catIds, ...
...    'catIdsMap', cocoGt.inds.catIdsMap, ...
...    'catImgIdsMap', cocoGt.inds.catImgIdsMap, ...
);
% cocoGt

%% initialize COCO detections api
jsonFile = [jsonsDir, jsonFileName];
cocoDt=cocoGt.loadRes(jsonFile);
% This should read only the used indexes (problem: only where people
% located)
% imgIds = unique([cocoDt.data.annotations.image_id])';
% Use next line instead (it can be don before the for loop) if I want to
% do sequential image reading
imgIds = sort(cocoGt.getImgIds()); % 5000 images

%% run COCO evaluation code (see CocoEval.m)
cocoEval=CocoEval(cocoGt,cocoDt,type);
cocoEval.params.imgIds=imgIds;
cocoEval.evaluate();
cocoEval.accumulate();
cocoEval.summarize();

%% generate Derek Hoiem style analyis of false positives (slow)
if(0), cocoEval.analyze(); movefile('analyze', ['analyze_', int2str(i)]); end
