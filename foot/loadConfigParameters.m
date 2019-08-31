%% User-configurable parameters
% All the parameters on this file start by 's'



% Path parameters
sDatasetFolder = '../dataset/';
sDatasetCocoFolder = [sDatasetFolder, 'COCO/'];
sCocoApiPath = [sDatasetCocoFolder, 'cocoapi/'];

sAnnotationsFolder = [sCocoApiPath, 'annotations/'];
sCocoMatlabApiFolder = [sCocoApiPath, 'MatlabAPI/'];
sImageFolder = [sCocoApiPath, 'images/'];
sImageMaskFolder = [sImageFolder, 'mask2014/'];
sJsonFolder = [sDatasetCocoFolder, 'json/'];
sMatFolder = [sDatasetCocoFolder, 'mat/'];



% Algorithm parameters
sNumberKeyPoints = 17;
sImageScale = 368;



% Foot parameters
sServerJsonFolder = '/media/posefs3b/Users/tsimon/labelserver_feet/json/';
s3KeypointJsonFolder1 = [sDatasetFolder, 'foot_6/'];
s3KeypointJsonFolder2 = '/0_foot_for_clickworker_all/';
s3KeypointJsonFolder3 = '/output/';
sBodyValFolder = [sImageFolder, 'val2017/'];
sFootValFolder = [sDatasetFolder, 'images/val2017_foot/'];
