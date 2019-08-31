%% User-configurable parameters
% All the parameters on this file start by 's'



% Path parameters
% Caffe
sCaffePath = '/home/gines/devel/openpose_caffe_train/matlab/';
% COCO
sCocoModelsPath = '/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/openpose/models/pose/coco/';
% sCocoProtoTxt = [sCocoModelsPath, 'pose_deploy.prototxt'];
sCocoProtoTxt = '../old_or_not_used/prototxt/coco/pose_deploy.prototxt';
sCocoModel = [sCocoModelsPath, 'pose_iter_440000.caffemodel'];
% MPI
sMpiModelsPath = '../dataset/testing_model/mpi/';
sMpiProtoTxt = [sMpiModelsPath, 'pose_deploy.prototxt'];
sMpiModel = [sMpiModelsPath, 'pose_iter_146000.caffemodel'];
% Dataset
sDatasetFolder = '../dataset/COCO/';
sCocoApiFolder = [sDatasetFolder, 'cocoapi/'];
sCocoMatlabApiFolder = [sCocoApiFolder, 'MatlabAPI/'];
sImagesFolder = [sCocoApiFolder, 'images/'];
sAnnotationsFolder = [sCocoApiFolder, 'annotations/'];
sMatFolder = [sDatasetFolder, 'mat/'];
sCocoMatPath = [sMatFolder, 'coco_val'];



% Algorithm parameters
sNumberKeyPoints = 18;
sImageScale = 368;
