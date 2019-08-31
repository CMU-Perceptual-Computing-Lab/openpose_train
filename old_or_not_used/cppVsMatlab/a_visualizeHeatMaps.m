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
% image = imread('./ski.jpg');
% heatMapsCpp = imread('./OpenPoseHeatMaps/ski_pose_heatmaps.png');
image = imread('./COCO_val2014_000000000136.jpg');
heatMapsCpp = imread('./OpenPoseHeatMaps/COCO_val2014_000000000136_pose_heatmaps.png');

% Deep net + NMS
tic
heatMaps = applyModel(image, param, caffeNet);
toc

% Greedy algorithm + visualization
visualize = 1;
tic
connect56LineVec(image, heatMaps, param, visualize);
toc

%% Debug heatmaps
clc
% Matlab
heatMapsScaled = heatMaps;
heatMapsScaled(heatMapsScaled>1) = 1;
heatMapsScaled(heatMapsScaled<-1) = -1;
heatMapsScaled(:,:,19:end) = (heatMapsScaled(:,:,19:end) + 1) / 2;
heatMapsScaled(heatMapsScaled<0) = 0;
heatMapsReshaped = reshape(heatMapsScaled, size(heatMapsScaled,1), size(heatMapsScaled,2)*size(heatMapsScaled,3));
assert(max(max(heatMapsReshaped)) <= 1, 'max(max(heatMapsReshaped)) <= 1');
assert(min(min(heatMapsReshaped)) >= 0, 'max(max(heatMapsReshaped)) >= 0');
heatMapsReshaped = uint8(round(255*heatMapsReshaped));
assert(max(max(heatMapsReshaped)) <= 255, 'max(max(heatMapsReshaped)) <= 255');
assert(min(min(heatMapsReshaped)) >= 0, 'max(max(heatMapsReshaped)) >= 0');

% C++
% size(heatMaps)
% Ski
% heatMapsCpp = heatMapsCpp(1:674, :);
% COCO
heatMapsCppReshaped = reshape(heatMapsCpp, size(heatMapsCpp,1), size(heatMapsCpp,2)/56, []);
heatMapsCppReshaped = heatMapsCppReshaped(1:374, 1:500, :);
heatMapsCppReshaped = reshape(heatMapsCppReshaped, size(heatMapsCpp,1), []);

% Sizes
disp('Sizes:')
size(heatMapsReshaped)
size(heatMapsCppReshaped)

% Difference
difference = uint8(round(255/2+0.5*(single(heatMapsReshaped)-single(heatMapsCppReshaped))));
% min(difference(:))
max(difference(:))

% Display all heatmaps together
figure(2)
subplot(3,1,1)
imshow(heatMapsReshaped)
subplot(3,1,2)
imshow(heatMapsCppReshaped)
subplot(3,1,3)
imshow(difference)

% Visualize each individual heatmap for C++ & Matlab
figure(3)
width = size(heatMaps,2);
numberFigures = 8;
for i = 1:56
    minX = (i-1)*width+1;
    maxX = minX - 1 + width;
    subplot(2,2,1)
    imshow(heatMapsReshaped(:, minX:maxX))
    xlabel(int2str(i))
    title('Matlab')
    subplot(2,2,2)
    imshow(heatMapsCppReshaped(:, minX:maxX))
    title('C++')
    subplot(2,2,3)
    diffScaled = difference(:, minX:maxX);
    diffScaled = uint8(round((single(diffScaled) - 255/2) * 5 + 255/2));
    imshow(diffScaled)
    xlabel(int2str(max(max(difference(:, minX:maxX)))))
    ylabel(int2str(min(min(difference(:, minX:maxX)))))
    title('Difference')
    pause
end
