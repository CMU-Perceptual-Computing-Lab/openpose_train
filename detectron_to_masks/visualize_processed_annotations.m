clear; close all; clc;

% % hands - dome
% path_images = '/home/aaron/Desktop/cmuserver_temp/dataset/hand/hand143_panopticdb/imgs/'; 
% path_ann = '/home/aaron/Desktop/cmuserver_temp/dataset/hand/json/hand21_dome_train.json';
% path_ann = '/home/aaron/Desktop/cmuserver_temp/matlab_code/person/processed_handdome_train.json';
% 
% % hands - mpii - train
% path_images = '/home/aaron/Desktop/cmuserver_temp/dataset/hand/hand_labels/manual_train/'; 
% path_ann = '/home/aaron/Desktop/cmuserver_temp/dataset/hand/json/hand42_mpii_train.json';
% path_ann = '/home/aaron/Desktop/cmuserver_temp/matlab_code/person/processed_handmpii_train.json';

% % hands - mpii - test 
% path_images = '/home/aaron/Desktop/cmuserver_temp/dataset/hand/hand_labels/manual_test/'; 
% path_ann = '/home/aaron/Desktop/cmuserver_temp/dataset/hand/json/hand42_mpii_test.json';
% path_ann = '/home/aaron/Desktop/cmuserver_temp/matlab_code/person/processed_handmpii_val.json';

% face
path_images = '/home/aaron/Desktop/cmuserver_temp/dataset/face/face_mask_out/';
path_ann = '/home/aaron/Desktop/cmuserver_temp/dataset/face/face_mask_out.json';

data_json=jsondecode(fileread(path_ann));
numpoints = data_json.annotations(1).num_keypoints;

% if contains(path_images, 'hand')
%     if contains(path_images, 'panoptic'), numpoints = 21;
%     elseif contains(path_images, 'mpii'), numpoints = 42;
%     end
% elseif contains(path_images, 'face')
%     numpoints = 70;
% end

figure;
for i=1:10:numel(data_json.images)
    i
    filename = [data_json.images(i).file_name(1:end-4) '.jpg'];
    image_id = data_json.images(i).id;
    sprintf(filename);
    I = imread(fullfile(path_images, data_json.images(i).file_name)); 
    imshow(I);
    hold on;
    
    % sort boxes so that annotated appear on top of others
    ind = find(vertcat(data_json.annotations.image_id)==image_id);
    [~,ind_sort] = sort([data_json.annotations(ind).num_keypoints]);
    ind = ind(ind_sort); clear ind_sort;

    % show the bounding box - matlab is 1-indexed
    for j = 1:numel(ind)
        bbox = data_json.annotations(ind(j)).bbox;
        bbox_draw = [bbox(1)+1 bbox(2)+1 bbox(3) bbox(4)];
        segmnt = data_json.annotations(ind(j)).segmentation;
        if data_json.annotations(ind(j)).num_keypoints > 0
            rectangle('Position', bbox_draw, 'EdgeColor', 'g');
            drawPolygon(segmnt);
            
            % show anchor points
            for k = 1:numpoints
                status = data_json.annotations(ind(j)).keypoints((k-1)*3+3);
                if status == 1 || status == 2
                    x = data_json.annotations(ind(j)).keypoints((k-1)*3+1);
                    y = data_json.annotations(ind(j)).keypoints((k-1)*3+2);
                    %plot(x, y, 'ro');
                    text(x,y,num2str(k),'fontname', 'courier new', 'fontsize', 12, 'color', 'w', 'backgroundcolor', 'k');
                end
            end
        else
            % rectangle('Position', bbox_draw, 'EdgeColor', 'g');
            drawPolygon(segmnt, 'w', .8);
        end
    end
    hold off; drawnow;
    pause;
end


