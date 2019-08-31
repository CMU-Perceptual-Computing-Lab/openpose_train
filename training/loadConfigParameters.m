%% User-configurable parameters
% All the parameters on this file start by 's'



% Path parameters
sDatasetBaseFolder = '../dataset/';
sDatasetFolder = [sDatasetBaseFolder, 'COCO/'];
sCocoApiPath = [sDatasetFolder, 'cocoapi/'];

sAnnotationsFolder = [sCocoApiPath, 'annotations/'];
sCocoMatlabApiFolder = [sCocoApiPath, 'MatlabAPI/'];
sImageFolder = [sCocoApiPath, 'images/'];
sImageMaskFolder = [sImageFolder, 'mask2017/'];
sSegmentationFolder = [sImageFolder, 'segmentation2017/'];
sJsonFolder = [sDatasetFolder, 'json/'];
sMatFolder = [sDatasetFolder, 'mat/'];



% Algorithm parameters
sNumberKeyPoints = 17;
sImageScale = 368;



% Foot parameters
sServerJsonFolder = '/media/posefs3b/Users/tsimon/labelserver_feet/json/';
s3KeypointJsonFolder1 = '/media/posefs3b/Users/gines/openpose_train/dataset/COCO/foot_6/';
s3KeypointJsonFolder2 = '/0_foot_for_clickworker_all/';
s3KeypointJsonFolder3 = '/output/';
