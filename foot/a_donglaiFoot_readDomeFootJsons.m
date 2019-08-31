%% Foot JSON to Mat format
% Copied from `training/a2_coco_jsonToMat.m` 
close all; clear variables; clc;

% Time measurement
tic

% Read JSON with info
jsonString = fileread('/media/posefs0c/panopticdb/body_foot/sample_list.json');
jsonStruct = jsondecode(jsonString);
assert((numel(jsonStruct.imgs) == numel(jsonStruct.body)) ...
        && (numel(jsonStruct.imgs) == numel(jsonStruct.foot)) ...
        && (numel(jsonStruct.imgs) == numel(jsonStruct.bbox)) ...
        && (numel(jsonStruct.imgs) == numel(jsonStruct.foot_inside)), ...
        'Number of elements should be the same for each element!');

disp(['Number images with annotations: ', int2str(numel(jsonStruct.imgs))])

% Remove files with no all the keypoints visible
jsonStruct.imgs(~jsonStruct.foot_inside) = [];
jsonStruct.body(~jsonStruct.foot_inside) = [];
jsonStruct.foot(~jsonStruct.foot_inside) = [];
jsonStruct.bbox(~jsonStruct.foot_inside) = [];
jsonStruct.foot_inside(~jsonStruct.foot_inside) = [];

disp(['Number images with all foot annotated: ', int2str(numel(jsonStruct.imgs))])

%%
jsonStruct.imgs(end) % JPG image path
jsonStruct.body(end) % Body JSON path
% jsonStruct.foot_inside(end) % Bool whether all foot keypoints are available
jsonStruct.foot(end) % Foot JSON path
jsonStruct.bbox(end) % Bbox JSON path

% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
