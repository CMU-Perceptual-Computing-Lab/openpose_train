% Prepares hand-mpii data in coco format with 42 keypoints.
% Also, adds bounding boxes and segmentations for unlabeled people using
% detectron output. Both gt annotations and detectron output is 0-indexed.
% Keypoints indices are platform dependent (in MATLAB, json indexing starts
% with 1, in Python/C++ it starts at 0).
%
% Haroon Idrees

clear; close all; clc; warning on;

% main_folder = '/home/aaron/Desktop/cmuserver_temp/dataset/hand/';
main_folder = '../dataset/hand/';
hand_mpii_dataset = [main_folder, 'hand_labels_v2/'];
% raw_hand_mpii_dataset = [main_folder, 'raw_datasets/hand_labels/'];

% run for both train and test
if 0
    path_im = [hand_mpii_dataset, 'manual_train_v2/'];
    path_ann = [main_folder, 'json/hand42_mpii_train_v2.json'];
    path_dec = [hand_mpii_dataset, 'manual_train_det_out_v2/'];
    file_out = [main_folder, 'hand42_mpii_train.json'];
    tempMatFile = [hand_mpii_dataset, 'hand42_mpii_train_gt_clean_v2.mat'];
else
    path_im = [hand_mpii_dataset, 'manual_test_v2/'];
    path_im_val = [main_folder, 'hand_mpii_val_v2/'];
    path_ann = [main_folder, 'json/hand42_mpii_test_v2.json'];
    path_dec = [hand_mpii_dataset, 'manual_test_det_out_v2/'];
    file_out = [main_folder, 'hand42_mpii_val.json'];
    tempMatFile = [hand_mpii_dataset, 'hand42_mpii_val_gt_clean_v2.mat'];

    % Remove / recreate validation image folder
    try
        rmdir(path_im_val)
    catch
    end
    mkdir(path_im_val)
end

file_in = path_ann;

addpath(genpath('clipper2'));

% CONSTS

% gt bboxes should not have more than this iou ratio with each other
IOU_RATIO_GT = .9;
% detectron bboxes should not have more than this iou ratio with each other
IOU_RATIO_DET = .95;
% post assignment if there are more det boxes that overlap with gt box,
% discard them if their iou with gt box is higher than this iou ratio
IOU_DISCARD_RATIO = .5;
% detectron scores lower than this are discarded (must be > 0.1)
DET_DISCARD_SCORE = .1;
% visualize results
TO_VISUALIZE = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nullify duplicate / zero gt annotation - since they hurt 1-1 matching

if ~exist(tempMatFile, 'file')
    dj=jsondecode(fileread(file_in)); % data_json
    count_zero = 0; count_dup = 0;
    for i = 1:numel(dj.images)
        if mod(i, floor(numel(dj.images)/25)) == 1
            fprintf('preprocessing gt %0.4d...\n', i);
        end
        all_indices = vertcat(dj.annotations.image_id);
        image_id = dj.images(i).id;
        ind_ann = find(all_indices == image_id);
        
        boxes_ann = vertcat([dj.annotations(ind_ann).bbox])';
        ind_zero = find(boxes_ann(:,3).*boxes_ann(:,4)<=0);
        if ~isempty(ind_zero)
            fprintf('zero-sized boxes: %d... ', length(ind_zero));
            for j = 1:length(ind_zero)
                % make them unit boxes (bboxOverlapRatio below will not complain)
                % at random negative locations (do not overlap with other boxes)
                boxes_ann(ind_zero(j), :) = [-round(rand*1e9) -round(rand*1e9) 1 1];
                count_zero = count_zero + 1;
            end
        end
        
        ind_ann_ignore = [];
        iou = bboxOverlapRatio(boxes_ann, boxes_ann) - eye(size(boxes_ann,1));
        iou_ = tril(iou) > IOU_RATIO_GT;
        [ind_det_i, ind_det_j] = find(iou_); % clear iou;
        for iboxes = 1:numel(ind_det_i)
            fprintf('duplicate boxes: %d... ', length(ind_det_i));
            % for duplicate boxes, keep one with more annotated keypoints
            kp_i = length(find(dj.annotations(ind_ann(ind_det_i(iboxes))).keypoints(3:3:end)==2));
            kp_j = length(find(dj.annotations(ind_ann(ind_det_j(iboxes))).keypoints(3:3:end)==2));
            
            if kp_i >= kp_j
                ind_ann_ignore = [ind_ann_ignore; ind_det_j(iboxes)];
            else
                ind_ann_ignore = [ind_ann_ignore; ind_det_i(iboxes)];
            end
            count_dup = count_dup + 1;
        end
        dj.annotations(ind_ann([ind_zero; ind_ann_ignore])) = [];
    end
    fprintf('*** problematic annotations %d zero, %d duplicate ***\n', count_zero, count_dup);
    clear count_zero count_dup  all_indices image_id ind_ann boxes_ann ind_zero ind_ann_ignore iou iou_ ind_det_i ind_det_j iboxes kp_i kp_j
    save(tempMatFile, 'dj');
else
    load(tempMatFile);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[keypoints, skeleton, key_trans] = getKeypointsLabelsAndSkeleton('hands');
skeleton = skeleton-1; % json is 0-indexed

dj_out = []; % data_json_out
dj_out.info = dj.info;
dj_out.info.version = '1.1 [Created by Haroon Idrees]';
dj_out.info.description = ['MPII hands dataset.'...
    ' Version 1.1 includes unlabeled vehicles, segmentation contours for all vehicles,' ...
    ' as well as keypoint labels for both hands.' ...
    ' All co-ordinates are 0-indexed. Bounding boxes are [x y w h], while contours are [x1,y1,x2,y2,...].'];
dj_out.licenses = dj.licenses;

dj_out.categories(1).supercategory = 'person';
dj_out.categories(1).keypoints = keypoints;
dj_out.categories(1).name = 'person';
dj_out.categories(1).id = 1; % ids same as ms-coco
dj_out.categories(1).skeleton = skeleton;

dj_out.images = dj.images;
im_names = arrayfun(@(x) [x.file_name(1:end-4) '.jpg'], dj.images, 'UniformOutput', false);
im_names = cell2struct(im_names, 'file_name', 2);
[dj_out.images.file_name] = im_names.file_name; clear im_names;
dj_out.annotations = [];

unlabeled_indices = [];
% all 42 labeled; set keypoint status to 2 (from 1) for visible;
% set keypoint status to 3 (from 0) for invisible;

all_indices = vertcat(dj.annotations.image_id);
all_boxes = vertcat([dj.annotations.bbox])';
for i = 1:numel(dj.images)
    if mod(i, floor(numel(dj.images)/25)) == 1
        fprintf('\nprocessing %d - %d: %s...', i, numel(dj.images), dj.images(i).file_name);
    end
    
    % image: fn, id, annotation indices, bboxes
    fn = [dj.images(i).file_name(1:end-4) '.jpg'];
    image_id = dj.images(i).id;
    ind_ann = find(all_indices == image_id);
    boxes_ann = all_boxes(ind_ann, :);
    
    % load detectron output
    det_output = load([fullfile(path_dec, fn(1:end-4)) '.mat']);
    det_output = fixDetContours(det_output);
    
    % round off / clip detectron boxes; 0-indexed
    boxes_det = round(det_output.boxes(:,1:4));
    boxes_det(:,1:2) = max(0, boxes_det(:,1:2));
    boxes_det(:,3) = min(dj.images(i).width-1, boxes_det(:,3));
    boxes_det(:,4) = min(dj.images(i).height-1, boxes_det(:,4));
    det_output.boxes(:,1:4) = boxes_det;
    
    % filter detectron output: unwanted classes, small bboxes, low scores
    widths = det_output.boxes(:,3) - det_output.boxes(:,1);
    heights = det_output.boxes(:,4) - det_output.boxes(:,2);
    det_output.boxes(:,3) = widths; det_output.boxes(:,4) = heights;
    ind_remove = det_output.classes ~= 1 ...
        | widths'.*heights' <= 144 | det_output.boxes(:,5)' < DET_DISCARD_SCORE;
    det_output.classes(ind_remove) = [];  det_output.boxes(ind_remove,:) = [];
    det_output.contours(ind_remove) = [];
    clear widths heights ind_remove;
    
    % remove det boxes with siginficant iou - det box with higher score survives
    ind_remove = [];
    boxes_det = det_output.boxes(:,1:4); scores_det = det_output.boxes(:,5);
    iou = bboxOverlapRatio(boxes_det, boxes_det) - eye(size(boxes_det,1));
    iou_ = tril(iou) > IOU_RATIO_DET;
    [ind_det_i, ind_det_j] = find(iou_);
    for iboxes = 1:numel(ind_det_i)
        if scores_det(ind_det_i(iboxes)) > scores_det(ind_det_j(iboxes))
            ind_remove(end+1) = ind_det_j(iboxes);
        else
            ind_remove(end+1) = ind_det_i(iboxes);
        end
    end
    det_output.classes(ind_remove) = [];  det_output.boxes(ind_remove,:) = [];
    det_output.contours(ind_remove) = [];
    clear iou iou_ ind_det_i ind_det_j;
    
    % IoU gt-det bboxes / bipartite matching based on quality of overlap
    boxes_det = det_output.boxes(:,1:4); scores_det = det_output.boxes(:,5);
    iou = bboxOverlapRatio(boxes_ann, boxes_det);
    assignment = munkres(1 - iou);
    
    % filter overlapping boxes
    ind_remove = [];
    for j = 1:size(boxes_ann,1)
        ind_overlap = find(iou(j,:) > IOU_DISCARD_RATIO);
        if numel(ind_overlap) == 1, continue; end
        ind_remove = [ind_remove, setdiff(ind_overlap, assignment)];
    end
    det_output.classes(ind_remove) = [];  det_output.boxes(ind_remove,:) = [];
    det_output.contours(ind_remove) = [];
    clear ind_remove ind_overlap;
    
    % do above step once more (lazy way of computing updated indices)
    % IoU gt-det bboxes / bipartite matching based on quality of overlap
    boxes_det = det_output.boxes(:,1:4); scores_det = det_output.boxes(:,5);
    iou = bboxOverlapRatio(boxes_ann, boxes_det);
    assignment = munkres(1 - iou);
    
    if TO_VISUALIZE
        % visualize assignment results - matlab is 1-indexed
        im = imread(fullfile(path_im, fn));
        imshow(im); hold on;
        for j = 1:size(boxes_det, 1)
            [pos, ind_ass] = find(assignment == j);
            if pos
                bbox_draw = [boxes_ann(ind_ass,1)+1 boxes_ann(ind_ass,2)+1 boxes_ann(ind_ass,3) boxes_ann(ind_ass,4)];
                rectangle('Position', bbox_draw, 'EdgeColor', 'w');
                % bbox_draw = [boxes_det(j,1)+1 boxes_det(j,2)+1 boxes_det(j,3) boxes_det(j,4)];
                % rectangle('Position', bbox_draw, 'EdgeColor', 'k');
            else
                bbox_draw = [boxes_det(j,1)+1 boxes_det(j,2)+1 boxes_det(j,3) boxes_det(j,4)];
                rectangle('Position', bbox_draw, 'EdgeColor', 'g');
            end
        end
        drawnow;
        hold off;
        pause;
        clear im j pos ind_ass bbox_draw;
    end
    
    % add data to json
    for j = 1:size(boxes_det, 1)
        %         j
        [pos, ind_ass] = find(assignment == j);
        if pos
            % bbox_draw = [boxes_ann(ind_ass,1) boxes_ann(ind_ass,2) boxes_ann(ind_ass,3) boxes_ann(ind_ass,4)];
            
            dj_out.annotations(end+1,1).iscrowd = dj.annotations(ind_ann(ind_ass)).iscrowd;
            dj_out.annotations(end).category_id = dj.annotations(ind_ann(ind_ass)).category_id;
            %             dj_out.annotations(end).bbox = dj.annotations(ind_ann(ind_ass)).bbox;
            dj_out.annotations(end).num_keypoints = numel(keypoints);
            dj_out.annotations(end).area = dj.annotations(ind_ann(ind_ass)).area;
            dj_out.annotations(end).image_id = dj.annotations(ind_ann(ind_ass)).image_id;
            
            keypoints_out = zeros(numel(keypoints), 3);
            keypoints_in = reshape(dj.annotations(ind_ann(ind_ass)).keypoints, [3, 42])';
            if dj.annotations(ind_ann(ind_ass)).category_id == 1
                %                 keypoints_out(key_trans(:,2),1:3) = keypoints_in(key_trans(:,1), 1:3);
                
                keypoints_out(1:42,:) = keypoints_in;
                dj_out.annotations(end).keypoints = reshape(keypoints_out', [numel(keypoints_out) 1]);
                dj_out.annotations(end).keypoints(find(dj.annotations(ind_ann(ind_ass)).keypoints([1:42]*3)==1)*3) = 2;
                dj_out.annotations(end).keypoints(find(dj.annotations(ind_ann(ind_ass)).keypoints([1:42]*3)==0)*3) = 3;
            end
            clear keypoints_in keypoints_out;
            
            %             segmnt_union = dj.annotations(ind_ann(ind_ass)).segmentation(:);
            segmnt_det = getDetectronSegmentation(det_output, j, dj_out.images(i).width, dj_out.images(i).height);
            %             for k = 1:size(segmnt_det,2)
            %                 segmnt_union = [segmnt_union; segmnt_det{k}(:)];
            %             end
            %             segmnt_union = double(segmnt_union);
            %             K = convhull(segmnt_union(1:2:end), segmnt_union(2:2:end));
            %             contour = [segmnt_union(2*K-1), segmnt_union(2*K)];
            %             contour = int32(contour)'; segmnt_union = contour(:);
            
            segmnt_union = segmnt_det{1};
            dj_out.annotations(end).segmentation{1} = segmnt_union(:);
            
            ind_kp_valid = find(dj_out.annotations(end).keypoints([1:42]*3) == 2);
            kp_x = dj_out.annotations(end).keypoints(ind_kp_valid*3-2);
            kp_y = dj_out.annotations(end).keypoints(ind_kp_valid*3-1);
            dj_out.annotations(end).bbox = ensureBBoxContainment(det_output.boxes(j,1:4),...
                [min(kp_x)-10, min(kp_y)-10, max(kp_x)-min(kp_x)+20, max(kp_y)-min(kp_y)+20],...
                [dj.images(i).width-1, dj.images(i).height-1]);
            clear segmnt_union segmnt_det K contour ind_kp_valid kp_x kp_y;
        else
            % bbox_draw = [boxes_det(j,1) boxes_det(j,2) boxes_det(j,3) boxes_det(j,4)];
            
            dj_out.annotations(end+1,1).iscrowd = 0;
            dj_out.annotations(end).category_id = det_output.classes(j);
            dj_out.annotations(end).keypoints = zeros(numel(keypoints)*3,1);
            dj_out.annotations(end).keypoints([1:42]*3) = 3;
            dj_out.annotations(end).bbox = det_output.boxes(j,1:4);
            dj_out.annotations(end).num_keypoints = 0;
            dj_out.annotations(end).area = boxes_det(j,3)*boxes_det(j,4);
            dj_out.annotations(end).segmentation = ...
                getDetectronSegmentation(det_output, j, dj_out.images(i).width, dj_out.images(i).height);
            dj_out.annotations(end).image_id = image_id;
            
        end
    end
    
    if TO_VISUALIZE
        % visualize final results - matlab is 1-indexed
        ind_image = find(vertcat(dj_out.annotations.image_id)==image_id);
        im = imread(fullfile(path_im, fn));
        imshow(im); hold on;
        for j = 1:numel(ind_image)
            bbox_draw = dj_out.annotations(ind_image(j)).bbox;
            bbox_draw = [bbox_draw(1)+1 bbox_draw(2)+1 bbox_draw(3) bbox_draw(4)];
            rectangle('Position', bbox_draw, 'EdgeColor', 'w');
            drawPolygon(dj_out.annotations(ind_image(j)).segmentation); drawnow;
            % pause;
        end
        hold off;
        pause;
        clear ind_image im bbox_draw;
    end
end

% make all ids uint64
tmp = arrayfun(@(x) uint64(x.id), dj_out.images, 'UniformOutput', false);
tmp = cell2struct(tmp, 'id', 2);
[dj_out.images.id] = tmp.id;

tmp = arrayfun(@(x) uint64(x.image_id), dj_out.annotations, 'UniformOutput', false);
tmp = cell2struct(tmp, 'image_id', 2);
[dj_out.annotations.image_id] = tmp.image_id;

% train / val split: use pre-defined splits
all_ids = [dj_out.images.id];
val_ids = all_ids(randperm(length(all_ids)));
val_ids = val_ids(1:round(length(val_ids)*0.0)); % no val
val_ind = ismember(all_ids, val_ids);

if contains(file_out, 'train')
    % train set
    fprintf('\nProcessing training set...\n');
    dj_train = dj_out;
    dj_train.images = []; dj_train.annotations = [];
    dj_train.images = dj_out.images(~val_ind);
    train_im_ids = vertcat(dj_out.images(~val_ind).id);
    train_ann_ind = cell2mat(arrayfun(@(x) ismember(x.image_id, train_im_ids), dj_out.annotations, 'UniformOutput', false));
    dj_train.annotations = dj_out.annotations(train_ann_ind);
    ids = num2cell(uint64(0:size(dj_train.annotations, 1)-1)); [dj_train.annotations.id] = ids{:};
    data_encode = jsonencode(dj_train);
    fid=fopen(file_out, 'w'); % file_out in place of train_out here
    fprintf(fid, data_encode);
    fclose(fid);
    clear train_im_ids train_ann_ind ids fid;
else
    % val set
    fprintf('\nProcessing validation set...\n');
    dj_val = dj_out;
    dj_val.images = []; dj_val.annotations = [];
    dj_val.images = dj_out.images(~val_ind); % added not here
    val_im_ids = vertcat(dj_out.images(~val_ind).id); % added not here
    val_ann_ind = cell2mat(arrayfun(@(x) ismember(x.image_id, val_im_ids), dj_out.annotations, 'UniformOutput', false));
    dj_val.annotations = dj_out.annotations(val_ann_ind);
    ids = num2cell(uint64(0:size(dj_val.annotations, 1)-1)); [dj_val.annotations.id] = ids{:};
    % Create validation image folder and reset image indexes to 0:N-1
    for i=1:numel(dj_val.images)
        oldId = dj_val.images(i).id;
        newId = i-1;
        % Update image.id
        dj_val.images(i).id = newId;
        % Update image_id on people annotations
        for p=1:numel(dj_val.annotations)
            if dj_val.annotations(p).image_id == oldId
                dj_val.annotations(p).image_id = newId;
            end
        end
        % Copy image into validation folder
        copyfile([path_im, dj_val.images(i).file_name], [path_im_val, dj_val.images(i).file_name]);
    end
    % Create validation image folder and reset image indexes to 0:N-1 ended
    data_encode = jsonencode(dj_val);
    fid=fopen(file_out, 'w'); % file_out in place of val_out here
    fprintf(fid, data_encode);
    fclose(fid);
    clear val_im_ids val_ann_ind ids fid;
end

% Done
fprintf('\nFinished!\n');
