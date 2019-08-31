%% Generate COCO masks and segmentation
% Not all COCO images are completely labeled. These masks will tell the
% algorithm which body parts are not labeled, so it does not wrongly uses
% them to generate the brackground heat maps
close all; clear variables; clc

% Time measurement
tic

% Note:
% By default, this code uses the 'parfor' loop in order to speed up the code.
% You can manually disable it.

% Useful information
% Number total masks at the end should be:
% (#imagesWithPeopleTrain2017 + #imagesWithPeopleVal2017) * 2 (a maskAll & maskMiss per image)
% I.e.
% numberMasksOnMask2017 = (numel(coco_kpt) + numel(coco_val)) * 2

% User-configurable parameters
loadConfigParameters
debugVisualize = false; % Debugging: enable to plot images with mask overlapped
disableWarnings = true;

% Load auxiliary functions
addpath('../matlab_utilities/'); % progressBarInit, progressBarUpdate, blendMask, progressDisplay

% Create directories to save generated masks/segmentations
mkdir(sImageMaskFolder)
mkdir(sSegmentationFolder)

% Start parpool if not started
startParallel(disableWarnings);

for mode = 1 % Body
% for mode = 2:4 % Car22
% for mode = 6:-1:5 % For hand21, hand42
% for mode = 7 % For face70
    % Add COCO Matlab API folder (in order to use its API)
    addpath(sCocoMatlabApiFolder);
    % Body pose
    if mode == 1
        load([sMatFolder, 'coco_kpt.mat']);
        dataType = 'train2017';
        imageMaskFolder = [sImageMaskFolder, dataType, '/'];
        imageSegmentationFolder = [sSegmentationFolder, dataType, '/'];
        matAnnotations = coco_kpt;
    % Car22
    elseif mode >= 2 && mode <= 4
        if mode == 2
            dataType = 'car-fusion';
            load([sMatFolder, 'car22_carfusion.mat']);
        elseif mode == 3
            dataType = 'pascal3d+';
            load([sMatFolder, 'car22_pascal3dplus.mat']);
        elseif mode == 4
            dataType = 'veri-776';
            load([sMatFolder, 'car22_veri776.mat']);
        end
        imageMaskFolder = [sImageMaskFolder, dataType, '/'];
        imageSegmentationFolder = [sSegmentationFolder, dataType, '/'];
        matAnnotations = car_kpt;
    % Hand21, Hand42
    elseif mode >= 5 && mode <= 6
        % Dome
        if mode == 5
            subDataType = 'dome';
            sNumberKeyPoints = 21;
        % MPII
        elseif mode == 6
            subDataType = 'mpii';
            sNumberKeyPoints = 42;
        end
        dataType = ['hand', int2str(sNumberKeyPoints)];
        baseName = [dataType, '_', subDataType];
        load([sMatFolder, baseName, '.mat']);
        opt.FileName = [sJsonFolder, baseName, '.json'];
        matAnnotations = coco_kpt;
        imageMaskFolder = [sImageMaskFolder, dataType, '/'];
        imageSegmentationFolder = [sSegmentationFolder, dataType, '/'];
    % Face
    elseif mode == 7
        subDataType = 'face_mask_out_train';
        sNumberKeyPoints = 70;
        dataType = ['face', int2str(sNumberKeyPoints)];
        baseName = [dataType, '_', subDataType];
        load([sMatFolder, baseName, '.mat']);
        opt.FileName = [sJsonFolder, baseName, '.json'];
        matAnnotations = coco_kpt;
        imageMaskFolder = [sImageMaskFolder, subDataType, '/'];
        imageSegmentationFolder = [sSegmentationFolder, subDataType, '/'];
    else
        assert(false, 'Unknown mode.');
    end
    disp(['Running ', dataType])

    % Create directory to save generated masks
    mkdir(imageMaskFolder)

    numberImagesWithPeople = length(matAnnotations);
    % Display progress bar
    progressBarInit();
    % Enable parfor to speed up the code
    parfor imageIndex = 1:numberImagesWithPeople
%     for imageIndex = 1:numberImagesWithPeople
        % Update progress bar
        progressBarUpdate(imageIndex, numberImagesWithPeople);
        % Paths
        if mode == 1
            imagePath = sprintf([dataType, '/%012d.jpg'], matAnnotations(imageIndex).image_id);
            maskMissPath = sprintf([imageMaskFolder, '%012d.png'], matAnnotations(imageIndex).image_id);
            segmentationPath = sprintf([imageSegmentationFolder, '%012d.png'], matAnnotations(imageIndex).image_id);
        % Car22
        elseif mode >= 2 && mode <= 4
            imagePath = sprintf([dataType, '/%s'], matAnnotations(imageIndex).image_path);
            [~, fileName, ~] = fileparts(matAnnotations(imageIndex).image_path);
            maskMissPath = sprintf([imageMaskFolder, '%s.png'], fileName);
            segmentationPath = sprintf([imageSegmentationFolder, '%s.png'], fileName);
        % Face70
        elseif mode == 7
            imagePath = ['/media/posefs3b/Users/gines/Datasets/face/tomas_ready/face_mask_out_train/', ...
                matAnnotations(imageIndex).image_path];
            [~, fileName, ~] = fileparts(matAnnotations(imageIndex).image_path);
            maskMissPath = sprintf([imageMaskFolder, '%s.png'], fileName);
            segmentationPath = sprintf([imageSegmentationFolder, '%s.png'], fileName);
        % Hand21, Hand42
        elseif mode >= 5 && mode <= 6
            if mode == 5
                imagePath = ['/media/posefs3b/Users/gines/openpose_train/dataset/hand/hand143_panopticdb/imgs/', ...
                    matAnnotations(imageIndex).image_path];
            elseif mode == 6
                imagePath = ['/media/posefs3b/Users/gines/openpose_train/dataset/hand/hand_labels_v2/manual_train_v2/', ...
                    matAnnotations(imageIndex).image_path];
            else
                assert(false, 'Not expected value. Check this.');
            end
            [~, fileName, ~] = fileparts(matAnnotations(imageIndex).image_path);
            maskMissPath = sprintf([imageMaskFolder, '%s.png'], fileName);
            segmentationPath = sprintf([imageSegmentationFolder, '%s.png'], fileName);
        % Unknown
        else
            assert(false, 'Unknown mode.');
        end
        % If files exist -> skip (so it can be resumed if cancelled)
        maskNotGenerated = true;
        try
            % Note: it takes ~3 msec to check both images exist, but ~25
            % msec to load the images. If the exist() command is removed,
            % it would speed up when images are present, but it would
            % considerably slow down when no images are present (e.g., 1st
            % run).
            % Note2: We only check the one generated last (i.e., the mask)
            if exist(maskMissPath, 'file')
                % Masks exist, but confirm it was successfully generated
                imread(maskMissPath);
                maskNotGenerated = false;
            end
        catch
            maskNotGenerated = true;
        end
        % Generate and write masks
        if maskNotGenerated
            % Generate masks
            % Paths
            if mode == 1
                image = imread([sImageFolder, imagePath]);
                minScale = 0.3;
            % Car22
            elseif mode >= 2 && mode <= 4
                image = imread(['/media/posefs4b/User/hidrees/VehiclePoseEstimation/', imagePath]);
                minScale = 0.3;
            % Face70
            elseif mode == 7
                image = imread(imagePath);
                minScale = 0.2;
            % Hand21, Hand42
            elseif mode >= 5 && mode <= 6
                image = imread(imagePath);
                minScale = 0.2;
            % Unknown
            else
                assert(false, 'Unknown mode.');
            end
            [h, w, ~] = size(image);
            segmentationAll = false(h, w);
            maskMiss = false(h, w);
            maskCrowd = false(h, w);
            peopleOnImageI = length(matAnnotations(imageIndex).annorect);
            % If image i is not completely segmented for all people
            try
                % Fill maskAll and maskMiss from each person on image i
                for p = 1:peopleOnImageI
                    % Get person individual mask
                    segmentation = matAnnotations(imageIndex).annorect(p).segmentation{1};
                    [X,Y] = meshgrid( 1:w, 1:h );
                    % Apply mask over convex hull
                    xPoints = segmentation(1:2:end);
                    yPoints = segmentation(2:2:end);
                    % Hands and Face
                    if mode >= 5 && mode <= 7
                        % Error happen when e.g. segmentation = 640,308,640,308,640,308,640,308
                        try
                            convexHullId = convhull(xPoints, yPoints);
                        catch
                            convexHullId = 1:numel(xPoints);
                        end
                        xPoints = xPoints(convexHullId);
                        yPoints = yPoints(convexHullId);
                        % Increase mask area
                        minX = min(xPoints);
                        maxX = max(xPoints);
                        minY = min(yPoints);
                        maxY = max(yPoints);
                        middleX = (maxX+minX)/2;
                        middleY = (maxY+minY)/2;
                        directionX = xPoints - middleX;
                        directionY = yPoints - middleY;
                        norms = sqrt(directionX.*directionX + directionY.*directionY);
                        finalNorm = max([0.05*(maxX-minX), 0.05*(maxY-minY), 20*w/1920, 20*h/1080]);
                        % Based on image size
                        widthRatio = (mode == 1)*20 + (mode ~= 1)*30; % We assume COCO is really good segmentation and the rest are not
                        finalNorm = widthRatio*max([w/656.0, h/368.0]);
                        % Based on person size
                        widthRatio = (mode == 1)*25 + (mode ~= 1)*35; % We assume COCO is really good segmentation and the rest are not
                        finalNorm = max(finalNorm, widthRatio/368*max([maxX-minX, maxY-minY]));
                        % Based on minimum scale when training (or it will fail when shrinking the image)
                        finalNorm = finalNorm / (minScale*0.9);
                        directionX = directionX .* (finalNorm./norms);
                        directionY = directionY .* (finalNorm./norms);
                        % Get maskPersonP
                        segmentationPersonP = inpolygon(X, Y, xPoints+directionX, yPoints+directionY); % Bigger mask code
                    % Body, car
                    else
                        segmentationPersonP = inpolygon(X, Y, xPoints, yPoints); % Original code
                    end
                    % Fill mask all
                    segmentationAll = or(segmentationPersonP, segmentationAll);
                    % If not annotations, fill mask miss
                    if matAnnotations(imageIndex).annorect(p).num_keypoints <= 0
                        maskMiss = or(segmentationPersonP, maskMiss);
                    end
                end
                maskMiss = not(maskMiss);
            % If image i is not completely segmented for all people
            catch
                assert(p == peopleOnImageI, 'p should be the last element if no annotations are found!');
                maskNoAnnotations = logical(MaskApi.decode(matAnnotations(imageIndex).annorect(p).segmentation));
                maskCrowd = maskNoAnnotations - and(segmentationAll, maskNoAnnotations);
                maskMiss = not(or(maskMiss, maskCrowd));
            end
            segmentationAllAndCrowd = or(segmentationAll, maskCrowd);
            % Write masks
            % First write segmentation in case of stop & resume
            % No segmentation for face & hands
            if mode < 5 || mode > 7
                imwrite(segmentationAllAndCrowd, segmentationPath);
            end
            imwrite(maskMiss, maskMissPath);
            % Visualize masks (debugging purposes)
            if debugVisualize == 1
%             if true == 1
%             if sum(maskMiss(:)) < w*h
                [~, fileName, ~] = fileparts(imagePath);
                titleBase = [fileName, ' - '];
                % segmentationAllAndCrowd
                figure(1), blendMask(image, segmentationAllAndCrowd, [titleBase, 'segmentationAllAndCrowd']);
                % segmentationAll
                figure(2), blendMask(image, segmentationAll, [titleBase, 'segmentationAll']);
                % maskMiss
                figure(3), blendMask(image, maskMiss, [titleBase, 'maskMiss']);
                % maskCrowd
                figure(4), blendMask(image, maskCrowd, [titleBase, 'maskCrowd']);
                if exist('maskNoAnnotations', 'var')
                    % maskCrowd
                    figure(5), blendMask(image, maskNoAnnotations, [titleBase, 'no annotations mask']);
                    clear maskNoAnnotations
                end
                % Pause
                pause;
            end
        end
    end
end

if disableWarnings
    warning ('on','all');
end

% Total running time
disp(['Total time a2_matToMasks.m: ', int2str(round(toc)), ' seconds.']);
