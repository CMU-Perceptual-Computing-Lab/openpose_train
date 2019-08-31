%% Demo demonstrating the algorithm result formats for COCO
clear variables; close all; clc

%% Time measurement
tic

%% User configurable paths
% OpenPose model names
modelSequences = {
    '2_23_batch316', ...
    'CUB1_19_NEG', ...
    'Cub2_19_batch16_lr5e5', ...
    'GPU4_19_DOME_2', ...
    'BODY_18_STANDARD', ...
};
openPoseModels = {
    'body_23', ...
    'body_19', ...
    'body_19', ...
    'body_19', ...
    'body_18', ...
};
maxSamples = Inf;
% maxSamples = 50;
jsonFilesOP1 = '2014_OP_1';
jsonFilesOP4 = '2014_OP_4';
subFolders = {'1scale/', '4scales/'};

%% Default paths
loadConfigParameters
% COCO API path
addpath(sCocoMatlabApiFolder)
% Sort_nat path
addpath('../matlab_utilities') % printToc
addpath('../matlab_utilities/sort_nat')
% JSON ground truth folder
jsonGroundTruthFolder = '../dataset/COCO/cocoapi/';
jsonFolder = '../training_results/';

%% COCO API
lastImageNumber = 50006;    % = 3559 images

%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{3}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);

%% initialize COCO ground truth api
prefix='instances'; dataType='val2014';
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end
annFile=sprintf('%s/annotations/%s_%s.json',jsonGroundTruthFolder,prefix,dataType);
cocoGt = CocoApi(annFile);

%% Get average precision and recall best OP models
avgPrecAndRecallOP1 = getPrecisionAndRecallUpToX({[jsonFolder, jsonFilesOP1, '.json']}, cocoGt, type, lastImageNumber);
avgPrecAndRecallOP4 = getPrecisionAndRecallUpToX({[jsonFolder, jsonFilesOP4, '.json']}, cocoGt, type, lastImageNumber);

for modelIndex = 1:numel(modelSequences)
    modelSequence = modelSequences{modelIndex};
    openPoseModel = openPoseModels{modelIndex};

    avgPrecAndRecall = cell(numel(subFolders), 1);
    numberFiles = zeros(numel(subFolders), 1);
    for subFolderId = 1:numel(subFolders)
        %% Get JSON files
        % JSONs folder and paths
        jsonsFolder = [jsonFolder, modelSequence, '/pose/', openPoseModel, '/', subFolders{subFolderId}];
        jsonFilePaths = getFilesInFolder(jsonsFolder, 'json');
        % Reading files
        [resFiles,~] = sort_nat(jsonFilePaths); % Matlab sorted: a1, a20, a3. sort_nat: a1, a3, a20
        % Get at most maxSamples files
        if numel(resFiles) > maxSamples
            resFiles = resFiles(1:maxSamples);
        end

        %% Get average precision and recall
        numberFiles(subFolderId) = numel(resFiles);
        avgPrecAndRecall{subFolderId} = getPrecisionAndRecallUpToX(resFiles, cocoGt, type, lastImageNumber);
    end

    %% Plotting results
    xAxis = 2*(0:max(numberFiles));
    xAxisI{1} = 2*(0:numberFiles(1));
    xAxisI{2} = 2*(0:numberFiles(2));
    lineWidth = 3;
    figure(modelIndex),
    for plotIndex = 1:numel(avgPrecAndRecall{1})
        subplot(2, 1, plotIndex),
%         loglog(0,0) % To change to loglog plot
        hold on
        if plotIndex == 1
            title([modelSequence, ' - Trained models on validation set'], 'Interpreter', 'none');
            yLabel = 'Average Precision';
            yLabelShort = 'AP';
        else
            yLabel = 'Average Recall';
            yLabelShort = 'AR';
        end
        plot([0, xAxis(end)], [avgPrecAndRecallOP1{plotIndex}, avgPrecAndRecallOP1{plotIndex}], 'LineWidth', lineWidth)
        plot([0, xAxis(end)], [avgPrecAndRecallOP4{plotIndex}, avgPrecAndRecallOP4{plotIndex}], 'LineWidth', lineWidth)
        for scaleIndex = 1:numel(avgPrecAndRecall)
            plot(xAxisI{scaleIndex}, [0; avgPrecAndRecall{scaleIndex}{plotIndex}], 'LineWidth', lineWidth)
            stem(xAxisI{scaleIndex}, [0; avgPrecAndRecall{scaleIndex}{plotIndex}], 'filled', 'LineStyle', 'None')
        end
        legend([yLabelShort, ' OpenPose 1 scale'], ...
               [yLabelShort, ' OpenPose 4 scales'], ...
               [yLabelShort, ' trained interpolated 1 scale'], ...
               [yLabelShort, ' trained 1 scale'], ...
               [yLabelShort, ' trained interpolated 4 scale'], ...
               [yLabelShort, ' trained 4 scale'], ...
               'Location', 'southeast')
        grid, hold off
        ylabel(yLabel)
    end
    xlabel('10^3 Iterations')
end

%% Time measurement
printToc(toc);
