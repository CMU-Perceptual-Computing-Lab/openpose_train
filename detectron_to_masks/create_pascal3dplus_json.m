% Create JSON file in MS-COCO format for Pascal3d+ dataset

clc; clear; close all;
path_im = './pascal3d+/dataset/Images/';
path_ann = './pascal3d+/dataset/Annotations/';
file_out = './pascal3d+/dataset/pascal3dplus_in_coco_format.json';

dj = []; % data_json

dj.info = [];
dj.info.url = 'http://cvgl.stanford.edu/projects/pascal3d.html';
dj.info.year = '2014';
dj.info.date_created = datestr([2014 12 31 12 0 0]);
dj.info.version = '1.0';

dj.licenses = [];
dj.licenses.url = 'unknown';
dj.licenses.id = 1;
dj.licenses.name = 'unknown';

dj.categories = [];
dj.images = [];
dj.annotations = [];

% % ids = [];
% % % a = vertcat({files.name});
% % % a(1:2) = [];
% % for i = 3:size(files,1)
% %     fn = files(i).name;
% %     ind_ = strfind(fn, '_');
% %     indpascal = ~contains(fn, 'pascal');
% %     fn = fn(ind_(2)+1+indpascal:end-4);
% %     fn = uint64(str2double(regexprep(fn, '_', '')));
% %     ind_exist = find(ids==fn);
% %     if ind_exist
% %         error('ids are not unique...\n');
% %     else
% %         ids = [ids; fn];
% %     end
% % end
% % conclusion: ids from file names are not unique

files = dir(path_ann);
for i=3:numel(files)
    fprintf('processing %d - %d: %s...\n', i, numel(files), files(i).name);
    fn = files(i).name;
    fn = regexprep(fn, 'JPEG', 'jpg');
    
    object = load([path_ann fn]);
    record = object.record;
    
    dj.images(i-2).data_captured = 'unknown';
    dj.images(i-2).width = record.imgsize(1);
    dj.images(i-2).height = record.imgsize(2);
    dj.images(i-2).license = 1;
    dj.images(i-2).id = 1.4e6 + i-2;
    dj.images(i-2).file_name = fn;
    dj.images(i-2).flickr_url = 'unknown';
    dj.images(i-2).coco_url = 'unknown';
    
    %     assert(size(record.objects.bbox,1)==1)
    for j = 1:numel(record.objects)
        if isfield(record.objects(j), 'anchors') ~= 1 || ...
                isempty(record.objects(j).anchors) == 1
            continue;
        end
        names = fieldnames(record.objects(j).anchors);
        if length(names) ~= 12, continue; end
        
        if strcmp(record.objects(j).class, 'car')
            cat = 'car';
        elseif strcmp(record.objects(j).class, 'bus')
            cat = 'bus';
        else
            continue;
        end
        
        bbox = round(record.objects(j).bbox)-1;
        bbox(1:2) = max(0, bbox(1:2));
        bbox(3) = min(dj.images(i-2).width-1, bbox(3));
        bbox(4) = min(dj.images(i-2).height-1, bbox(4));
        bbox_wh = [bbox(1) bbox(2) bbox(3)-bbox(1) bbox(4)-bbox(2)];
        if bbox_wh(3)*bbox_wh(4) <= 0
            error('zero bbox...\n');
        end
        
        dj.annotations(end+1).iscrowd = 0;
        dj.annotations(end).category_id = strcmp(cat, 'car')*3 + strcmp(cat, 'bus')*6;
        dj.annotations(end).bbox = bbox_wh;
        dj.annotations(end).keypoints = zeros(36,1);
        
        for k = 1:numel(names)
            if isempty(record.objects(j).anchors.(names{k}).location)
                x = 0;
                y = 0;
                s = 0;
            else
                x = round(record.objects(j).anchors.(names{k}).location(1))-1;
                y = round(record.objects(j).anchors.(names{k}).location(2))-1;
                s = 2; %record.objects(j).anchors.(names{k}).status;
            end
            dj.annotations(end).keypoints(3*k-2) = x;
            dj.annotations(end).keypoints(3*k-1) = y;
            dj.annotations(end).keypoints(3*k-0) = s;
        end
        
        kp = reshape(dj.annotations(end).keypoints, [3, 12])';
        ind_valid = find(kp(:,3) ==2);
        dj.annotations(end).num_keypoints = length(ind_valid);
        dj.annotations(end).area = bbox_wh(3)*bbox_wh(4);
        dj.annotations(end).image_id = dj.images(i-2).id ;
        
        try
            K = convhull(kp(ind_valid,1), kp(ind_valid,2));
            segmnt = kp(ind_valid(K(1:end-1)),1:2)';
        catch
            segmnt = bbox(:);
        end
        dj.annotations(end).segmentation = segmnt(:);
        dj.annotations(end).id = size(dj.annotations,2)-1;
        
    end
end
data_encode = jsonencode(dj);
fid=fopen(file_out, 'w');
fprintf(fid, data_encode);
fclose(fid);