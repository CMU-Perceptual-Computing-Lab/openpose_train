%% Check which images are good or bad
close all; clear variables; clc;

% Time measurement
tic

% User-configurable parameters
loadConfigParameters

% User-configurable parameters
valFolder = [sBaseFootFolder, 'val2017/'];
% % Batch 1 (Validation)
% sDatasetFootFolder = [valFolder, '0_foot_for_clickworker/'];
% sOutputBatch1Folder = [valFolder, '1_output_clickworker/output/'];
% sBatch1CleanedFolder = [valFolder, '1_output_clickworker_cleaned/'];
% sBatch2Folder = [valFolder, '2_batch2/'];
% % Batch 2 (Validation)
% sDatasetFootFolder = [valFolder, '2_batch/'];
% sOutputBatch1Folder = [valFolder, '2_output_clickworker_batch/output/'];
% sBatch1CleanedFolder = [valFolder, '2_output_clickworker_batch_cleaned/'];
% sBatch2Folder = [valFolder, '3_batch3/'];
% % Batch 3 (Validation)
% sDatasetFootFolder = [valFolder, '3_batch/'];
% sOutputBatch1Folder = [valFolder, '3_output_clickworker_batch/output/'];
% sBatch1CleanedFolder = [valFolder, '3_output_clickworker_batch_cleaned/'];
% sBatch2Folder = [valFolder, '4_batch/'];

trainFolder = [sBaseFootFolder, 'train2017/'];
% % Batch 1 (Training)
% sDatasetFootFolder = [trainFolder, '0_foot_for_clickworker_subset1/'];
% sOutputBatch1Folder = [trainFolder, '1_output_clickworker_batch/output/'];
% sBatch1CleanedFolder = [trainFolder, '1_output_clickworker_batch_cleaned/'];
% sBatch2Folder = [trainFolder, '1_output_clickworker_wrong_ones/'];
% % Batch 2 (Training)
% sDatasetFootFolder = [trainFolder, '2_foot_for_clickworker_subset2/'];
% sOutputBatch1Folder = [trainFolder, '2_output_clickworker_batch/output/'];
% sBatch1CleanedFolder = [trainFolder, '2_output_clickworker_batch_cleaned/'];
% sBatch2Folder = [trainFolder, '2_output_clickworker_wrong_ones/'];
% % Batch 3 (Training)
% sDatasetFootFolder = [trainFolder, '3_foot_for_clickworker_subset3/'];
% sOutputBatch1Folder = [trainFolder, '3_output_clickworker_batch/output/'];
% sBatch1CleanedFolder = [trainFolder, '3_output_clickworker_batch_cleaned/'];
% sBatch2Folder = [trainFolder, '3_output_clickworker_wrong_ones/'];
% % Batch 4 (Training)
% sDatasetFootFolder = [trainFolder, '4_foot_for_clickworker_subset4/'];
% sOutputBatch1Folder = [trainFolder, '4_output_clickworker_batch/output/'];
% sBatch1CleanedFolder = [trainFolder, '4_output_clickworker_batch_cleaned/'];
% sBatch2Folder = [trainFolder, '4_output_clickworker_wrong_ones/'];

% val2Folder = [sBaseFootFolder, 'val2017_cleaned/'];
% % Batch 1 (Cleaned)
% sDatasetFootFolder = [val2Folder, '1_foot_for_clickworker_subset1/'];
% sOutputBatch1Folder = [val2Folder, '1_output_clickworker/output/'];
% % sOutputBatch1Folder = [val2Folder, '1_foot_for_clickworker_subset1/val2017/output/'];
% sBatch1CleanedFolder = [val2Folder, '2_output_clickworker_recleaned/'];
% sBatch2Folder = [val2Folder, '3_batch2/'];

% Batch (final)
val2Folder = [sBaseFootFolder, 'val2017_combined/'];
% Validationu
sDatasetFootFolder = [val2Folder, 'val2017/'];
sOutputBatch1Folder = [val2Folder, 'val2017/output/'];
% sOutputBatch1Folder = [val2Folder, '1_foot_for_clickworker_subset1/val2017/output/'];
sBatch1CleanedFolder = [sBaseFootFolder, 'val2017_final/'];
sBatch2Folder = [sBaseFootFolder, 'val2017_final_dirty/'];

% Choose one
sJsonFolder = [sDatasetFootFolder, 'json/'];
inputFolder = sBatch1CleanedFolder;
outputFolder = sBatch2Folder;
% Subplot style
subplotHorizonal = true;
% subplotHorizonal = false;
if subplotHorizonal
    spX = 1;
    spY = 3;
else
    spX = 3;
    spY = 1;
end

% Dependencies
addpath('../../matlab_utilities/'); % progressDisplay
addpath([sMatlabUtilitiesPath, 'sort_nat/']); % progressDisplay

% Create directories
mkdir(sBatch1CleanedFolder)
mkdir(outputFolder)

% Converting and saving validation and training JSON data into MAT format
fprintf('Checking images\n');
for mode = 0:0 % val2017
% for mode = 1:1 % train2017
% for mode = 2:2 % val2017_cleaned
% for mode = 3:3 % train2017_cleaned
    % Load COCO API with desired (validation vs. training) keypoint annotations
    if mode == 0
        dataType = 'val2017';
        dataTypeFull = dataType;
    elseif mode == 1
        dataType = 'train2017';
        dataTypeFull = dataType;
    elseif mode == 2
        dataType = 'val2017';
        dataTypeFull = [dataType, '_cleaned'];
    elseif mode == 3
        dataType = 'train2017';
        dataTypeFull = [dataType, '_cleaned'];
    else
        assert(false);
    end
    fprintf(['Checking ', dataTypeFull, '\n']);
    mkdir([inputFolder, dataTypeFull, '/annotated/'])
    mkdir([outputFolder, dataTypeFull, '/annotated/'])
    mkdir([inputFolder, dataTypeFull, '/json/'])
    mkdir([outputFolder, dataTypeFull, '/json/'])
    mkdir([inputFolder, dataTypeFull, '/original/'])
    mkdir([outputFolder, dataTypeFull, '/original/'])
    mkdir([inputFolder, dataTypeFull, '/output/'])
    mkdir([outputFolder, dataTypeFull, '/output/'])
    % Read all JSONs
    fprintf(['Reading image names from ', sOutputBatch1Folder, '...\n']);
    footJsonPaths = getFilesInFolder(sOutputBatch1Folder, 'json');
    [footJsonPaths, ~] = sort_nat(footJsonPaths); % Matlab sorted: a1, a20, a3. sort_nat: a1, a3, a20
    % Auxiliary parameters
    previousImageId = -1;
    imageCounter = 0;
    numberAnnotations = numel(footJsonPaths);
    logEveryXFrames = round(numberAnnotations / 50);
    % Initialize matAnnotations (no memory allocation)
    matAnnotations = [];
    % JSON to MAT format
    for footFileIndex = 1:numberAnnotations
        button = 1;
        while button == 1
            % Display progress
            progressDisplay(footFileIndex, logEveryXFrames, numberAnnotations);
            [~, footJsonName, ~] = fileparts(footJsonPaths{footFileIndex});
            annPath = ['annotated/', footJsonName, '.jpg'];
            targetOp1 = [inputFolder, dataTypeFull, '/'];
            targetOp2 = [outputFolder, dataTypeFull, '/'];
            if exist([targetOp1, annPath], 'file') || exist([targetOp2, annPath], 'file')
                button = -1;
            else
                % Read foot file
                jsonOpened = footJsonPaths{footFileIndex};
                fileID = fopen(jsonOpened, 'r');
                footJsonString = fscanf(fileID, '%s');
                fclose(fileID);
                % Json struct
                footJsonStruct = jsondecode(footJsonString);
                feet = reshape(footJsonStruct.keypoints, 3, [])';
% % PROVISIONAL CODE to find images with >6 keypoints
% if (numel(feet) == 3*6)
% break;
% end
% if (numel(feet) == 3*7 && sum(feet(7,:)) == -2)
% break;
% end
% feet
                % Add +1 (it is 0-based)
                feet(:,1) = feet(:,1) + 1;
                feet(:,2) = feet(:,2) + 1;
                % Image path
                imagePath = [sImagesFolder, dataType, '/', sprintf('%012d', footJsonStruct.image_id), '.jpg'];
                % Image
                image = imread(imagePath);

                % ImageId
                imageId = footJsonStruct.image_id;
                % ImageId vs. footJSON id
                if imageId == previousImageId
                    personCounter = personCounter + 1;
                else
                    personCounter = 1;
                    imageCounter = imageCounter + 1;
                    % Remember last image id
                    previousImageId = imageId;
                end

                % Keypoints
                keypoints = footJsonStruct.body_keypoints;

                % Visuale - Display image
                subplot(spX,spY,3), imshow(image)
                xlabel('Right: red (big), dark red (small), very dark red (heel)')
                title(['Annotation ', int2str(footFileIndex), '/', int2str(numberAnnotations)])
                for i = 1:2
                    subplot(spX,spY,i),
                    hold off, imshow(image), hold on
                    xlabel('Left: white (big), grey (small), dark (heel)')
                    % Visuale - Keypoints
                    keypointsReshaped = reshape(keypoints, 3, [])';
                    leftAnkle = keypointsReshaped(16,1:2);
                    rightAnkle = keypointsReshaped(17,1:2);
                    keypointsReshaped(keypointsReshaped(:,3) < 0.5, :) = [];
                    centers = keypointsReshaped(:,1:2);
                    viscircles(centers, 3*ones(size(centers,1), 1), 'LineWidth',5,'Color','b');
                    viscircles(leftAnkle, 3, 'LineWidth',5,'Color','g');
                    viscircles(rightAnkle, 3, 'LineWidth',5,'Color','r');
                    % Foot
                    colors = {[1 1 1],[0.5 0.5 0.5],[0.25 0.25 0.25],[1 0 0],[0.4 0 0],[0.15 0 0],[0 1 0],[0 1 0],[0 1 0]};
                    centers = feet(:,1:2);
                    for c = 1:size(centers,1)
                        center = centers(c,:);
                        if sum(center < 1) == 0
                          viscircles(center, 5*ones(size(center,1), 1),'Color',colors{mod(c-1,numel(colors))+1}, 'LineWidth',2);
                          viscircles(center, 1*ones(size(center,1), 1),'Color',colors{mod(c-1,numel(colors))+1}, 'LineWidth',1);
                        end
                    end
                end
                % Max-min rectangle
                subplot(spX,spY,2),
                title('g = good     b = bad     click = reload')
                subplot(spX,spY,1),
                title(footJsonName)
                feetCleaned = feet;
                feetCleaned(feetCleaned(:,2) == 0, :) = [];
                minX = min(feetCleaned(:,1)) - 10;
                maxX = max(feetCleaned(:,1)) + 10;
                minY = min(feetCleaned(:,2)) - 10;
                maxY = max(feetCleaned(:,2)) + 10;
                axis([minX, maxX, minY, maxY])
                % Mouse click
                button = [];
% Auto accept images with 6 keypoints and with right-left keypoints right
% button = 'g' if #keypoints = 6 && dist(LKeypoints, LAnkle) < dist(LKeypoints, RAnkle) && dist(RKeypoints, RAnkle) < dist(RKeypoints, LAnkle)
autoAcceptRejectMode = false;
if autoAcceptRejectMode
    try
        allKeypoints = sum(feetCleaned(:, 3) == 2) == 6;
        keypointsAll = reshape(footJsonStruct.body_keypoints, 3, [])';
        leftAnkle = keypointsAll(16,1:2);
        rightAnkle = keypointsAll(17,1:2);
        distLL = sum(sqrt(sum((feetCleaned(1:3, 1:2) - leftAnkle).^2, 2)));
        distLR = sum(sqrt(sum((feetCleaned(1:3, 1:2) - rightAnkle).^2, 2)));
        distRL = sum(sqrt(sum((feetCleaned(4:6, 1:2) - leftAnkle).^2, 2)));
        distRR = sum(sqrt(sum((feetCleaned(4:6, 1:2) - rightAnkle).^2, 2)));
        if allKeypoints && distLL+distRR < distLR+distRL
            button = 'g';
            isRight = true;
        else
            button = 99;
        end
    catch
        button = [];
        button = 99;
    end
end
%                 if size(centers,1) > 6
%                     isRight = false
%                 else
                    while numel(button) == 0
                        [x, y, button] = ginput(1); % [x_mouse, y_mouse, button (mouse or keyboard)]
                        xy = [round([x,y] - 1), 2]; % xy is 0-based
                        clear x, y;
                        if button == 'g' % Left click / g
                            isRight = true;
                        elseif button == 'b' % Right click / b
                            isRight = false;
                        elseif button == 27 % Exit
                            close all;
                            display(' ')
                            display('Program closed!')
                            return;
                        elseif button == 1 % Repeat
                            disp(xy)
                            break;
                        elseif button == 3 % Repeat
                            button = 1;
                            [status, cmdout] = system(['subl ', jsonOpened, ' &'],'-echo');
                            assert(status == 0, cmdout);
                            disp(' '), disp(' '), disp(' ')
                            disp(xy)
                            break;
                        elseif button == 99 % Skip sample
                            break;
                        elseif numel(button) > 0 % Any other, e.g. Esc (27)
                            assert(false, ['Wrong button (', int2str(button), ') clicked'])
                        end
                    end
                    if button == 1 % Repeat
                        continue;
                    end
%                 end

                % Save cleaned file
                if button ~= 99
                    if isRight
                        targetFolder = targetOp1;
                    else
                        targetFolder = targetOp2;
                    end
%                     sourceFolder = [sDatasetFootFolder, dataType, '/'];
                    sourceFolder = [sDatasetFootFolder, '/'];
                    jsonPath = ['json/', footJsonName, '.json'];
                    oriPath = ['original/', footJsonName(1:12), '.jpg'];
                    outputJsonPath = [footJsonName, '.json'];
                    % Copy files
                    [status, msg] = copyfile([sourceFolder, annPath], [targetFolder, annPath]);
                    assert(status == 1, msg);
                    [status, msg] = copyfile([sourceFolder, jsonPath], [targetFolder, jsonPath]);
                    assert(status == 1, msg);
                    [status, msg] = copyfile([sourceFolder, oriPath], [targetFolder, oriPath]);
                    assert(status == 1, msg);
                    [status, msg] = copyfile([sOutputBatch1Folder, outputJsonPath], [targetFolder, 'output/', outputJsonPath]);
                    assert(status == 1, msg);
                end
            end
        end
    end
    fprintf(['\nFinished converting ', dataTypeFull, '!\n\n']);
    close all
end

% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
