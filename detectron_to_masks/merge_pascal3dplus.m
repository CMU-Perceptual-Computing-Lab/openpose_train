% Merge bus/car imagenet/pascal images/annotations in pascal3d+ dataset so
% that there is only one folder for images and one folder for annotations

% paths to original data
path_im_up = './pascal3d+/dataset_unprocessed/Images/';
path_ann_up = './pascal3d+/dataset_unprocessed/Annotations/';

% new folders to create
path_im = './pascal3d+/dataset/Images/';
path_ann = './pascal3d+/dataset/Annotations/';
mkdir(path_im); mkdir(path_ann);

folders = {'bus_pascal'; 'bus_imagenet'; 'car_pascal'; 'car_imagenet'};

for iFolder = 1:size(folders,1)
    files = dir([path_im_up folders{iFolder}]);
    for iFiles = 3:size(files,1)
        copyfile(sprintf('%s%s//%s', path_im_up, folders{iFolder}, files(iFiles).name),...
            sprintf('%s%s_%s', path_im, folders{iFolder}, regexprep(files(iFiles).name, 'JPEG', 'jpg')));
    end
end

for iFolder = 1:size(folders,1)
    files = dir([path_ann_up folders{iFolder}]);
    for iFiles = 3:size(files,1)
        copyfile(sprintf('%s%s//%s', path_ann_up, folders{iFolder}, files(iFiles).name),...
            sprintf('%s%s_%s', path_ann, folders{iFolder}, files(iFiles).name));
    end
end

% now run detectron on the created Images folder

