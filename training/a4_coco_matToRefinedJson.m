%% a4_matToRefinedJson
% This script creates a cleaner JSON than the original one
% E.g. it removes people too small and/or with very few body parts visible
close all; clear variables; clc


% Time measurement
tic

% User-configurable parameters
loadConfigParameters
debugVisualize = 0;

% COCO vs. foot
modes = 0; % For COCO
% modes = 1; % For foot (2014)
% modes = 2; % For foot (2017)
% modes = 3; % For car14_v1
% modes = 4:6; % For car22
% modes = 7:9; % For face70
% modes = 10:11; % For hand21, hand42
% modes = 12; % Dome135

% Add testing paths
addpath('../matlab_utilities/'); % progressDisplay
addpath('../matlab_utilities/jsonlab/');

mkdir([sDatasetFolder, 'json'])

for mode = modes
    % Load COCO API with desired (COCO vs. foot) keypoint annotations
    % COCO body
    if mode == 0
        dataType = 'train2017';
        load([sMatFolder, 'coco_kpt.mat']);
        matAnnotations = coco_kpt;
        opt.FileName = [sJsonFolder, 'COCO.json'];
    % Foot 2014
    elseif mode == 1
        sNumberKeyPoints = 21;
        dataType = 'train2014';
        load([sMatFolder, 'foot.mat']);
        matAnnotations = foot;
        opt.FileName = [sJsonFolder, 'foot_coco2014.json'];
    % Foot 2017
    elseif mode == 2
        sNumberKeyPoints = 23;
        dataType = 'train2017';
        load([sMatFolder, 'coco_kpt_foot.mat']);
        matAnnotations = coco_kpt;
        opt.FileName = [sJsonFolder, 'coco2017_foot.json'];
%         dataType = 'val2017';
%         load([sMatFolder, 'coco2017_val_foot.mat']);
%         matAnnotations = coco_val;
%         opt.FileName = [sJsonFolder, 'coco2017_val_foot.json'];
    % car14_v1
    elseif mode == 3
        sNumberKeyPoints = 14;
        dataType = 'car14_v1';
        load([sMatFolder, 'car14_v1.mat']);
        matAnnotations = car14_v1;
        opt.FileName = [sJsonFolder, 'car14_v1.json'];
    % car22
    elseif mode >= 4 && mode <= 6
        sNumberKeyPoints = 22;
        dataType = 'car22';
        if mode == 4
            load([sMatFolder, 'car22_carfusion.mat']);
            opt.FileName = [sJsonFolder, 'car22_carfusion.json'];
        elseif mode == 5
            load([sMatFolder, 'car22_pascal3dplus.mat']);
            opt.FileName = [sJsonFolder, 'car22_pascal3dplus.json'];
        elseif mode == 6
            load([sMatFolder, 'car22_veri776.mat']);
            opt.FileName = [sJsonFolder, 'car22_veri776.json'];
        end
        matAnnotations = car_kpt;
    % Face70
    elseif (mode >= 7 && mode <= 9)
        % frgc
        if mode == 7
            load([sMatFolder, 'face70_frgc_train.mat']);
            opt.FileName = [sJsonFolder, 'face70_frgc.json'];
        % multipie
        elseif mode == 8
            load([sMatFolder, 'face70_multipie_train.mat']);
            opt.FileName = [sJsonFolder, 'face70_multipie.json'];
        % face_mask_out
        elseif mode == 9
            load([sMatFolder, 'face70_face_mask_out_train.mat']);
            opt.FileName = [sJsonFolder, 'face70_mask_out.json'];
        end
        sNumberKeyPoints = 70;
        dataType = 'face70';
        matAnnotations = coco_kpt;
    % Hand21, Hand42
    elseif (mode >= 10 && mode <= 11)
        % Dome
        if mode == 10
            subDataType = 'dome';
            sNumberKeyPoints = 21;
        % MPII
        elseif mode == 11
            subDataType = 'mpii';
            sNumberKeyPoints = 42;
        end
        dataType = ['hand', int2str(sNumberKeyPoints)];
        baseName = [dataType, '_', subDataType];
        load([sMatFolder, baseName, '.mat']);
        opt.FileName = [sJsonFolder, baseName, '.json'];
        matAnnotations = coco_kpt;
    % Dome135
    elseif mode == 12
        dataType = 'dome135';
        sNumberKeyPoints = 135;
        load([sMatFolder, dataType, '.mat']);
        opt.FileName = [sJsonFolder, dataType, '.json'];
        matAnnotations = coco_kpt;
    % Unknown
    else
        assert(false, 'Unknown mode.');
    end
    fprintf(['Converting ', dataType, '\n']);

    numberAnnotations = numel(matAnnotations);
    logEveryXFrames = round(numberAnnotations / 40);
    % Process each image with people
    counter = 0;
    jointAll = [];
    for imageIndex = 1:numberAnnotations
        % Display progress
        progressDisplay(imageIndex, logEveryXFrames, numberAnnotations);
        % Save
        previousCenters = [];
        % Image width & height
        w = matAnnotations(imageIndex).annorect.img_width;
        h = matAnnotations(imageIndex).annorect.img_height;
        % Process each person on the image
        numerPeople = length(matAnnotations(imageIndex).annorect);
        for person = 1:numerPeople
            % Skip person if number parts is too low or segmentation area  too small
            if matAnnotations(imageIndex).annorect(person).num_keypoints >= 5 && matAnnotations(imageIndex).annorect(person).area >= 32*32
                % Skip person if distance to exiting person is too small
                personCenter = [matAnnotations(imageIndex).annorect(person).bbox(1) + matAnnotations(imageIndex).annorect(person).bbox(3) / 2, ...
                                matAnnotations(imageIndex).annorect(person).bbox(2) + matAnnotations(imageIndex).annorect(person).bbox(4) / 2];
                addPerson = true;
                for k = 1:size(previousCenters, 1)
                    dist = norm(previousCenters(k, 1:2) - personCenter);
                    if dist < previousCenters(k, 3) * 0.3
                        addPerson = false;
                        break;
                    end
                end
                % Add person
                if addPerson
                    % Keypoints
                    keypoints = reshapeKeypoints(matAnnotations(imageIndex).annorect(person).keypoints, sNumberKeyPoints);
                    % Security checks
                    assert(numel(keypoints)/3 == sNumberKeyPoints)
                    % Less than 2 annotated keypoints -> Skip
                    if mode == 2
                        labeledKeypoints = 6 - sum(keypoints(end-5:end, 3) == 2);
                        if labeledKeypoints < 2
                            continue;
                        end
                    end
                    % Increase counter
                    counter = counter + 1;
                    % Fill new person
                    % car14_v1
                    if mode == 3
                        jointAll(counter).dataset = 'car14';
                    % car22
                    elseif mode >= 4 && mode <= 6
                        jointAll(counter).dataset = 'car22';
                    % Body and/or foot
                    else
                        jointAll(counter).dataset = 'COCO';
                    end
                    if (mode == 0 || mode == 2)
                        jointAll(counter).img_paths = sprintf('%012d.jpg', matAnnotations(imageIndex).image_id);
                    elseif mode == 1
                        jointAll(counter).img_paths = sprintf([dataType, '/COCO_', dataType, '_%012d.jpg'], matAnnotations(imageIndex).image_id);
                    % Car14
                    elseif mode == 3
                        % Image id
                        imageIdString = sprintf('%07d', int64(matAnnotations(imageIndex).image_id));
                        imageIdString = [imageIdString(1:2), '_', imageIdString(3:end)];
                        if imageIdString(1) == '0'
                            imageIdString = imageIdString(2:end);
                        end
                        % img_paths
                        jointAll(counter).img_paths = ['images_jpg/', imageIdString, '.jpg'];
                    % Car22
                    elseif mode >= 4 && mode <= 6
                        % Image id
                        imageIdString = sprintf('%07d', int64(matAnnotations(imageIndex).image_id));
                        imageIdString = [imageIdString(1:2), '_', imageIdString(3:end)];
                        if imageIdString(1) == '0'
                            imageIdString = imageIdString(2:end);
                        end
                        % img_paths
                        jointAll(counter).img_paths = matAnnotations(imageIndex).image_path;
                    % Face70, Hand21, Hand42, Dome135
                    elseif (mode >= 7 && mode <= 12)
                        jointAll(counter).image_path = matAnnotations(imageIndex).image_path;
                        if mode == 7
                            jointAll(counter).dataset = 'face70_frgc';
                        elseif mode == 8
                            jointAll(counter).dataset = 'face70_multipie';
                        elseif mode == 9
                            jointAll(counter).dataset = 'face70_mask_out';
                        % Hand21
                        elseif mode == 10
                            jointAll(counter).dataset = 'hand21_dome';
                        % Hand42
                        elseif mode == 11
                            jointAll(counter).dataset = 'hand42_mpii';
                        % Dome135
                        elseif mode == 12
                            jointAll(counter).dataset = 'dome135';
                        end
                    % Unknown
                    else
                        assert(false, 'Unknown mode.');
                    end
                    jointAll(counter).img_width = w;
                    jointAll(counter).img_height = h;
                    jointAll(counter).objpos = personCenter;
                    jointAll(counter).image_id = matAnnotations(imageIndex).image_id;
                    jointAll(counter).bbox = matAnnotations(imageIndex).annorect(person).bbox;
                    jointAll(counter).segment_area = matAnnotations(imageIndex).annorect(person).area;
                    jointAll(counter).num_keypoints = matAnnotations(imageIndex).annorect(person).num_keypoints;
                    % Reshape keypoints from [1, (sNumberKeyPoints*3)] to [sNumberKeyPoints, 3]
                    jointAll(counter).joint_self = keypoints;
                    % Set scale
                    jointAll(counter).scale_provided = matAnnotations(imageIndex).annorect(person).bbox(4) / sImageScale;
                    % Add all other people on the same image
                    counterOther = 0;
                    jointAll(counter).joint_others = cell(0,0);
                    for otherPerson = 1:numerPeople
                        % If other person is not original person and it has >= 1 annotated keypoints
                        if otherPerson ~= person && matAnnotations(imageIndex).annorect(otherPerson).num_keypoints > 0
                            % Increase counter
                            counterOther = counterOther + 1;
                            % Fill person
                            jointAll(counter).scale_provided_other(counterOther) = matAnnotations(imageIndex).annorect(otherPerson).bbox(4) / sImageScale;
                            jointAll(counter).objpos_other{counterOther} = [...
                                matAnnotations(imageIndex).annorect(otherPerson).bbox(1) + matAnnotations(imageIndex).annorect(otherPerson).bbox(3)/2, ...
                                matAnnotations(imageIndex).annorect(otherPerson).bbox(2) + matAnnotations(imageIndex).annorect(otherPerson).bbox(4)/2 ...
                            ];
                            jointAll(counter).bbox_other{counterOther} = matAnnotations(imageIndex).annorect(otherPerson).bbox;
                            jointAll(counter).segment_area_other(counterOther) = matAnnotations(imageIndex).annorect(otherPerson).area;
                            jointAll(counter).num_keypoints_other(counterOther) = matAnnotations(imageIndex).annorect(otherPerson).num_keypoints;
                            % Reshape keypoints from [1, (sNumberKeyPoints*3)] to [sNumberKeyPoints, 3]
                            jointAll(counter).joint_others{counterOther} = reshapeKeypoints(matAnnotations(imageIndex).annorect(otherPerson).keypoints, sNumberKeyPoints);
                            % Security checks
                            assert(numel(jointAll(counter).joint_others{counterOther})/3 == sNumberKeyPoints)
                        end
                    end
                    jointAll(counter).annolist_index = imageIndex;
                    jointAll(counter).people_index = person;
                    jointAll(counter).numOtherPeople = length(jointAll(counter).joint_others);
                    % Update previous centers
                    previousCenters = [previousCenters; ...
                                       jointAll(counter).objpos, ...
                                       max(matAnnotations(imageIndex).annorect(person).bbox(3), ...
                                       matAnnotations(imageIndex).annorect(person).bbox(4))];
                    % Visualize result (debugging purposes)
                    if debugVisualize
                        try
                            imshow([sDatasetFolder, 'images/', jointAll(counter).img_paths]);
                        catch
                            if mode == 10
                                imshow([sDatasetBaseFolder, 'hand/hand143_panopticdb/imgs/', jointAll(counter).image_path]);
                            elseif mode == 11
                                imshow([sDatasetBaseFolder, 'hand/hand_labels/manual_train/', jointAll(counter).image_path]);
                            elseif mode == 12
                                imshow(['/media/posefs0c/panopticdb/a4/hdImgs/', jointAll(counter).image_path]);
                            else
                                assert(false, 'Not expected value. Check this.');
                            end
                        end
                        xlim(jointAll(counter).img_width * [-0.6, 1.6]);
                        ylim(jointAll(counter).img_height * [-0.6, 1.6]);
                        hold on;
                        visiblePart = jointAll(counter).joint_self(:,3) == 1;
                        invisiblePart = jointAll(counter).joint_self(:,3) == 0;
                        % Keypoints
                        plot(jointAll(counter).joint_self(visiblePart, 1), jointAll(counter).joint_self(visiblePart,2), 'gx');
                        % BBox
                        rectangle('Position',jointAll(counter).bbox, 'LineWidth',3)
                        % Rest
                        plot(jointAll(counter).joint_self(invisiblePart,1), jointAll(counter).joint_self(invisiblePart,2), 'rx');
                        plot(jointAll(counter).objpos(1), jointAll(counter).objpos(2), 'cs');
                        if ~isempty(jointAll(counter).joint_others)
                            for otherPerson = 1:size(jointAll(counter).joint_others,2)
                                visiblePart = jointAll(counter).joint_others{otherPerson}(:,3) == 1;
                                invisiblePart = jointAll(counter).joint_others{otherPerson}(:,3) == 0;
                                plot(jointAll(counter).joint_others{otherPerson}(visiblePart,1), jointAll(counter).joint_others{otherPerson}(visiblePart,2), 'mx');
                                plot(jointAll(counter).joint_others{otherPerson}(invisiblePart,1), jointAll(counter).joint_others{otherPerson}(invisiblePart,2), 'cx');
                                plot(jointAll(counter).objpos_other{otherPerson}(1), jointAll(counter).objpos_other{otherPerson}(2), 'cs');
                            end
                        end
                        rectSize = 2.1 * sqrt(jointAll(counter).scale_provided) / 1.2;
%                         max(matAnnotations(i).annorect(person).bbox(3), matAnnotations(i).annorect(person).bbox(4))
%                         sqrt(joint_all(count).scale_provided)
                        rectangle('Position',[jointAll(counter).objpos(1)-rectSize, ...
                                              jointAll(counter).objpos(2)-rectSize, ...
                                              2*rectSize, ...
                                              2*rectSize], ...
                                  'EdgeColor','b')
                        pause;
%                         pause(0.01);
                    end
                end
            end
        end
    end
    fprintf('\nFinished!\n\n');

    % Save JSON file
    opt.FloatFormat = '%.3f';
    fprintf(['Saving JSON: ', opt.FileName, ...
             '\nNote: It might take several minutes or even a few hours...\n']);
    savejson('root', jointAll, opt);
    fprintf('\nFinished!\n\n');
end

% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);

function [reshapedKeypoints] = reshapeKeypoints(keypoints, sNumberKeyPoints)
    % Reshape keypoints from [1, (sNumberKeyPoints*3)] to [sNumberKeyPoints, 3]
    % In COCO (sNumberKeyPoints = 17):
    %    (1-'nose'	2-'left_eye' 3-'right_eye' 4-'left_ear' 5-'right_ear'
    %    6-'left_shoulder' 7-'right_shoulder'	8-'left_elbow' 9-'right_elbow' 10-'left_wrist'	
    %    11-'right_wrist'	12-'left_hip' 13-'right_hip' 14-'left_knee'	15-'right_knee'	
    %    16-'left_ankle' 17-'right_ankle')
    % COCO:
        % 0 = not labeled
        % 1 = ocluded but labeled
        % 2 = visible and labeled
        % 3 (added by us) = not in that dataset
    % OP:
        % 0 = ocluded but labeled
        % 1 = visible and labeled
        % 2 = not labeled
        % 3 = [training code dependant]
        % 4 (added by us) = not in that dataset
    reshapedKeypoints = reshape(keypoints, [], sNumberKeyPoints)';
    non3Indexes = reshapedKeypoints(:,3) < 3;
    reshapedKeypoints(non3Indexes, 3) = mod(reshapedKeypoints(non3Indexes, 3)+2, 3);
    reshapedKeypoints(~non3Indexes, 3) = 4;
end
