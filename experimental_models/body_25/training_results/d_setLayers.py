# User configurable paths
## Path parameters
import os
from generateProtoTxt import generateProtoTxt

sCaffeFolder =  '/home/gines/devel/openpose_caffe_train/'
sDatasetFolder = '../dataset/'
# sLmdbFolders = ['lmdb_dome_bodyHand/']
sLmdbFolders = ['lmdb_coco/']
# sLmdbFolders = ['lmdb_foot/']
# sLmdbFolders = ['lmdb_coco/', 'lmdb_dome/']
# sLmdbFolders = ['lmdb_foot/', 'lmdb_dome/']
# sLmdbFolders = ['lmdb_coco/', 'lmdb_dome_bodyHand/', 'lmdb_mpii_hand']
sLmdbBackground = 'lmdb_background/'
sPretrainedModelPath = sDatasetFolder + 'vgg/VGG_ILSVRC_19_layers.caffemodel'
# sPretrainedModelPath = sDatasetFolder + 'resnet/ResNet-50-model.caffemodel'
# sPretrainedModelPath = sDatasetFolder + 'resnet/ResNet-152-model.caffemodel'
# sPretrainedModelPath = sDatasetFolder + 'resnet/v2/resnet101-v2.caffemodel'
# sPretrainedModelPath = sDatasetFolder + 'resnet/v2/resnet152-v2.caffemodel'
sTrainingFolder = '../training_results/pose/'

## Algorithm parameters
# Number heatmaps
sBodyParts = 19 # 18, Gines: 19, 23, 25
sBodyPAFs = 2*(sBodyParts+1)
# sBodyPAFs = 2*(sBodyParts+3)
sBodyPartsAndBkg = sBodyParts+1
# Solver params
sLearningRateInit = 1e-4   # 4e-5, 2e-5
sBatchSizes = [10] # [10], Gines: 21
# sBatchSizes = [7, 3, 2] # [10], Gines: 21
sNumberStages = [4, 2, 0, 0, 0, 0]
# sNumberStages = [4, 2, 2, 1, 0, 0] # For foot as independent PAF/BP
# sNumberStages = [4, 2, 0, 0, 1] # Rescale layers
# Data augmentation
sImageScale = 368
# sScaleMin = [0.5, 0.5, 0.25] # 0.5
# sScaleMax = [1.1, 8.0, 2.5]
sScaleMin = [1.0/3.0, 0.5, 0.25] # 0.5, 0.25 does harm it
sScaleMax = [1.1, 8.0, 2.5]
sCenterSwapProb = [0.0, 1.0, 0.0]
sMaxRotationDegree = 45 # 40, 60 does harm it
# Learning rate
sLearningRateMultDistro = [1.0, 1.0, 4.0, 1.0] # 'V', 'C(1-2)'('image'), 'C(1-2)', loss
# sLearningRateMultDistro = [1.0, 1.0, 1.0, 1.0] # 'V', 'C(1-2)'('image'), 'C(1-2)', loss
# sLearningRateMultDistro = [0.25, 1.0, 1.0, 1.0] # 'V', 'C(1-2)'('image'), 'C(1-2)', loss
# sLearningRateMultDistro = [1.0, 9.000018, 9.000018, 9.000018] # 'V', 'C(1-2)'('image'), 'C(1-2)', loss
# Ideally fixed
sNumberIterations = 1000000
sNumberIterationsMiddle = 50000
sUsePReLU = 1
sBatchNorm = 0
# sBatchNorm = 1
sBinaryConv = 0
# sBinaryConv = 1
if sBinaryConv:
    sPretrainedModelPath = '/media/posefs3b/Users/gines/openpose_train/training_results/2_19MoreScale2/pose/pose_iter_776000.caffemodel'
    sImageScale = 224
# Foot training
trainFoot = sNumberStages[2] + sNumberStages[3] > 0
if trainFoot:
    sPretrainedModelPath = '/media/posefs3b/Users/gines/openpose_train/training_results/2_19_42/best_730k/pose_iter_730000.caffemodel'
    sFootParts = 6
    sFootPAFs = 2*sFootParts # +1 not required because that redundancy is already in body
    sLmdbFolders = ['lmdb_coco2017_foot/']
    sLearningRateMultDistro = [0.0, 0.0, 0.0, 0.0, 4.0, 1.0] # 'V', 'C(1-2)'('image'), 'C(1-2)', loss
else:
    sFootParts = 0
    sFootPAFs = 0
# Rescale training
rescaleLayer = sNumberStages[4] > 0
if rescaleLayer:
    sPretrainedModelPath = '/media/posefs3b/Users/gines/openpose_train/training_results/2_19_42/best_730k/pose_iter_730000.caffemodel'
    # sFootParts = 6
    # sFootPAFs = 2*sFootParts # +1 not required because that redundancy is already in body
    # sLmdbFolders = ['lmdb_coco2017_foot/']
    sLearningRateMultDistro = [0.0, 0.0, 0.0, 0.0, 1.0, 1.0] # 'V', 'C(1-2)'('image'), 'C(1-2)', loss
    sLearningRateInit = 1e-1   # 4e-5, 2e-5
    sBatchSizes = [16] # [10], Gines: 21

# Foot training - Yaser's way
sBodyParts = 25
sBodyPAFs = 2*(sBodyParts+1)
sBodyPartsAndBkg = sBodyParts+1
sLmdbFolders = ['lmdb_coco2017_foot/']
# sLmdbFolders += ['lmdb_coco2017_foot/']
# sBatchSizes = [9.5, 0.5] # [10], Gines: 21

# Relative paths to full paths
sCaffeFolder = os.path.abspath(sCaffeFolder)
for index, item in enumerate(sLmdbFolders):
    sLmdbFolders[index] = os.path.abspath(sDatasetFolder + sLmdbFolders[index])
sLmdbBackground = os.path.abspath(sDatasetFolder + sLmdbBackground)
sPretrainedModelPath = os.path.abspath(sPretrainedModelPath)
sTrainingFolder = os.path.abspath(sTrainingFolder)

## Things to try:
# 1. Different batch size --> 20
# 2. Different lr --> 1e-2, 1e-3, 1e-4

## Debugging - Check absolute paths
print '\n------------------------- Absolute paths: -------------------------'
print 'sCaffeFolder absolute path:\t' + sCaffeFolder
print 'sLmdbFolder absolute paths:'
for lmdbFolder in sLmdbFolders:
    print '\t' + lmdbFolder
print 'sLmdbBackground absolute path:\t' + sLmdbBackground
print 'sPretrainedModelPath absolute path:\t' + sPretrainedModelPath
print 'sTrainingFolder absolute path:\t' + sTrainingFolder
print '\n'

def concatStage(concatString, layerName, kernel, numberOutputChannels, stride):
    layerName               += [concatString]
    kernel                  += [ 0 ]
    numberOutputChannels    += [ 0 ]
    stride                  += [ 0 ]

def resetStage(layerName, kernel, numberOutputChannels, stride):
    layerName               += ['reset']
    kernel                  += [ 0 ]
    numberOutputChannels    += [ 0 ]
    stride                  += [ 0 ]

if __name__ == "__main__":
    transformParams = [dict(stride=8, crop_size_x=sImageScale, crop_size_y=sImageScale,
                            target_dist=0.6, scale_prob=1, scale_min=sScaleMin[0], scale_max=sScaleMax[0],
                            center_swap_prob=sCenterSwapProb[0],
                            max_rotate_degree=sMaxRotationDegree, center_perterb_max=40,
                            # do_clahe=False, visualize=False,
                            model='COCO_' + str(sBodyParts + sFootParts),
                            # model='COCO_' + str(sBodyParts) + 'b',
                            source_background=sLmdbBackground,
                            number_max_occlusions=2,
                            normalization=False,
                            # normalization=True,
                            # Foot - Yaser's way
                            source_secondary=os.path.abspath(sDatasetFolder + 'lmdb_coco/'),
                            model_secondary='COCO_25_17',
                            prob_secondary=0.95
                        )]
    # If COCO2017 foot
    if len(sBatchSizes) > 1 and 'lmdb_coco2017_foot' in sLmdbFolders[1]:
        transformParamDome = eval(repr(transformParams[0]))
        transformParamDome['model'] = 'COCO_' + str(sBodyParts) + '_17'
        transformParamDome['scale_min'] = sScaleMin[1]
        transformParamDome['scale_max'] = sScaleMax[1]
        transformParamDome['center_swap_prob'] = sCenterSwapProb[1]
        transformParams = transformParams + [transformParamDome]
    # If dome
    if len(sBatchSizes) > 1 and 'dome' in sLmdbFolders[1]:
        transformParamDome = eval(repr(transformParams[0]))
        transformParamDome['model'] = 'DOME_' + str(sBodyParts)
        transformParamDome['scale_min'] = sScaleMin[1]
        transformParamDome['scale_max'] = sScaleMax[1]
        transformParamDome['center_swap_prob'] = sCenterSwapProb[1]
        transformParamDome['media_directory'] = '/media/posefs0c/panopticdb/a3/'
        transformParams = transformParams + [transformParamDome]
    # If MPII hand
    if len(sBatchSizes) == 3 and 'mpii_hand' in sLmdbFolders[2]:
        transformParamDome = eval(repr(transformParams[0]))
        transformParamDome['scale_min'] = sScaleMin[2]
        transformParamDome['scale_max'] = sScaleMax[2]
        transformParamDome['center_swap_prob'] = sCenterSwapProb[2]
        transformParamDome['model'] = 'MPII_' + str(sBodyParts)
        transformParams = transformParams + [transformParamDome]
    # If first one is Dome
    if 'dome' in sLmdbFolders[0]:
        transformParams[0]['model'] = 'DOME_' + str(sBodyParts)
        transformParams[0]['media_directory'] = '/media/posefs0c/panopticdb/a3/'
    # Create training folder
    if not os.path.exists(sTrainingFolder):
        os.makedirs(sTrainingFolder)

    # for maximumPafStage in range(1, sNumberStages[0]+2):
    for maximumPafStage in range(sNumberStages[0], sNumberStages[0]+1):
        trainingFolder = sTrainingFolder
        # if maximumPafStage <= sNumberStages[0]:
        #     trainingFolder = trainingFolder + '/' + str(maximumPafStage)
        #     isFinalModel = False
        #     numberIterations = sNumberIterationsMiddle
        # else:
        #     maximumPafStage = maximumPafStage - 1
        #     isFinalModel = True
        #     numberIterations = sNumberIterations
        isFinalModel = True
        numberIterations = sNumberIterations
        print ' '
        print trainingFolder

        # First stage             ----------------------- VGG 19 -----------------------   ---------- Body parts ----------
        layerName               = ['V','V','P'] * 2  +  ['V'] * 4 + ['P']  +  ['V'] * 2     + ['C'] * 2     + ['$']
        kernel                  = [ 3,  3,  2 ] * 2  +  [ 3 ] * 4 + [ 2 ]  +  [ 3 ] * 2     + [ 3 ] * 2     + [ 0 ]
        numberOutputChannels    = [64]*3 + [128]* 3  +  [256] * 4 + [256]  +  [512] * 2     + [256] + [128] + [ 0 ]
        stride                  = [ 1 , 1,  2 ] * 2  +  [ 1 ] * 4 + [ 2 ]  +  [ 1 ] * 2     + [ 1 ] * 2     + [ 0 ]

        # Stages 2-sNumberStages   ------------------------------------ Body + PAF parts ------------------------------------
        # nodesPerLayer = 8+2
        nodesPerLayer = 5+2
        # PAFs
        # for s in range(1, sNumberStages[0]+1):
        for s in range(1, maximumPafStage+1):
            if s == 1:
                resetStage(layerName, kernel, numberOutputChannels, stride)
            else:
                concatStage('@', layerName, kernel, numberOutputChannels, stride)

            np = sBodyPAFs
            if trainFoot:
                layerName               += ['DC2'] * (nodesPerLayer-2) + ['C2'] * 2 +  ['L2d']
            else:
                # layerName               += ['SC2'] * (nodesPerLayer-2) + ['C2'] * 2 +  ['L2']
                # layerName               += ['DC2'] * (nodesPerLayer-2) + ['C2'] * 2 +  ['L2c']
                # layerName               += ['C2'] * (nodesPerLayer-2) + ['C2'] * 2  +  ['L2']
                layerName               += ['DC2'] * (nodesPerLayer-2) + ['C2'] * 2 +  ['L2']
            kernel                  += [ 3 ] * (nodesPerLayer-2) + [1]*2        +  [ 0 ]
            if s <= 1 and s != sNumberStages[0]:
                numberOutputChannels    += [96] * (nodesPerLayer-2) + [256,np]  +  [ 0 ]
            elif s != sNumberStages[0]:
                numberOutputChannels    += [128] * (nodesPerLayer-2) + [512,np] +  [ 0 ]
            else:
                numberOutputChannels    += [128] * (nodesPerLayer-2) + [512,np] +  [ 0 ]
            # numberOutputChannels    += [128] * (nodesPerLayer-2) + [512,np]     +  [ 0 ]
            # numberOutputChannels    += [64] * (nodesPerLayer-1) + [np]          +  [ 0 ] # (Super-)Fast version
            # numberOutputChannels    += [32] * (nodesPerLayer-1) + [np]          +  [ 0 ] # Super-fast version
            stride                  += [ 1 ] * nodesPerLayer                    +  [ 0 ]

        # Body parts
        for s in range(1, sNumberStages[1]+1):
            if s == 1:
                resetStage(layerName, kernel, numberOutputChannels, stride)
            concatStage('@', layerName, kernel, numberOutputChannels, stride)

            np = sBodyPartsAndBkg
            if trainFoot:
                layerName               += ['DC1'] * (nodesPerLayer-2) + ['C1']*2   +  ['L1d']
            else:
                # layerName               += ['SC1'] * (nodesPerLayer-2) + ['C1'] * 2 +  ['L1']
                # layerName               += ['DC1'] * (nodesPerLayer-2) + ['C1'] * 2 +  ['L1c']
                layerName               += ['DC1'] * (nodesPerLayer-2) + ['C1']*2   +  ['L1']
            kernel                  += [ 3 ] * (nodesPerLayer-2) + [1]*2        +  [ 0 ]
            if s <= 1 and s != sNumberStages[1]:
                numberOutputChannels    += [96] * (nodesPerLayer-2) + [256,np] +  [ 0 ]
            elif s != sNumberStages[1]:
                numberOutputChannels    += [128] * (nodesPerLayer-2) + [512,np] +  [ 0 ]
            else:
                numberOutputChannels    += [128] * (nodesPerLayer-2) + [512,np] +  [ 0 ]
            stride                  += [ 1 ] * nodesPerLayer                    +  [ 0 ]

        # Foot PAFs
        for s in range(1, sNumberStages[2]+1):
            if s == 1:
                resetStage(layerName, kernel, numberOutputChannels, stride)
            concatStage('@f', layerName, kernel, numberOutputChannels, stride)

            np = sFootPAFs
            layerName               += ['C2f'] + ['DC2f'] * (nodesPerLayer-2) + ['C2f']*2 +  ['L2f']
            kernel                  += [1]     + [ 3 ] * (nodesPerLayer-2) + [1]*2        +  [ 0 ]
            if s <= 1 and s != sNumberStages[3]:
                numberOutputChannels    += [128] + [64] * (nodesPerLayer-2) + [64,np]     +  [ 0 ]
            else:
                numberOutputChannels    += [128] + [64] * (nodesPerLayer-2) + [128,np]    +  [ 0 ]
            stride                  += [ 1 ] * (nodesPerLayer+1)                          +  [ 0 ]

        # Foot parts
        for s in range(1, sNumberStages[3]+1):
            if s == 1:
                resetStage(layerName, kernel, numberOutputChannels, stride)
            concatStage('@f', layerName, kernel, numberOutputChannels, stride)

            np = sFootParts
            layerName               += ['C1f'] + ['DC1f'] * (nodesPerLayer-2) + ['C1f']*2 +  ['L1f']
            kernel                  += [1]     + [ 3 ] * (nodesPerLayer-2) + [1]*2        +  [ 0 ]
            if s <= 1 and s != sNumberStages[3]:
                numberOutputChannels    += [128] + [64] * (nodesPerLayer-2) + [64,np]     +  [ 0 ]
            else:
                numberOutputChannels    += [128] + [64] * (nodesPerLayer-2) + [128,np]    +  [ 0 ]
            stride                  += [ 1 ] * (nodesPerLayer+1)                          +  [ 0 ]

        # # Rescale / deconvolution layer
        # for s in range(1, sNumberStages[4]+1):
        #     if s == 1:
        #         resetStage(layerName, kernel, numberOutputChannels, stride)
        #     concatStage('@U', layerName, kernel, numberOutputChannels, stride)

        #     np = sBodyPartsAndBkg + sBodyPAFs + sFootParts + sFootPAFs
        #     layerName               += ['U'] + ['L']
        #     kernel                  += [ 0 ] + [ 0 ]
        #     numberOutputChannels    += [np]  + [ 0 ]
        #     stride                  += [ 0 ] + [ 0 ]

        extraGT = False
        # # Big PAF
        # for s in range(1, sNumberStages[4]+1):
        #     extraGT = True
        #     # Connection
        #     layerName               += ['@2']
        #     kernel                  += [ 0 ]
        #     numberOutputChannels    += [ 0 ]
        #     stride                  += [ 0 ]
        #     # Bilinear upsampling
        #     layerName               += ['U2']
        #     kernel                  += [ 0 ]
        #     numberOutputChannels    += [sBodyPAFs]
        #     stride                  += [ 2 ]
        #     # Concatenation
        #     layerName               += ['@V']
        #     kernel                  += [ 0 ]
        #     numberOutputChannels    += [ 0 ]
        #     stride                  += [ 0 ]
        #     # Conv
        #     nodesPerLayerC = 5+2
        #     layerName               += ['C2'] * nodesPerLayerC               +  ['L2_2']
        #     kernel                  += [ 7 ] * (nodesPerLayerC-2) + [1] * 2  +  [ 0 ]
        #     numberOutputChannels    += [128] * (nodesPerLayerC-1) + [0]      +  [ 0 ]
        #     stride                  += [ 1 ] * nodesPerLayerC                +  [ 0 ]
        #     # out of memory...
        #     # layerName               += ['DC2'] * (nodesPerLayerC-2) + ['C2'] * 2    +  ['L2_2']
        #     # kernel                  += [ 3 ] * (nodesPerLayerC-2) + [1] * 2         +  [ 0 ]
        #     # numberOutputChannels    += [128] * (nodesPerLayerC-1) + [0]             +  [ 0 ]
        #     # stride                  += [ 1 ] * nodesPerLayerC                       +  [ 0 ]
        # # Big body parts
        # for s in range(1, sNumberStages[5]+1):
        #     extraGT = True
        #     # Connection
        #     layerName               += ['@1']
        #     kernel                  += [ 0 ]
        #     numberOutputChannels    += [ 0 ]
        #     stride                  += [ 0 ]
        #     # Bilinear upsampling
        #     layerName               += ['U1']
        #     kernel                  += [ 0 ]
        #     numberOutputChannels    += [sBodyParts+1]
        #     stride                  += [ 2 ]
        #     # Concatenation
        #     layerName               += ['@V']
        #     kernel                  += [ 0 ]
        #     numberOutputChannels    += [ 0 ]
        #     stride                  += [ 0 ]
        #     # Conv
        #     nodesPerLayerC = 5+2
        #     layerName               += ['C1'] * nodesPerLayerC               +  ['L1_2']
        #     kernel                  += [ 7 ] * (nodesPerLayerC-2) + [1] * 2  +  [ 0 ]
        #     numberOutputChannels    += [128] * (nodesPerLayerC-1) + [0]      +  [ 0 ]
        #     stride                  += [ 1 ] * nodesPerLayerC                +  [ 0 ]
        # # # Bilinear upsampling
        # # layerName               += ['U1d', 'U2d']
        # # kernel                  += [ 0 ] * 2
        # # numberOutputChannels    += [sBodyParts+1, sBodyPAFs]
        # # stride                  += [ 2 ] * 2

        pretrainedModelPath = sPretrainedModelPath
        # if maximumPafStage == 1:
        #     pretrainedModelPath = sPretrainedModelPath
        # else:
        #     pretrainedModelPath = trainedModelsFolder + '/pose_iter_50000.caffemodel'
        print pretrainedModelPath

        # Create folders where saving
        if not os.path.exists(trainingFolder):
            os.makedirs(trainingFolder)
        trainedModelsFolder = os.path.join(trainingFolder, 'model')
        if not os.path.exists(trainedModelsFolder): # for storing Caffe models
            os.makedirs(trainedModelsFolder)

        generateProtoTxt(sLmdbFolders, trainingFolder, sBatchSizes, layerName, kernel, stride, numberOutputChannels,
                         transformParams, sLearningRateInit, trainedModelsFolder, sBodyParts, sBodyPAFs,
                         sBatchNorm, sBinaryConv, sLearningRateMultDistro, sCaffeFolder, pretrainedModelPath,
                         isFinalModel, numberIterations, maximumPafStage, sUsePReLU, extraGT, sFootParts, sFootPAFs)
