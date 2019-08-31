%% User-configurable parameters
% All the parameters on this file start by 's'



% Path parameters
% Caffe
sCaffePath = '/home/gines/devel/caffe_train/matlab/';
sNumberGpus = 4;
sNumberGpusStart = 0;
% COCO
sCocoModelsPath = '/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/openpose/models/pose/coco/';
sCocoProtoTxt = '../old_or_not_used/prototxt/coco/pose_deploy.prototxt';
sCocoModel = [sCocoModelsPath, 'pose_iter_440000.caffemodel'];
% MPI
sMpiModelsPath = '../dataset/testing_model/mpi/';
sMpiProtoTxt = [sMpiModelsPath, 'pose_deploy.prototxt'];
sMpiModel = [sMpiModelsPath, 'pose_iter_146000.caffemodel'];
% Dataset
sDatasetBaseFolder = '../dataset/';
sDatasetFolder = [sDatasetBaseFolder, 'COCO/'];
sCocoApiFolder = [sDatasetFolder, 'cocoapi/'];
sCocoMatlabApiFolder = [sCocoApiFolder, 'MatlabAPI/'];
sImagesFolder = [sCocoApiFolder, 'images/'];
sAnnotationsFolder = [sCocoApiFolder, 'annotations/'];
sMatFolder = [sDatasetFolder, 'mat/'];
sCocoMatPath = [sMatFolder, 'coco_val'];



% Algorithm parameters
sNumberKeyPoints = 18;
sImageScale = 368;
