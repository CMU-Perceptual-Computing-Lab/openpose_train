# User configurable paths
## Path parameters
import os
sCaffeFolder =  '/home/gines/devel/openpose_caffe_train/'
sDatasetFolder = '../dataset/'
# sLmdbFolders = ['lmdb_coco/']
# sLmdbFolders = ['lmdb_foot/']
# sLmdbFolders = ['lmdb_coco/', 'lmdb_dome/']
# sLmdbFolders = ['lmdb_foot_coco2014/', 'lmdb_foot_dome_it1/']
sLmdbFolders = ['lmdb_foot_coco2014/', 'lmdb_foot_dome_it1/', 'lmdb_coco/']
sLmdbBackground = 'lmdb_background/'
sPretrainedModelPath = sDatasetFolder + 'vgg/VGG_ILSVRC_19_layers.caffemodel'
sPretrainedModelPath = '/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/openpose/models/pose/coco/pose_iter_440000.caffemodel'
sTrainingFolder = '../training_results/pose/'
sTrainedModelsFolder = os.path.join(sTrainingFolder, 'model')
# Relative paths to full paths
sCaffeFolder =  os.path.abspath(sCaffeFolder)
for index, item in enumerate(sLmdbFolders):
    sLmdbFolders[index] = os.path.abspath(sDatasetFolder + sLmdbFolders[index])
sLmdbBackground = os.path.abspath(sDatasetFolder + sLmdbBackground)
sPretrainedModelPath = os.path.abspath(sPretrainedModelPath)
sTrainingFolder = os.path.abspath(sTrainingFolder)
sTrainedModelsFolder = os.path.abspath(sTrainedModelsFolder)

## Algorithm parameters
sNumberKeyPoints = 23; # 18, Gines: 19, 23
sNumberPAFs = 2*(sNumberKeyPoints+1);
sNumberTotalParts = sNumberKeyPoints + sNumberPAFs
sNumberKeyPointsPlusBackground = sNumberKeyPoints+1;
sImageScale = 368;
sLearningRateInit = 4e-5   # 4e-5, 2e-5
# sBatchSizes = [10] # [10], Gines: 21
# sBatchSizes = [9, 1] # [10], Gines: 21
sBatchSizes = [1, 2, 7] # [10], Gines: 21
sMaxRotationDegree = 40 # 40, Gines: 180
sBatchNorm = 0
sNumberStages = 6
sScaleMin = 0.5 # 0.5, Gines: 0.1
sScaleMax = 1.1

## Fix parameters
sKeypointLevel = 0
sPafLevel = -(sKeypointLevel-1)     # 0 or 1, depending on sKeypointLevel = 1 or 0
sLabelName = ['label_heat', 'label_vec', 'heat_weight', 'vec_weight', 'heat_temp', 'vec_temp'] # `heat` in [2*n+sKeypointLevel] positions, `vec` in [2*n+sPafLevel] positions

## Things to try:
# 1. Different batch size --> 20
# 2. Different lr --> 1e-2, 1e-3, 1e-4
# 3. Increase scale_min & scale_max
# 4. Increase max rotation degree

## Debugging - Check absolute paths
print '\n------------------------- Absolute paths: -------------------------'
print 'sCaffeFolder absolute path:\t' + sCaffeFolder
print 'sLmdbFolder absolute paths:'
for lmdbFolder in sLmdbFolders:
    print '\t' + lmdbFolder
print 'sLmdbBackground absolute path:\t' + sLmdbBackground
print 'sPretrainedModelPath absolute path:\t' + sPretrainedModelPath
print 'sTrainingFolder absolute path:\t' + sTrainingFolder
print 'sTrainedModelsFolder absolute path:\t' + sTrainedModelsFolder
print '\n'





import sys
import os
import math
import argparse
import json
from ConfigParser import SafeConfigParser

sys.path.insert(0, os.path.join(sCaffeFolder, 'python'))
import caffe
from caffe import layers as L  # pseudo module using __getattr__ magic to generate protobuf messages
from caffe import params as P  # pseudo module using __getattr__ magic to generate protobuf messages

def setLayersTwoBranches(dataFolders, batchSizes, layerName, kernel, stride, numberOutputChannels, numberTotalParts, labelName,
                         transformParams, deploy=False, batchNorm=0, lrMultDistro=[1,1,1]):
    # it is tricky to produce the deploy prototxt file, as the data input is not from a layer, so we have to create a workaround
    # producing training and testing prototxt files is pretty straightforward
    caffeNet = caffe.NetSpec()
    assert len(layerName) == len(kernel)
    assert len(layerName) == len(stride)
    assert len(layerName) == len(numberOutputChannels)

    # Testing/deployment mode
    if deploy:
        input = "image"
        dim1 = 1
        dim2 = 3
        dim3 = 1 # Reshaped on runtime
        dim4 = 1 # Reshaped on runtime
        # make an empty "data" layer so the next layer accepting input will be able to take the correct blob name "data",
        # we will later have to remove this layer from the serialization string, since this is just a placeholder
        caffeNet.image = L.Layer()
    # Training mode - Use lmdb
    else:
        if len(batchSizes) != len(dataFolders):
            raise ValueError("len(batchSizes) != len(dataFolders)!")
        # If not merging different datasets
        if len(batchSizes) == 1:
            caffeNet.image, caffeNet.tops['label'] = L.OPData(data_param=dict(backend=1, source=dataFolders[0], batch_size=batchSizes[0]),
                                                              op_transform_param=transformParams[0], ntop=2)
        # If merging different datasets
        elif len(batchSizes) <= 3:
            # Lmdb 1 - COCO
            caffeNet.tops['dataFoot'], caffeNet.tops['labelFoot'] = L.OPData(
                data_param=dict(backend=1, source=dataFolders[0], batch_size=batchSizes[0]), op_transform_param=transformParams[0], ntop=2
            )
            # Lmdb 2 - DomeDB
            caffeNet.tops['dataDomeDB'], caffeNet.tops['labelDomeDB'] = L.OPData(
                data_param=dict(backend=1, source=dataFolders[1], batch_size=batchSizes[1]), op_transform_param=transformParams[1], ntop=2
            )
            if len(batchSizes) == 3:
                # Lmdb 3 - COCO
                caffeNet.tops['dataCoco'], caffeNet.tops['labelCoco'] = L.OPData(
                    data_param=dict(backend=1, source=dataFolders[2], batch_size=batchSizes[2]), op_transform_param=transformParams[2], ntop=2
                )
            # Dataset concat layer
            if len(batchSizes) == 2:
                caffeNet.image = L.Concat(caffeNet.tops['dataFoot'], caffeNet.tops['dataDomeDB'], concat_param=dict(axis=0))
                caffeNet.tops['label'] = L.Concat(caffeNet.tops['labelFoot'], caffeNet.tops['labelDomeDB'], concat_param=dict(axis=0))
            else:
                caffeNet.image = L.Concat(caffeNet.tops['dataFoot'], caffeNet.tops['dataDomeDB'], caffeNet.tops['dataCoco'], concat_param=dict(axis=0))
                caffeNet.tops['label'] = L.Concat(caffeNet.tops['labelFoot'], caffeNet.tops['labelDomeDB'], caffeNet.tops['labelCoco'], concat_param=dict(axis=0))
        else:
            raise ValueError("Wrong batchSizes size.")
        # Slice layer
        caffeNet.tops[labelName[3]], caffeNet.tops[labelName[2]], caffeNet.tops[labelName[5]], caffeNet.tops[labelName[4]] = L.Slice(
            caffeNet.label, slice_param=dict(axis=1, slice_point=[sNumberPAFs, numberTotalParts+1, numberTotalParts+sNumberPAFs+1]), ntop=4
        )
        # 2 Eltwise layers
        for level in range(0,2):
            caffeNet.tops[labelName[level]] = L.Eltwise(caffeNet.tops[labelName[level+2]], caffeNet.tops[labelName[level+4]], operation=P.Eltwise.PROD)

        # something special before everything
        # caffeNet.image = caffeNet.data
        # caffeNet.image, caffeNet.center_map = L.Slice(caffeNet.data, slice_param=dict(axis=1, slice_point=3), ntop=2)
        # caffeNet.silence2 = L.Silence(caffeNet.center_map, ntop=0)
        #caffeNet.pool_center_lower = L.Pooling(caffeNet.center_map, kernel_size=9, stride=8, pool=P.Pooling.AVE)

    # just follow arrays..CPCPCPCPCCCC....
    lastLayer = ['image', 'image']
    stage = 1
    convCounter = 1
    poolCounter = 1
    dropCounter = 1
    localCounter = 1
    state = 'image' # can be image or fuse
    sharePoint = 0

    for l in range(0, len(layerName)):
        # Convolution layers
        if layerName[l] == 'V': #pretrained VGG layers
            conv_name = 'conv%d_%d' % (poolCounter, localCounter)
            lr_m = lrMultDistro[0]
            caffeNet.tops[conv_name] = L.Convolution(caffeNet.tops[lastLayer[0]], kernel_size=kernel[l],
                                                     num_output=numberOutputChannels[l], pad=int(math.floor(kernel[l]/2)),
                                                     param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)],
                                                     weight_filler=dict(type='gaussian', std=0.01),
                                                     bias_filler=dict(type='constant'))
            lastLayer[0] = conv_name
            lastLayer[1] = conv_name
            print '%s\tch=%d\t%.1f' % (lastLayer[0], numberOutputChannels[l], lr_m)
            ReLUname = 'relu%d_%d' % (poolCounter, localCounter)
            caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer[0]], in_place=True)
            localCounter += 1
            print ReLUname
        if layerName[l] == 'B':
            poolCounter += 1
            localCounter = 1
        # Convolution layers
        if layerName[l] == 'C':
            if state == 'image':
                #conv_name = 'conv%d_stage%d' % (convCounter, stage)
                conv_name = 'conv%d_%d_CPM' % (poolCounter, localCounter) # no image state in subsequent stages
                if stage == 1:
                    lr_m = lrMultDistro[1]
                else:
                    lr_m = lrMultDistro[1]
            else: # fuse
                conv_name = 'Mconv%d_stage%d' % (convCounter, stage)
                lr_m = lrMultDistro[2]
                convCounter += 1
            #if stage == 1:
            #    lr_m = 1
            #else:
            #    lr_m = lr_sub
            caffeNet.tops[conv_name] = L.Convolution(caffeNet.tops[lastLayer[0]], kernel_size=kernel[l],
                                                     num_output=numberOutputChannels[l], pad=int(math.floor(kernel[l]/2)),
                                                     param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)],
                                                     weight_filler=dict(type='gaussian', std=0.01),
                                                     bias_filler=dict(type='constant'))
            lastLayer[0] = conv_name
            lastLayer[1] = conv_name
            print '%s\tch=%d\t%.1f' % (lastLayer[0], numberOutputChannels[l], lr_m)
            # ReLU (+ BatchNorm) layers
            if layerName[l+1] != 'L':
                if state == 'image':
                    # Uncommenting this crashes the program
                    # if batchNorm == 1:
                    #     batchNormName = 'bn%d_stage%d' % (convCounter, stage)
                    #     caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer[0]],
                    #                                          param=[dict(lr_mult=0), dict(lr_mult=0), dict(lr_mult=0)])
                    #                                          #scale_filler=dict(type='constant', value=1), shift_filler=dict(type='constant', value=0.001))
                    #     lastLayer[0] = batchNormName
                    #ReLUname = 'relu%d_stage%d' % (convCounter, stage)
                    ReLUname = 'relu%d_%d_CPM' % (poolCounter, localCounter)
                    caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer[0]], in_place=True)
                else:
                    if batchNorm == 1:
                        batchNormName = 'Mbn%d_stage%d' % (convCounter, stage)
                        caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer[0]],
                                                             param=[dict(lr_mult=0), dict(lr_mult=0), dict(lr_mult=0)])
                                                             #scale_filler=dict(type='constant', value=1), shift_filler=dict(type='constant', value=0.001))
                        lastLayer[0] = batchNormName
                    ReLUname = 'Mrelu%d_stage%d' % (convCounter, stage)
                    caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer[0]], in_place=True)
                #lastLayer = ReLUname
                print ReLUname

            #convCounter += 1
            localCounter += 1
        # Convolution layers
        elif layerName[l] == 'C2':
            for level in range(0,2):
                if state == 'image':
                    #conv_name = 'conv%d_stage%d' % (convCounter, stage)
                    conv_name = 'conv%d_%d_CPM_L%d' % (poolCounter, localCounter, level+1) # no image state in subsequent stages
                    if conv_name == 'conv5_5_CPM_L1':
                        conv_name = 'conv5_5_CPM_L1_foot'
                    if conv_name == 'conv5_5_CPM_L2':
                        conv_name = 'conv5_5_CPM_L2_foot'
                    if stage == 1:
                        lr_m = lrMultDistro[1]
                    else:
                        lr_m = lrMultDistro[1]
                else: # fuse
                    conv_name = 'Mconv%d_stage%d_L%d_foot' % (convCounter, stage, level+1)
                    lr_m = lrMultDistro[2]
                    #convCounter += 1
                #if stage == 1:
                #    lr_m = 1
                #else:
                #    lr_m = lr_sub
                if layerName[l+1] == 'L2':
                    if level == sPafLevel:
                        numberOutputChannels[l] = sNumberPAFs
                    elif level == sKeypointLevel:
                        numberOutputChannels[l] = sNumberKeyPointsPlusBackground
                    else:
                        raise ValueError("Wrong level selected.")

                caffeNet.tops[conv_name] = L.Convolution(caffeNet.tops[lastLayer[level]], kernel_size=kernel[l],
                                                         num_output=numberOutputChannels[l], pad=int(math.floor(kernel[l]/2)),
                                                         param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)],
                                                         weight_filler=dict(type='gaussian', std=0.01),
                                                         bias_filler=dict(type='constant'))
                lastLayer[level] = conv_name
                print '%s\tch=%d\t%.1f' % (lastLayer[level], numberOutputChannels[l], lr_m)

                if layerName[l+1] != 'L2':
                    if state == 'image':
                        if batchNorm == 1:
                            batchNormName = 'bn%d_stage%d_L%d' % (convCounter, stage, level+1)
                            caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer[level]],
                                                                       param=[dict(lr_mult=0), dict(lr_mult=0), dict(lr_mult=0)])
                                                                       #scale_filler=dict(type='constant', value=1), shift_filler=dict(type='constant', value=0.001))
                            lastLayer[level] = batchNormName
                        #ReLUname = 'relu%d_stage%d' % (convCounter, stage)
                        ReLUname = 'relu%d_%d_CPM_L%d' % (poolCounter, localCounter, level+1)
                        caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer[level]], in_place=True)
                    else:
                        if batchNorm == 1:
                            batchNormName = 'Mbn%d_stage%d_L%d' % (convCounter, stage, level+1)
                            caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer[level]],
                                                                       param=[dict(lr_mult=0), dict(lr_mult=0), dict(lr_mult=0)])
                                                                       #scale_filler=dict(type='constant', value=1), shift_filler=dict(type='constant', value=0.001))
                            lastLayer[level] = batchNormName
                        ReLUname = 'Mrelu%d_stage%d_L%d' % (convCounter, stage, level+1)
                        caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer[level]], in_place=True)
                    print ReLUname

            convCounter += 1
            localCounter += 1
        # Pooling layers
        elif layerName[l] == 'P':
            caffeNet.tops['pool%d_stage%d' % (poolCounter, stage)] = L.Pooling(caffeNet.tops[lastLayer[0]], kernel_size=kernel[l], stride=stride[l], pool=P.Pooling.MAX)
            lastLayer[0] = 'pool%d_stage%d' % (poolCounter, stage)
            poolCounter += 1
            localCounter = 1
            convCounter += 1
            print lastLayer[0]
        # Loss layers
        elif layerName[l] == 'L':
            # Loss: caffeNet.loss layer is only in training and testing nets, but not in deploy net.
            if not deploy:
                level = sKeypointLevel
                name = 'weight_stage%d' % stage
                caffeNet.tops[name] = L.Eltwise(caffeNet.tops[lastLayer[level]], caffeNet.tops[labelName[(level+2)]], operation=P.Eltwise.PROD)
                caffeNet.tops['loss_stage%d' % stage] = L.EuclideanLoss(caffeNet.tops[name], caffeNet.tops[labelName[level]])

            print 'loss %d' % stage
            stage += 1
            convCounter = 1
            poolCounter = 1
            dropCounter = 1
            localCounter = 1
            state = 'image'
        # Loss layers
        elif layerName[l] == 'L2':
            # Loss: caffeNet.loss layer is only in training and testing nets, but not in deploy net.
            weight = [lrMultDistro[3],1];
            # print lrMultDistro[3]
            for level in range(0,2):
                if not deploy:
                    name = 'weight_stage%d_L%d' % (stage, level+1)
                    caffeNet.tops[name] = L.Eltwise(caffeNet.tops[lastLayer[level]], caffeNet.tops[labelName[(level+2)]], operation=P.Eltwise.PROD)
                    caffeNet.tops['loss_stage%d_L%d' % (stage, level+1)] = L.EuclideanLoss(caffeNet.tops[name], caffeNet.tops[labelName[level]], loss_weight=weight[level])

                print 'loss %d level %d' % (stage, level+1)

            stage += 1
            #last_connect = lastLayer
            #lastLayer = 'image'
            convCounter = 1
            poolCounter = 1
            dropCounter = 1
            localCounter = 1
            state = 'image'
        # Dropout layers
        elif layerName[l] == 'D':
            if deploy == False:
                caffeNet.tops['drop%d_stage%d' % (dropCounter, stage)] = L.Dropout(caffeNet.tops[lastLayer[0]], in_place=True, dropout_param=dict(dropout_ratio=0.5))
                dropCounter += 1
        # Concat layers
        elif layerName[l] == '@':
            #if not sharePoint:
            #    sharePoint = lastLayer
            caffeNet.tops['concat_stage%d' % stage] = L.Concat(caffeNet.tops[lastLayer[0]], caffeNet.tops[lastLayer[1]], caffeNet.tops[sharePoint], concat_param=dict(axis=1))

            localCounter = 1
            state = 'fuse'
            lastLayer[0] = 'concat_stage%d' % stage
            lastLayer[1] = 'concat_stage%d' % stage
            print lastLayer
        # Sharepoint index (the output of the last layer is shared by multiple stages)
        elif layerName[l] == '$':
            sharePoint = lastLayer[0]
            poolCounter += 1
            localCounter = 1
            print 'share'

    # Return result
    if deploy:
        caffeNet.tops['net_output'] = L.Concat(caffeNet.tops[lastLayer[0]], caffeNet.tops[lastLayer[1]], concat_param=dict(axis=1))
        deployInit = 'input: {}\n\
input_dim: {} # This value will be defined at runtime\n\
input_dim: {}\n\
input_dim: {} # This value will be defined at runtime\n\
input_dim: {} # This value will be defined at runtime\n'.format('"' + input + '"', dim1, dim2, dim3, dim4)
        # assemble the input header with the net layers string.  remove the first placeholder layer from the net string.
        layerText = 'layer {'
        return deployInit + layerText + layerText.join(str(caffeNet.to_proto()).split(layerText)[2:])
    else:
        return str(caffeNet.to_proto())



def writePrototxts(dataFolders, trainingFolder, batchSizes, layerName, kernel, stride, numberOutputChannels, transformParams,
                   learningRateInit, trainedModelsFolder, numberTotalParts, labelName='label_1st', batchNorm=0, lrMultDistro=[1,1,1]):
    # pose_training.prototxt - Training prototxt
    stringToWrite = setLayersTwoBranches(dataFolders, batchSizes, layerName, kernel, stride, numberOutputChannels, numberTotalParts, labelName, transformParams, deploy=False, batchNorm=batchNorm, lrMultDistro=lrMultDistro)
    with open('%s/pose_training.prototxt' % trainingFolder, 'w') as f:
        f.write(stringToWrite)

    # pose_deploy.prototxt - Deployment prototxt
    stringToWrite = setLayersTwoBranches([], [], layerName, kernel, stride, numberOutputChannels, numberTotalParts, labelName, transformParams, deploy=True, batchNorm=batchNorm, lrMultDistro=lrMultDistro)
    with open('%s/pose_deploy.prototxt' % trainingFolder, 'w') as f:
        f.write(stringToWrite)

    # solver.prototxt - Solver parameters
    solver_string = getSolverPrototxt(learningRateInit, trainedModelsFolder)
    with open('%s/pose_solver.prototxt' % trainingFolder, "w") as f:
        f.write('%s' % solver_string)

    # train_pose.sh - Training script
    bash_string = getBash()
    with open('%s/train_pose.sh' % trainingFolder, "w") as f:
        f.write('%s' % bash_string)



def getSolverPrototxt(learningRateInit, snapshotFolder):
    string = '# Net Path Location\n\
net: "pose_training.prototxt"\n\
# Testing\n\
# test_iter specifies how many forward passes the test should carry out.\n\
# In the case of MNIST, we have test batch size 100 and 100 test iterations,\n\
# covering the full 10,000 testing images.\n\
#test_iter: 100\n\
# Carry out testing every 500 training iterations.\n\
#test_interval: 500\n\
# Solver Parameters - Base Learning Rate, Momentum and Weight Decay\n\
base_lr: %f\n\
momentum: 0.9\n\
weight_decay: 0.0005\n\
lr_policy: "step"   # The learning rate policy\n\
gamma: 0.333\n\
stepsize: 136106    # Mine:100000   # Previously: 29166 68053 136106 (previous one)\n\
# Output - Model Saving and Loss Output\n\
display: 20 # Previously: 5   # Display every X iterations\n\
max_iter: 1000000   # Maximum number of iterations, previously: 600000\n\
snapshot: 2000   # Snapshot intermediate results, previously: 2000. Mine: 10000?\n\
snapshot_prefix: "%s/pose"\n\
solver_mode: GPU   # CPU or GPU\n' % (learningRateInit, snapshotFolder)
    return string



def getBash():
    return ('#!/usr/bin/env sh\n' + sCaffeFolder + '/build/tools/caffe train --solver=pose_solver.prototxt --gpu=$1 \
--weights=' + sPretrainedModelPath + ' 2>&1 | tee ./training_log.txt\n')



if __name__ == "__main__":
    sLearningRateMultDistro = [1.0, 1.0, 4.0, 1.0]
    transformParams = [dict(stride=8, crop_size_x=sImageScale, crop_size_y=sImageScale,
                            target_dist=0.6, scale_prob=1, scale_min=sScaleMin, scale_max=sScaleMax,
                            max_rotate_degree=sMaxRotationDegree, center_perterb_max=40, do_clahe=False,
                            visualize=False, model='COCO_' + str(sNumberKeyPoints), source_background=sLmdbBackground)]
    if len(sBatchSizes) > 3:
        raise ValueError("len(sBatchSizes) > 3!")
    else:
        if len(sBatchSizes) > 1:
            transformParamDome = eval(repr(transformParams[0]))
            # transformParamDome['model'] = 'DOME_' + str(sNumberKeyPoints) + '_19'
            transformParamDome['model'] = 'DOME_' + str(sNumberKeyPoints)
            transformParamDome['media_directory'] = '/media/posefs0c/panopticdb/body_foot/'
            transformParams = transformParams + [transformParamDome]
            transformParamDome['max_rotate_degree'] = 180
            transformParamDome['scale_min'] = 0.3
        if len(sBatchSizes) > 2:
            transformParamDome = eval(repr(transformParams[0]))
            transformParamDome['model'] = 'COCO_' + str(sNumberKeyPoints) + '_18'
            transformParams = transformParams + [transformParamDome]
            transformParams[0]['max_rotate_degree'] = 180
            transformParams[0]['scale_min'] = 0.3
    if not os.path.exists(sTrainingFolder):
        os.makedirs(sTrainingFolder)

    # Original/fast versions
    # First stage             ----------------------- VGG 19 ----------------------- --------------------------------------------------- CPM ---------------------------------------------------
    layerName               = ['V','V','P'] * 2  +  ['V'] * 4 + ['P']  +  ['V'] * 2 + ['C'] * 2     + ['$'] + ['C2'] * 3 + ['C2'] * 2                       + ['L2']
    kernel                  = [ 3,  3,  2 ] * 2  +  [ 3 ] * 4 + [ 2 ]  +  [ 3 ] * 2 + [ 3 ] * 2     + [ 0 ] + [ 3 ] * 3  + [ 1 ] * 2                        + [ 0 ]
    numberOutputChannels    = [64]*3 + [128]* 3  +  [256] * 4 + [256]  +  [512] * 2 + [256] + [128] + [ 0 ] + [128] * 3  + [512] + [sNumberTotalParts*2]    + [ 0 ]
    # numberOutputChannels    = [64]*3 + [128]* 3  +  [256] * 4 + [256]  +  [512] * 2 + [256] + [128] + [ 0 ] + [128] * 3  + [256] + [sNumberTotalParts*2]    + [ 0 ] # Super-fast version 1/2
    # numberOutputChannels    = [64]*3 + [128]* 3  +  [256] * 4 + [256]  +  [512] * 2 + [256] + [128] + [ 0 ] + [128] * 3  + [128] + [sNumberTotalParts*2]    + [ 0 ] # Super-fast version 2/2
    stride                  = [ 1 , 1,  2 ] * 2  +  [ 1 ] * 4 + [ 2 ]  +  [ 1 ] * 2 + [ 1 ] * 2     + [ 0 ] + [ 1 ] * 3  + [ 1 ] * 2                        + [ 0 ]

    # # Super-fast version
    # # First stage             ----------------------- VGG 19 ----------------------- --------------------------------------------------- CPM ---------------------------------------------------
    # layerName               = ['V','V','P'] * 2  +  ['V'] * 4 + ['P']  +  ['V'] * 2 + ['C'] * 2     + ['$'] + ['C2'] * 2 + ['C2']                   + ['L2']
    # kernel                  = [ 3,  3,  2 ] * 2  +  [ 3 ] * 4 + [ 2 ]  +  [ 3 ] * 2 + [ 3 ] * 2     + [ 0 ] + [ 3 ] * 2  + [ 1 ]                    + [ 0 ]
    # numberOutputChannels    = [64]*3 + [128]* 3  +  [256] * 4 + [256]  +  [512] * 2 + [256] + [128] + [ 0 ] + [128] * 2  + [sNumberTotalParts*2]    + [ 0 ]
    # stride                  = [ 1 , 1,  2 ] * 2  +  [ 1 ] * 4 + [ 2 ]  +  [ 1 ] * 2 + [ 1 ] * 2     + [ 0 ] + [ 1 ] * 2  + [ 1 ]                    + [ 0 ]

    # Stages 2-sNumberStages   ----------------------------------------- CPM + PAF -----------------------------------------
    nodesPerLayer = 5+2
    for s in range(2, sNumberStages+1):
        layerName               += ['@'] + ['C2'] * nodesPerLayer                               +  ['L2']
        kernel                  += [ 0 ] + [ 7 ] * (nodesPerLayer-2) + [1,1]                    +  [ 0 ]
        numberOutputChannels    += [ 0 ] + [128] * (nodesPerLayer-1) + [sNumberTotalParts*2]    +  [ 0 ] # Original CPM + PAF
        # numberOutputChannels    += [ 0 ] + [64] * (nodesPerLayer-1) + [sNumberTotalParts*2]     +  [ 0 ] # (Super-)Fast version
        # numberOutputChannels    += [ 0 ] + [32] * (nodesPerLayer-1) + [sNumberTotalParts*2]     +  [ 0 ] # Super-fast version
        stride                  += [ 0 ] + [ 1 ] * nodesPerLayer                                +  [ 0 ]

    # Create folders where saving
    if not os.path.exists(sTrainingFolder):
        os.makedirs(sTrainingFolder)
    if not os.path.exists(sTrainedModelsFolder): # for storing Caffe models
        os.makedirs(sTrainedModelsFolder)

    writePrototxts(sLmdbFolders, sTrainingFolder, sBatchSizes, layerName, kernel, stride, numberOutputChannels,
                   transformParams, sLearningRateInit, sTrainedModelsFolder, sNumberTotalParts, sLabelName, sBatchNorm, sLearningRateMultDistro)

# NOTE - Speeds
    # Original: slow
    # Fast version: +30%
    # Super-fast version: +XX%
