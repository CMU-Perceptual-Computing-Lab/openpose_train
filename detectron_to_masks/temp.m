path_ann = '/home/aaron/Desktop/cmuserver_temp/dataset/face/face_mask_out.json';
dj=jsondecode(fileread(path_ann));

for i = 1:numel(dj.annotations)
    status = dj.annotations(i).keypoints(3:3:204);
    if any(status~=2),
        a=[];
    end
end
