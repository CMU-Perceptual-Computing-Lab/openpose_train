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

%% Load image(s)
% Option a) Specific images
numberImages = 1;
imagePaths = {
%     '../dataset/COCO/images/val2014/COCO_val2014_000000000074.jpg';
%     '../cppVsMatlab/COCO_val2014_000000000136.jpg';
    './sample_image/ski.jpg';
%     './sample_image/upper.jpg'
};
% % Option b) Load real Coco validation image paths
% addpath([sDatasetFolder, '/coco/MatlabAPI/']);
% dataType = 'val2014';
% annotationsFile = sprintf([sAnnotationsFolder, '%s_%s.json'], 'person_keypoints', dataType);
% coco = CocoApi(annotationsFile);
% lastImageNumber = 50006;    % = 3559 images
% imageIds = sort(coco.getImgIds());
% imageIds = imageIds(1:find(imageIds==lastImageNumber));
% numberImages = numel(imageIds);
% imagePaths = cell(numberImages, 1);
% for imageId = 1:numberImages
%     imageFileName = coco.loadImgs(imageIds(imageId)).file_name;
%     imagePaths{imageId} = [sImagesFolder, dataType, '/', imageFileName];
% end

%% Process images
for imageId = 1:numberImages
    image = imread(imagePaths{imageId});
    % Deep net + NMS
    tic
    heatMaps = applyModel(image, param, caffeNet);
    toc

    % Greedy algorithm + visualization
    visualize = 1;
    tic
    [subset, candidates] = connect56LineVec(image, heatMaps, param, visualize);
    if exist('imageids', 'var')
        title(['Image id: ', int2str(imageIds(imageId))])
    end
    toc

    if imageId < numel(imagePaths)
        pause
    end

    % Save result
    % export_fig(['video/frame_' num2str(i) '.jpg']);
end
