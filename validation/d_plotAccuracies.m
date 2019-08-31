%% Demo demonstrating the algorithm result formats for COCO
clear variables; close all; clc

%% Time measurement
tic

%% User configurable paths
% OpenPose model names
modelSequences = {
    % 25B
    {'1_25BBkg', 'body_25b', '4'};
%     {'100_25BBig', 'body_25b', '4'};
%     {'6_25BSuperModel2', 'body_25b', '4'};
    {'2_25BSuperModel', 'body_25b', '4'}; % Used ICCV
    {'5_25BSuperModel31DeepAndHM', 'body_25b', '4'}; % Used ICCV
    {'5_25BSuperModel41', 'body_25b', '4'}; % Used ICCV
    {'1_25BSuperModel31PreDCConcat', 'body_25b', '4'}; % Used ICCV
    {'2_25BSuperModel21FullVGG', 'body_25b', '4'}; % Used ICCV
    % 135
    {'1_135NewTrainTest', 'body_135', '14'};
    {'100_135Big', 'body_135', '14'};
    {'100_135BigMoreBody2', 'body_135', '14'};
    {'100_135AlmostSameBatchAllGPUs', 'body_135', '14'};
%     % Car-based
%     {'2_22car', 'car_22'};
%     ...
%     % Car-based (old)
%     {'1_12CarV1', 'car_12'};
%     ...
%     % V100-based
%     {'0_25In624FineTune', 'body_25'};
%     {'0_25In624', 'body_25'};
%     ...
%     % Distance-based
%     {'2_25DistanceNeck', 'body_25d'};
%     {'2_25DistanceAll2_star', 'body_25d'};
%     {'2_25DistanceAll2', 'body_25d'};
%     ...
%     % DenseNet-based
%     {'1_19DenseNet', 'body_19n'};
%     {'1_19DenseNet2', 'body_19n'};
%     ...
%     % Binary
%     {'1_19BinaryPretrained', 'body_19'};
%     {'1_19BinaryPretrained2', 'body_19'};
%     {'1_19FullBinary', 'body_19'};
%     {'1_19TanH', 'body_19'};
};
dataType='val2017';
maxSamples = Inf;
% maxSamples = 60/2;
% maxSamples = 400;
% maxSamples = 200;
% maxSamples = 100;
% maxSamples = 50;
% maxSamples = 25;
% maxSamples = 5;
subFoldersPerson = {
    % Body
    '1scale/';
    '4scales/';
    % Foot
    'foot_1scale/';
    'foot_4scales/';
    % Face
    'frgc_1scale/';
    'frgc_4scales/';
    'mpie_1scale/';
    'mpie_4scales/';
    'faceMask_1scale/';
    'faceMask_4scales/';
    % Hand
    'hand_dome_1scale/';
    'hand_dome_4scales/';
    'hand_mpii_1scale/';
    'hand_mpii_4scales/';
};
subFoldersCar = {
    'scaleCF_1/';
    'scaleP3_1/';
    'scaleV7_1/';
%     'scaleCF_4/';
%     'scaleP3_4/';
%     'scaleV7_4/';
};

%% Default paths
loadConfigParameters
% COCO API path
addpath(sCocoMatlabApiFolder)
% Sort_nat path
addpath('../matlab_utilities') % printToc
addpath('../matlab_utilities/sort_nat')
% JSON ground truth folder
groundTruthDir = '../dataset/COCO/cocoapi/';
jsonFolder = '../training_results/';

%% select results type for demo (either bbox or segm)
type = {'segm','bbox','keypoints'}; type = type{3}; % specify type here
fprintf('Running demo for *%s* results.\n\n',type);

%% initialize COCO ground truth api
prefix='instances';
if(strcmp(type,'keypoints')), prefix='person_keypoints'; end

% Get average precision and recall best OP models
% Body
annFile=sprintf('%s/annotations/%s_%s.json',groundTruthDir,prefix,dataType);
cocoGt = CocoApi(annFile);
% Foot
% (Re)initialize COCO ground truth api
annFile=sprintf('%s/annotations/%s_%s%s.json',groundTruthDir,prefix,dataType, '_foot');
cocoGtFoot = CocoApi(annFile);
% Face
% (Re)initialize COCO ground truth api
annFile = sprintf('%s/annotations/%s.json',groundTruthDir,'frgc_val');
cocoGtFrgc = CocoApi(annFile);
annFile = sprintf('%s/annotations/%s.json',groundTruthDir,'multipie_val');
cocoGtMpie = CocoApi(annFile);
annFile = sprintf('%s/annotations/%s.json',groundTruthDir,'face_mask_out_val');
cocoGtFaceMask = CocoApi(annFile);
% Hand
% (Re)initialize COCO ground truth api
annFile = sprintf('%s/annotations/%s.json',groundTruthDir,'hand21_dome_val');
cocoGtHandDome = CocoApi(annFile);
annFile = sprintf('%s/annotations/%s.json',groundTruthDir,'hand42_mpii_val');
cocoGtHandMPII = CocoApi(annFile);

% % Car
% annFile=sprintf('%s/annotations/%s_%s%s.json',groundTruthDir,prefix,dataType, '_car');
% cocoGtCar = CocoApi(annFile);
annFile=sprintf('%s/annotations/%s.json',groundTruthDir,'processed_carfusion_val_cocoapi');
cocoGtCarCF = CocoApi(annFile);
annFile=sprintf('%s/annotations/%s.json',groundTruthDir,'processed_pascal3dplus_val_cocoapi');
cocoGtCarP3 = CocoApi(annFile);
annFile=sprintf('%s/annotations/%s.json',groundTruthDir,'processed_veri776_val_cocoapi');
cocoGtCarV7 = CocoApi(annFile);
% Top scores
avgPrecAndRecallOP1 = getPrecisionAndRecall({[jsonFolder, 'OP_1.json']}, cocoGt, type);
avgPrecAndRecallOP4 = getPrecisionAndRecall({[jsonFolder, 'OP_4.json']}, cocoGt, type);
avgPrecAndRecallOP1Foot = getPrecisionAndRecall({[jsonFolder, 'OP_1_foot.json']}, cocoGtFoot, type);
avgPrecAndRecallOP4Foot = getPrecisionAndRecall({[jsonFolder, 'OP_1_foot.json']}, cocoGtFoot, type);
% Face
avgPrecAndRecallOP1Frgc = getPrecisionAndRecall({[jsonFolder, 'OP_1_face_frgc.json']}, cocoGtFrgc, type);
avgPrecAndRecallOP1MPie = getPrecisionAndRecall({[jsonFolder, 'OP_1_face_mpie.json']}, cocoGtMpie, type);
avgPrecAndRecallOP1FaceMask = getPrecisionAndRecall({[jsonFolder, 'OP_1_face_mask.json']}, cocoGtFaceMask, type);
% Hand
avgPrecAndRecallOP1Hand21 = getPrecisionAndRecall({[jsonFolder, 'OP_1_hand21.json']}, cocoGtHandDome, type);
avgPrecAndRecallOP1Hand42 = getPrecisionAndRecall({[jsonFolder, 'OP_1_hand42.json']}, cocoGtHandMPII, type);

for modelIndex = 1:numel(modelSequences)
    modelString = modelSequences{modelIndex}{2};
    isCar = (sum(modelString(1:3) == 'car') == 3);
    modelSequence = modelSequences{modelIndex}{1};
    openPoseModel = modelSequences{modelIndex}{2};
    if ~isCar
        numberPlots = str2num(modelSequences{modelIndex}{3});
        subFolders = subFoldersPerson(1:numberPlots);
    else
        subFolders = subFoldersCar;
    end

    avgPrecAndRecall = cell(numel(subFolders), 1);
    numberFiles = zeros(numel(subFolders), 1);
    for subFolderId = 1:numel(subFolders)
        %% Get JSON files
        % JSONs folder and paths
        if ~isCar
            jsonsFolder = [jsonFolder, modelSequence, '/pose/', openPoseModel, '/', subFolders{subFolderId}];
        else
            jsonsFolder = [jsonFolder, modelSequence, '/car/', openPoseModel, '/', subFolders{subFolderId}];
        end
        jsonFilePaths = getFilesInFolder(jsonsFolder, 'json');
        % Reading files
        [resFiles,~] = sort_nat(jsonFilePaths); % Matlab sorted: a1, a20, a3. sort_nat: a1, a3, a20
        % Get at most maxSamples files
        if numel(resFiles) > maxSamples
            resFiles = resFiles(1:maxSamples);
        end

        %% Get average precision and recall
        % avgPrecAndRecall order:
        %    - 1. Body AP
        %    - 2. Body AR
        %    - 3. Foot AP
        %    - 4. Foot AR
        numberFiles(subFolderId) = numel(resFiles);
        % Body
        % avgPrecAndRecall = {AP_1}{AR_1}{AP_2}{AR_2}...
        if ~isCar
            % avgPrecAndRecall = {AP_b}{AR_b}{AP_f}{AR_f}
            if subFolderId < 3
                avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGt, type);
                avgPrecAndRecall{1}{subFolderId} = avgPrecAndRecallI{1};
                avgPrecAndRecall{2}{subFolderId} = avgPrecAndRecallI{2};
            % Foot
            elseif subFolderId < 5
                try
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtFoot, type);
                    avgPrecAndRecall{3}{subFolderId-2} = avgPrecAndRecallI{1};
                    avgPrecAndRecall{4}{subFolderId-2} = avgPrecAndRecallI{2};
                catch
                end
            % Face frgc
            elseif subFolderId < 7
                try
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtFrgc, type);
                    avgPrecAndRecall{5}{subFolderId-4} = avgPrecAndRecallI{1};
                    avgPrecAndRecall{6}{subFolderId-4} = avgPrecAndRecallI{2};
                catch
                end
            % Face MPie
            elseif subFolderId < 9
                try
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtMpie, type);
                    avgPrecAndRecall{7}{subFolderId-6} = avgPrecAndRecallI{1};
                    avgPrecAndRecall{8}{subFolderId-6} = avgPrecAndRecallI{2};
                catch
                end
            % Face mask out
            elseif subFolderId < 11
                try
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtFaceMask, type);
                    avgPrecAndRecall{9}{subFolderId-8} = avgPrecAndRecallI{1};
                    avgPrecAndRecall{10}{subFolderId-8} = avgPrecAndRecallI{2};
                catch
                end
            % Hand Dome
            elseif subFolderId < 13
                try
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtHandDome, type);
                    avgPrecAndRecall{11}{subFolderId-10} = avgPrecAndRecallI{1};
                    avgPrecAndRecall{12}{subFolderId-10} = avgPrecAndRecallI{2};
                catch
                end
            % Hand MPII
            elseif subFolderId < 15
                try
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtHandMPII, type);
                    avgPrecAndRecall{13}{subFolderId-12} = avgPrecAndRecallI{1};
                    avgPrecAndRecall{14}{subFolderId-12} = avgPrecAndRecallI{2};
                catch
                end
            end
        % Car
        else
            % avgPrecAndRecall = {AP_cf}{AR_cf}{AP_p3}{AR_p3}{AP_v7}{AR_v7}
            if numel(subFolders{subFolderId}) >= 7
                if norm(subFolders{subFolderId}(1:7)-'scaleCF') == 0
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtCarCF, type);
                elseif norm(subFolders{subFolderId}(1:7)-'scaleP3') == 0
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtCarP3, type);
                elseif norm(subFolders{subFolderId}(1:7)-'scaleV7') == 0
                    avgPrecAndRecallI = getPrecisionAndRecall(resFiles, cocoGtCarV7, type);
                else
                    assert(false, 'Unknown subFolderId');
                end
            end
            subIndex = 1*(subFolderId<4) + 2*(subFolderId>3);
            avgPrecAndRecall{2*(subFolderId-1)+1}{subIndex} = avgPrecAndRecallI{1};
            avgPrecAndRecall{2*(subFolderId-1)+2}{subIndex} = avgPrecAndRecallI{2};
        end
    end

    %% Plotting results
    xAxis = 2*(0:max(numberFiles));
    lineWidth = 3;
    figure(modelIndex),
    subplots = numel(avgPrecAndRecall);
    if ~isCar && subplots == 4 && numel(avgPrecAndRecall{3}{1}) == 0
        subplots = 2;
    end
    for plotIndex = 1:subplots
        currentAvgPrecAndRecall = avgPrecAndRecall{plotIndex};
        if numel(currentAvgPrecAndRecall) > 0 && numel(currentAvgPrecAndRecall{1}) > 0
            if subplots > 6
                subplot(subplots/2, 2, plotIndex),
            else
                subplot(subplots, 1, plotIndex),
            end
%             loglog(0,0) % To change to loglog plot
            hold on
            if mod(plotIndex, 2) == 1
                if plotIndex == 1
                    title([modelSequence, ' - Validation set accuracy'], 'Interpreter', 'none');
                end
                yLabelShort = 'AP';
            else
                yLabelShort = 'AR';
            end
                % Body
                if plotIndex == 1 || (mod(plotIndex, 2) == 1 && isCar)
                    yLabel = 'Average Precision';
                elseif plotIndex == 2 || (mod(plotIndex, 2) == 0 && isCar)
                    yLabel = 'Average Recall';
                % Foot
                elseif plotIndex == 3
                    yLabel = 'Foot AP';
                elseif plotIndex == 4
                    yLabel = 'Foot AR';
                % Face
                elseif plotIndex == 5
                    yLabel = 'FRGC AP';
                elseif plotIndex == 6
                    yLabel = 'FRGC AR';
                elseif plotIndex == 7
                    yLabel = 'MPIE AP';
                elseif plotIndex == 8
                    yLabel = 'MPIE AR';
                elseif plotIndex == 9
                    yLabel = 'FaceMask AP';
                elseif plotIndex == 10
                    yLabel = 'FaceMask AR';
                % Hand
                elseif plotIndex == 11
                    yLabel = 'HandDome AP';
                elseif plotIndex == 12
                    yLabel = 'HandMPII AR';
                end
            maxOPIndex = mod(plotIndex-1, 2)+1;
            if ~isCar
                % Body
                if plotIndex <= 2
                    avgMax1 = avgPrecAndRecallOP1{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP4{maxOPIndex};
                % Foot
                elseif plotIndex <= 4
                    avgMax1 = avgPrecAndRecallOP1Foot{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP4Foot{maxOPIndex};
                % Face
                elseif plotIndex <= 6
                    avgMax1 = avgPrecAndRecallOP1Frgc{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP1Frgc{maxOPIndex};
                elseif plotIndex <= 8
                    avgMax1 = avgPrecAndRecallOP1MPie{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP1MPie{maxOPIndex};
                elseif plotIndex <= 10
                    avgMax1 = avgPrecAndRecallOP1FaceMask{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP1FaceMask{maxOPIndex};
                % Hand
                elseif plotIndex <= 12
                    avgMax1 = avgPrecAndRecallOP1Hand21{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP1Hand21{maxOPIndex};
                elseif plotIndex <= 14
                    avgMax1 = avgPrecAndRecallOP1Hand42{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP1Hand42{maxOPIndex};
                % Unknown
                else
                    avgMax1 = avgPrecAndRecallOP1{maxOPIndex};
                    avgMax4 = avgPrecAndRecallOP4{maxOPIndex};
                end
                % Plot maximums
                plot([0, xAxis(end)], [avgMax1, avgMax1], 'LineWidth', lineWidth)
                plot([0, xAxis(end)], [avgMax4, avgMax4], 'LineWidth', lineWidth)
            else
                plot([0, xAxis(end)], [avgPrecAndRecallOP1{maxOPIndex}, avgPrecAndRecallOP1{maxOPIndex}], 'LineWidth', lineWidth)
                plot([0, xAxis(end)], [avgPrecAndRecallOP4{maxOPIndex}, avgPrecAndRecallOP4{maxOPIndex}], 'LineWidth', lineWidth)
            end
            for scaleIndex = 1:numel(currentAvgPrecAndRecall)
                xAxisI{scaleIndex} = 2*(0:numel(currentAvgPrecAndRecall{scaleIndex}));
                plot(xAxisI{scaleIndex}, [0; currentAvgPrecAndRecall{scaleIndex}], 'LineWidth', lineWidth)
                stem(xAxisI{scaleIndex}, [0; currentAvgPrecAndRecall{scaleIndex}], 'filled', 'LineStyle', 'None')
            end
            maximum = zeros(2,1);
            maxIndex = zeros(2,1);
            for scaleIndex = 1:numel(currentAvgPrecAndRecall)
                if numel(currentAvgPrecAndRecall{scaleIndex}) > 0
                    [maximum(scaleIndex), maxIndex(scaleIndex)] = max(   currentAvgPrecAndRecall{scaleIndex}   );
                end
            end
            maxIndex = maxIndex * (xAxisI{1}(2) - xAxisI{1}(1));
            for scaleIndex = 1:numel(currentAvgPrecAndRecall)
                stem(maxIndex, maximum, 'k', 'filled', 'LineStyle', 'None')
            end
            maxOP1 = max(avgMax1);
            maxOP4 = max(avgMax4);
            % https://www.mathworks.com/help/matlab/ref/legend.html
            location = 'southeast';
            if subplots >= 4
                location = 'bestoutside';%'best';
            end
            legend([yLabelShort, ' goal 1s(', num2str(maxOP1), ')'], ...
                   [yLabelShort, ' goal 4s(', num2str(maxOP4), ')'], ...
                   [yLabelShort, ' interpolated 1s'], ...
                   [yLabelShort, ' 1s(#', int2str(maxIndex(1)), ',', num2str(maximum(1)), ')'], ...
                   [yLabelShort, ' interpolated 4s'], ...
                   [yLabelShort, ' 4s(#', int2str(maxIndex(2)), ',', num2str(maximum(2)), ')'], ...
                   'Location', location)
            grid, hold off
            ylabel(yLabel)
        end
    end
    xlabel('10^3 Iterations')
end

%% Time measurement
printToc(toc);
