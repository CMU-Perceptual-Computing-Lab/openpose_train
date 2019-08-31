%% Demo
% MatCaffe requires Matlab to be run from bash:
% matlab &
close all; clear variables; clc

%% Setting environment + loading net
% Add dependencies
addpath('../matlab_utilities/openpose/');
addpath('../matlab_utilities/ojwoodford-export_fig-5735e6d/');

% Load Caffe and model
param = config();
model = param.model;
caffeNet = caffe.Net(model.deployFile, model.caffemodel, 'test');
loadConfigParameters

%% Process images
% Load image
image = imread('./ski.jpg');

% Deep net + NMS
tic
heatMaps = applyModel(image, param, caffeNet);
toc

% % Greedy algorithm + visualization
% visualize = 0;
% tic
% Run internally this function and debug it from inside
% connect56LineVec(image, heatMaps, param, visualize);
% toc

% NMS (Non-Maximum Suppression) to find joint candidates
tic
numberBodyParts = 18;
[candidates, maximum] = nms(heatMaps, param, numberBodyParts);
toc
