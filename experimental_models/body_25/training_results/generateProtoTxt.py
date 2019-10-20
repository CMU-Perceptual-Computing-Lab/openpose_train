## Path parameters
import math
import os
import sys
from getResNetProtoTxt import getResNet50Init, getResNet50Init

## Fixed parameters
sKeypointLevel = 0
sPafLevel = -(sKeypointLevel-1)     # 0 or 1, depending on sKeypointLevel = 1 or 0
# `heat` in [2*n+sKeypointLevel] positions, `vec` in [2*n+sPafLevel] positions
# If sKeypointLevel is changed, sLabelName must also be swapped
sLabelName = ['label_heat', 'label_vec', 'heat_weight', 'vec_weight', 'heat_temp', 'vec_temp']



def generateProtoTxt(dataFolders, trainingFolder, batchSizes, layerName, kernel, stride, numberOutputChannels,
                     transformParams, learningRateInit, trainedModelsFolder, numberKeyPoints, numberPAFs,
                     batchNorm, binaryConv, lrMultDistro, caffeFolder, pretrainedModelPath, isFinalModel,
                     numberIterations, maximumPafStage, usePReLU, extraGT, footParts, footPAFs):
    # pose_training.prototxt - Training prototxt
    stringToWrite = setLayersTwoBranches(dataFolders, batchSizes, layerName, kernel, stride, numberOutputChannels,
                                         numberKeyPoints, numberPAFs, sLabelName, transformParams, False, batchNorm,
                                         binaryConv, lrMultDistro, caffeFolder, isFinalModel, maximumPafStage,
                                         usePReLU, extraGT, footParts, footPAFs)
    with open('%s/pose_training.prototxt' % trainingFolder, 'w') as f:
        f.write(stringToWrite)

    # pose_deploy.prototxt - Deployment prototxt
    stringToWrite = setLayersTwoBranches([], [], layerName, kernel, stride, numberOutputChannels, 
                                         numberKeyPoints, numberPAFs, sLabelName, transformParams, True, batchNorm,
                                         binaryConv, lrMultDistro, caffeFolder, isFinalModel, maximumPafStage,
                                         usePReLU, extraGT, footParts, footPAFs)
    with open('%s/pose_deploy.prototxt' % trainingFolder, 'w') as f:
        f.write(stringToWrite)

    # solver.prototxt - Solver parameters
    solverString = getSolverPrototxt(learningRateInit, numberIterations, trainedModelsFolder)
    with open('%s/pose_solver.prototxt' % trainingFolder, "w") as f:
        f.write('%s' % solverString)

    # train_pose.sh - Training script
    bashString = getBash(caffeFolder, pretrainedModelPath)
    with open('%s/train_pose.sh' % trainingFolder, "w") as f:
        f.write('%s' % bashString)

    # Resume training
    resumedBashString = getResumeBash(caffeFolder)
    with open('%s/resume_train_pose.sh' % trainingFolder, "w") as f:
        f.write('%s' % resumedBashString)



def bilinearUpsampling(factor, numberChannels, deconvName, L, caffeNet, lastLayer, deploy, lr_mult = 0):
    # Deconvolution layer
    # http://caffe.berkeleyvision.org/doxygen/classcaffe_1_1BilinearFiller.html#details
    # layer {
    #   name: "upsample", type: "Deconvolution"
    #   bottom: "{{bottom_name}}" top: "{{top_name}}"
    #   convolution_param {
    #     kernel_size: {{2 * factor - factor % 2}} stride: {{factor}}
    #     num_output: {{C}} group: {{C}}
    #     pad: {{ceil((factor - 1) / 2.)}}
    #     weight_filler: { type: "bilinear" } bias_term: false
    #   }
    #   param { lr_mult: 0 decay_mult: 0 }
    # }
    caffeNet.tops[deconvName] = L.Deconvolution(caffeNet.tops[lastLayer],
        convolution_param=dict(
            num_output=numberChannels, group=numberChannels,
            kernel_size=2*factor-(factor%2), stride=factor,
            pad=int(math.ceil((factor-1)/2.0)),
            weight_filler=dict(type='bilinear'), bias_term=False
        ),
        # param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)],
        param=[dict(lr_mult=lr_mult, decay_mult=1)],
    )
    # Verbose
    if not deploy:
        print '%s\tch=%d' % (deconvName, numberChannels)



def setLayersTwoBranches(dataFolders, batchSizes, layerName, kernel, stride, numberOutputChannels,
                         numberKeyPoints, numberPAFs, labelName, transformParams, deploy, batchNorm, binaryConv,
                         lrMultDistro, caffeFolder, isFinalModel, maximumPafStage, usePReLU, extraGT,
                         footParts, footPAFs):
    # Caffe includes
    sys.path.insert(0, os.path.join(caffeFolder, 'python'))
    import caffe
    from caffe import layers as L  # pseudo module using __getattr__ magic to generate protobuf messages
    from caffe import params as P  # pseudo module using __getattr__ magic to generate protobuf messages
    # Producing training and testing prototxt files is pretty straightforward
    caffeNet = caffe.NetSpec()
    assert len(layerName) == len(kernel)
    assert len(layerName) == len(stride)
    assert len(layerName) == len(numberOutputChannels)
    numberTotalParts = numberKeyPoints + footParts + numberPAFs + footPAFs

    # Testing/deployment mode
    if deploy:
        # It is tricky to produce the deploy prototxt file, as the data input is not from a layer, so we have to
        # create a workaround
        input = "image"
        dim1 = 1
        dim2 = 3
        dim3 = 16 # Reshaped on runtime
        dim4 = 16 # Reshaped on runtime
        # Make an empty "data" layer so the next layer accepting input will be able to take the correct blob name
        # "data", we will later have to remove this layer from the serialization string, since this is just a
        # placeholder
        caffeNet.image = L.Layer()
    # Training mode - Use lmdb
    else:
        if len(batchSizes) != len(dataFolders):
            raise ValueError("len(batchSizes) != len(dataFolders)!")
        # If not merging different datasets
        if len(batchSizes) == 1:
            if extraGT:
                caffeNet.image, caffeNet.tops['label'], caffeNet.tops['label_2'] = L.OPData(
                    data_param=dict(backend=1, source=dataFolders[0],
                    batch_size=batchSizes[0]), op_transform_param=transformParams[0], ntop=3)
            else:
                caffeNet.image, caffeNet.tops['label'] = L.OPData(
                    data_param=dict(backend=1, source=dataFolders[0],
                    batch_size=batchSizes[0]), op_transform_param=transformParams[0], ntop=2)
        # If merging different datasets
        else: # if len(batchSizes) > 1:
            for index in range(0, len(batchSizes)):
                # Lmdb i
                caffeNet.tops['data' + str(index)], caffeNet.tops['label' + str(index)] = L.OPData(
                    data_param=dict(backend=1, source=dataFolders[index], batch_size=batchSizes[index]),
                    op_transform_param=transformParams[index], ntop=2
                )
            if len(batchSizes) == 2:
                caffeNet.image = L.Concat(caffeNet.tops['data0'], caffeNet.tops['data1'], concat_param=dict(axis=0))
                caffeNet.tops['label'] = L.Concat(caffeNet.tops['label0'], caffeNet.tops['label1'],
                                                  concat_param=dict(axis=0))
            # If merging different datasets
            elif len(batchSizes) == 3:
                # Dataset concat layer
                caffeNet.image = L.Concat(caffeNet.tops['data0'], caffeNet.tops['data1'], caffeNet.tops['data2'],
                                          concat_param=dict(axis=0))
                caffeNet.tops['label'] = L.Concat(caffeNet.tops['label0'], caffeNet.tops['label1'],
                                                  caffeNet.tops['label2'], concat_param=dict(axis=0))
            else:
                raise ValueError("Wrong batchSizes size.")
        # Slice layer
        if footParts + footPAFs > 0:
            temp = '_temp'
        else:
            temp = ''
        caffeNet.tops[labelName[3]+temp], caffeNet.tops[labelName[2]+temp], caffeNet.tops[labelName[5]+temp], caffeNet.tops[labelName[4]+temp] = L.Slice(
            caffeNet.label,
            slice_param=dict(axis=1, slice_point=[numberPAFs+footPAFs, numberTotalParts+1, numberTotalParts+numberPAFs+footPAFs+1]),
            ntop=4
        )
        # Crop foot part (ignore body annotations)
        if footParts + footPAFs > 0:
            for index in range(2,6):
                footNumber = (index%2==0)*footParts + (index%2==1)*footPAFs
                bodyNumber = (index%2==0)*numberKeyPoints + (index%2==1)*numberPAFs
                print footNumber
                print bodyNumber
                if index%2==0:
                    caffeNet.tops[labelName[index]+'_1'], caffeNet.tops[labelName[index]], caffeNet.tops[labelName[index]+'_2'] = L.Slice(
                        caffeNet.tops[labelName[index]+temp],
                        slice_param=dict(axis=1, slice_point=[bodyNumber,bodyNumber+footNumber]),
                        ntop=3
                    )
                    caffeNet.tops[labelName[index]+'_silent2'] = L.Silence(caffeNet.tops[labelName[index]+'_2'], ntop=0)
                else:
                    caffeNet.tops[labelName[index]+'_1'], caffeNet.tops[labelName[index]] = L.Slice(
                        caffeNet.tops[labelName[index]+temp],
                        slice_param=dict(axis=1, slice_point=[bodyNumber]),
                        ntop=2
                    )
                caffeNet.tops[labelName[index]+'_silent1'] = L.Silence(caffeNet.tops[labelName[index]+'_1'], ntop=0)

        # extraGT
        if extraGT and (footParts + footPAFs > 0):
            raise ValueError("Not implemented for this case.")
        if extraGT:
            caffeNet.tops[labelName[3]+'_2'], caffeNet.tops[labelName[2]+'_2'], caffeNet.tops[labelName[5]+'_2'], caffeNet.tops[labelName[4]+'_2'] = L.Slice(
                caffeNet.tops['label_2'],
                slice_param=dict(axis=1, slice_point=[numberPAFs+footPAFs, numberTotalParts+1, numberTotalParts+numberPAFs+footPAFs+1]),
                ntop=4
            )
        # 2 Eltwise layers
        for level in range(0,2):
            caffeNet.tops[labelName[level]] = L.Eltwise(caffeNet.tops[labelName[level+2]],
                                                        caffeNet.tops[labelName[level+4]],
                                                        operation=P.Eltwise.PROD)
            if extraGT:
                caffeNet.tops[labelName[level]+'_2'] = L.Eltwise(caffeNet.tops[labelName[level+2]+'_2'],
                                                                 caffeNet.tops[labelName[level+4]+'_2'],
                                                                 operation=P.Eltwise.PROD)

        # something special before everything
        # caffeNet.image = caffeNet.data
        # caffeNet.image, caffeNet.center_map = L.Slice(
        #     caffeNet.data, slice_param=dict(axis=1, slice_point=3), ntop=2)
        # caffeNet.silence2 = L.Silence(caffeNet.center_map, ntop=0)
        # caffeNet.pool_center_lower = L.Pooling(
        #     caffeNet.center_map, kernel_size=9, stride=8, pool=P.Pooling.AVE)

    # just follow arrays..CPCPCPCPCCCC....
    lastLayer = 'image'
    lastLayerL1 = ''
    lastLayerL1f = ''
    lastLayerL1h = ''
    lastLayerL2 = ''
    lastLayerL2f = ''
    lastLayerL2h = ''
    lastLayerL3 = ''
    lastLayerL3f = ''
    lastLayerL3h = ''
    stage = 0
    convCounter = 1
    poolCounter = 1
    dropCounter = 1
    localCounter = 1
    state = 'image' # can be image or fuse
    sharePoint = 0
    skipConnectionCounter = 0
    skipConnectionLastStage = -1
    vggLastLayers = []
    vggLastLayersIndex = 0
    for l in range(0, len(layerName)):
        # Convolution layers
        if layerName[l] == 'V': #pretrained VGG layers
            convName = 'conv%d_%d' % (poolCounter, localCounter)
            lr_m = lrMultDistro[0] * (isFinalModel or stage == maximumPafStage)
            caffeNet.tops[convName] = L.Convolution(
                caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
                pad=int(math.floor(kernel[l]/2)),
                param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)],
                weight_filler=dict(type='gaussian', std=0.01), bias_filler=dict(type='constant'))
            lastLayer = convName
            if not deploy:
                print '%s\tch=%d\t%.1f' % (lastLayer, numberOutputChannels[l], lr_m)
            ReLUname = 'relu%d_%d' % (poolCounter, localCounter)
            # PReLU
            if (usePReLU and layerName[l+1][0] == 'C'):
                ReLUname = 'p' + ReLUname
                caffeNet.tops[ReLUname] = L.PReLU(caffeNet.tops[lastLayer], param=[dict(lr_mult=lrMultDistro[0], decay_mult=1)], in_place=True)
            # ReLU
            else:
                caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
            localCounter += 1
            if not deploy:
                print ReLUname
        elif layerName[l] == 'B':
            poolCounter += 1
            localCounter = 1
        # Convolution layers
        elif layerName[l] == 'C':
            if state == 'image':
                convName = 'conv%d_%d_CPM' % (poolCounter, localCounter) # no image state in subsequent stages
                lr_m = lrMultDistro[1] * (isFinalModel or stage == maximumPafStage)
            else: # fuse
                convName = 'Mconv%d_stage%d' % (convCounter, stage)
                lr_m = lrMultDistro[2] * (isFinalModel or stage == maximumPafStage)
                convCounter += 1
            #if stage == 1:
            #    lr_m = 1 * (isFinalModel or stage == maximumPafStage)
            #else:
            #    lr_m = lr_sub * (isFinalModel or stage == maximumPafStage)
            addBatchNorm = (batchNorm == 1 and layerName[l+1][0] != 'L')
            addBinaryLayer = (binaryConv and (layerName[l+1][0] != 'L' and kernel[l] > 1))

            # # Binary BN + Scale + ReLU
            # if addBinaryLayer:
            #     if state == 'image':
            #         batchNormName = 'bn%d_%d_CPM_2' % (poolCounter, localCounter)
            #         # caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=not addBinaryLayer)
            #         caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
            #         scaleNormName = 'scale%d_%d_CPM_2' % (poolCounter, localCounter)
            #         caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
            #         lastLayer = scaleNormName
            #         if not deploy:
            #             print batchNormName
            #             print scaleNormName
            #         ReLUname = 'bin_act%d_%d_CPM' % (poolCounter, localCounter)
            #         # caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
            #         caffeNet.tops[ReLUname] = L.BinaryActivation(caffeNet.tops[lastLayer], in_place=True)
            #     else:
            #         batchNormName = 'Mbn%d_stage%d_2' % (convCounter, stage)
            #         # caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=not addBinaryLayer)
            #         caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
            #         scaleNormName = 'Mscale%d_stage%d_2' % (convCounter, stage)
            #         caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
            #         lastLayer = scaleNormName
            #         if not deploy:
            #             print batchNormName
            #             print scaleNormName
            #         ReLUname = 'Mbin_act%d_stage%d' % (convCounter, stage)
            #         caffeNet.tops[ReLUname] = L.BinaryActivation(caffeNet.tops[lastLayer], in_place=True)

            if addBatchNorm:
                caffeNet.tops[convName] = L.Convolution(
                    caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
                    pad=int(math.floor(kernel[l]/2)),
                    param=[dict(lr_mult=lr_m, decay_mult=1)],
                    # weight_filler=dict(type='gaussian', std=0.01), bias_term=False)
                    weight_filler=dict(type='xavier'), bias_term=False)
                    # weight_filler=dict(type='msra'), bias_term=False)
            elif addBinaryLayer:
                caffeNet.tops[convName] = L.Convolution(
                    caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
                    pad=int(math.floor(kernel[l]/2)),
                    param=[dict(lr_mult=lr_m, decay_mult=0), dict(lr_mult=lr_m*2, decay_mult=0)], binary=3,
                    # param=[dict(lr_mult=lr_m, decay_mult=1)], binary=True)
                    # weight_filler=dict(type='gaussian', std=0.01), bias_term=False)
                    weight_filler=dict(type='xavier'), bias_filler=dict(type='constant'))
                    # weight_filler=dict(type='xavier'), bias_term=False)
                    # weight_filler=dict(type='msra'), bias_term=False)
            else:
                caffeNet.tops[convName] = L.Convolution(
                    caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
                    pad=int(math.floor(kernel[l]/2)),
                    param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)],
                    # weight_filler=dict(type='gaussian', std=0.01), bias_filler=dict(type='constant'))
                    weight_filler=dict(type='xavier'), bias_filler=dict(type='constant'))
                    # weight_filler=dict(type='msra'), bias_filler=dict(type='constant'))
            lastLayer = convName
            # if not addBinaryLayer:
            #     lastLayer = convName
            if not deploy:
                print '%s\tch=%d\t%.1f' % (lastLayer, numberOutputChannels[l], lr_m)
            # ReLU (+ BatchNorm) layers
            if layerName[l+1] != 'L':
                if state == 'image':
                    # BN + Scale + ReLU
                    # if addBatchNorm or addBinaryLayer:
                    if addBatchNorm:
                        batchNormName = 'bn%d_%d_CPM' % (poolCounter, localCounter)
                        caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                        scaleNormName = 'scale%d_%d_CPM' % (poolCounter, localCounter)
                        caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                        lastLayer = scaleNormName
                        if not deploy:
                            print batchNormName
                            print scaleNormName
                    ReLUname = 'relu%d_%d_CPM' % (poolCounter, localCounter)
                    # PReLU
                    if usePReLU:
                        ReLUname = 'p' + ReLUname
                        caffeNet.tops[ReLUname] = L.PReLU(caffeNet.tops[lastLayer], param=[dict(lr_mult=lrMultDistro[0], decay_mult=1)], in_place=True)
                    # ReLU
                    else:
                        caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
                    lastLayer = ReLUname
                    # if addBinaryLayer:
                    #     batchNormName = 'bn%d_%d_CPM' % (poolCounter, localCounter)
                    #     caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                    #     scaleNormName = 'scale%d_%d_CPM' % (poolCounter, localCounter)
                    #     caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                    #     lastLayer = scaleNormName
                    #     if not deploy:
                    #         print batchNormName
                    #         print scaleNormName
                else:
                    # BN + Scale + ReLU
                    # if addBatchNorm or addBinaryLayer:
                    if addBatchNorm:
                        batchNormName = 'Mbn%d_stage%d' % (convCounter, stage)
                        caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                        scaleNormName = 'Mscale%d_stage%d' % (convCounter, stage)
                        caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                        lastLayer = scaleNormName
                        if not deploy:
                            print batchNormName
                            print scaleNormName
                    # PReLU
                    if usePReLU:
                        ReLUname = 'Mprelu%d_stage%d' % (convCounter, stage)
                        caffeNet.tops[ReLUname] = L.PReLU(caffeNet.tops[lastLayer], param=[dict(lr_mult=lrMultDistro[0], decay_mult=1)], in_place=True)
                    # ReLU
                    else:
                        ReLUname = 'Mrelu%d_stage%d' % (convCounter, stage)
                        caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
                    lastLayer = ReLUname
                    # if addBinaryLayer:
                    #     batchNormName = 'Mbn%d_stage%d' % (convCounter, stage)
                    #     caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                    #     scaleNormName = 'Mscale%d_stage%d' % (convCounter, stage)
                    #     caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                    #     lastLayer = scaleNormName
                    #     if not deploy:
                    #         print batchNormName
                    #         print scaleNormName
                # lastLayer = ReLUname
                if not deploy:
                    print ReLUname
            # if addBinaryLayer:
            #     caffeNet.tops[convName] = L.Convolution(
            #         caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
            #         pad=int(math.floor(kernel[l]/2)),
            #         weight_filler=dict(type='xavier'), bias_term=False,
            #         # weight_filler=dict(type='msra'), bias_term=False,
            #         param=[dict(lr_mult=lr_m, decay_mult=0)], binary=True)
            #         # param=[dict(lr_mult=lr_m, decay_mult=1)], binary=True)
            #     lastLayer = convName

            #convCounter += 1
            localCounter += 1
        # Deconvolution layers
        elif layerName[l] == 'U1' or layerName[l] == 'U2' or layerName[l] == 'U1d' or layerName[l] == 'U2d' or layerName[l] == 'U':
            if layerName[l] == 'U':
                # for level in range(0, 2):
                factor = 4
                numberChannels = numberOutputChannels[l]
                # deconvName = 'Mdeconv%d_stage%d_L%d' % (convCounter, stage, level+1)
                deconvName = 'net_output'# + ('_' + str(level)) * (level < 2)
                bilinearUpsampling(factor, numberChannels, deconvName, L, caffeNet, lastLayer, deploy, lrMultDistro[4])
                lastLayer = deconvName
            else:
                if layerName[l][-1] != 'd' or deploy:
                    # Information
                    if layerName[l][1] == '1':
                        lastLayerDeconv = lastLayerL1
                        level = 0
                    elif layerName[l][1] == '2':
                        lastLayerDeconv = lastLayerL2
                        level = 1
                    # elif layerName[l][1] == '3':
                    #     lastLayerDeconv = lastLayerL3
                    #     level = 2
                    else:
                        raise ValueError("Wrong level selected.")
                    # Layer name
                    if state == 'image':
                        # No image state in subsequent stages
                        convName = 'conv%d_%d_CPM_L%d' % (poolCounter, localCounter, level+1)
                        convName = 'de' + convName
                        lr_m = lrMultDistro[1] * (isFinalModel or (stage == maximumPafStage or level == 0))
                    else: # fuse
                        convName = 'Mconv%d_stage%d_L%d' % (convCounter, stage, level+1)
                        convName = convName[0] + 'de' + convName[1:]
                        lr_m = lrMultDistro[2] * (isFinalModel or (stage == maximumPafStage or level == 0))
                    # Deconvolution layer
                    # http://caffe.berkeleyvision.org/doxygen/classcaffe_1_1BilinearFiller.html#details
                    # layer {
                    #   name: "upsample", type: "Deconvolution"
                    #   bottom: "{{bottom_name}}" top: "{{top_name}}"
                    #   convolution_param {
                    #     kernel_size: {{2 * factor - factor % 2}} stride: {{factor}}
                    #     num_output: {{C}} group: {{C}}
                    #     pad: {{ceil((factor - 1) / 2.)}}
                    #     weight_filler: { type: "bilinear" } bias_term: false
                    #   }
                    #   param { lr_mult: 0 decay_mult: 0 }
                    # }
                    caffeNet.tops[convName] = L.Deconvolution(caffeNet.tops[lastLayerDeconv],
                        convolution_param=dict(
                            num_output=numberOutputChannels[l], group=numberOutputChannels[l],
                            kernel_size=2*stride[l]-(stride[l]%2), stride=stride[l],
                            pad=int(math.ceil((stride[l]-1)/2.0)),
                            weight_filler=dict(type='bilinear'), bias_term=False
                        ),
                        # param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)],
                        param=[dict(lr_mult=0, decay_mult=0)],
                    )
                    # Update last layer
                    lastLayer = convName
                    # Verbose
                    if not deploy:
                        print '%s\tch=%d\t%.1f' % (lastLayer, numberOutputChannels[l], lr_m)
                    convCounter += 1
                    localCounter += 1
        # Convolution layers - 'C1', 'C2', 'C3', 'C1f', 'C2f', 'C3f', 'C1h', 'C2h', 'C3h', ...
        elif (layerName[l][0] == 'C' and layerName[l][1] >= '0' and layerName[l][1] <= '9'):
            if layerName[l][1] == '1':
                level = 0
            elif layerName[l][1] == '2':
                level = 1
            elif layerName[l][1] == '3':
                level = 2
            else:
                raise ValueError("Wrong level selected.")

            # Special cases: foot, hand
            isFoot = (layerName[l][-1] == 'f')
            isHand = (layerName[l][-1] == 'h')
            if isFoot:
                init = 'Foot_'
            elif isHand:
                init = 'Hand_'
            else:
                init = ''

            if state == 'image':
                # No image state in subsequent stages
                convName = 'conv%d_%d_CPM_L%d' % (poolCounter, localCounter, level+1)
                lr_m = lrMultDistro[1] * (isFinalModel or (stage == maximumPafStage or level == 0))
            else: # fuse
                convName = init + 'Mconv%d_stage%d_L%d' % (convCounter, stage, level+1)
                lr_m = lrMultDistro[2+2*(isFoot or isHand)] * (isFinalModel or (stage == maximumPafStage or level == 0))
            if not isFinalModel and level == 0:
                convName += '_temp'
                #convCounter += 1
            #if stage == 1:
            #    lr_m = 1 * (isFinalModel or (stage == maximumPafStage or level == 0))
            #else:
            #    lr_m = lr_sub * (isFinalModel or (stage == maximumPafStage or level == 0))
            if numberOutputChannels[l] == 0:
                raise ValueError("Number output channels can't be 0!")

            if layerName[l+1][0] == 'L' and numberOutputChannels[l] == 0:
                if level == sKeypointLevel:
                    lastLayerES = lastLayerL1
                elif level == sPafLevel:
                    lastLayerES = lastLayerL2
                elif level == sDistanceLevel:
                    lastLayerES = lastLayerL3
                else:
                    raise ValueError("Wrong level selected.")
                concatPreviousLoss = (layerName[l+1][-1] == 'c')
            else:
                concatPreviousLoss = False
            # addBatchNorm = (batchNorm == 1 and layerName[l+1][0] != 'L' and ((convCounter % 2 == 0 and not kernel[l+1] == 1) or kernel[l] == 1))
            addBatchNorm = (batchNorm == 1 and layerName[l+1][0] != 'L')
            addBinaryLayer = (binaryConv and (layerName[l+1][0] != 'L' and kernel[l] > 1))
            if addBinaryLayer:
                raise ValueError("AddBinaryLayer not (fully) implemented for C1, C2, C3, etc.")

            # Convolution
            stdValue = 0.01
            # if (vggLastLayersIndex < len(vggLastLayers) - 1):
            #     stdValue /= 2
            # Size_o = (size_in - kernel + 2 pad)/stride - 1
            # https://stackoverflow.com/questions/39631763/how-to-set-the-params-of-deconvolution-in-caffe-prototxt
            if addBatchNorm:
                caffeNet.tops[convName] = L.Convolution(
                    caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
                    pad=int(math.floor(kernel[l]/2)),
                    # weight_filler=dict(type='gaussian', std=stdValue), bias_term=False,
                    weight_filler=dict(type='xavier'), bias_term=False,
                    # weight_filler=dict(type='msra'), bias_term=False,
                    param=[dict(lr_mult=lr_m, decay_mult=1)])
            else:
                caffeNet.tops[convName] = L.Convolution(
                    caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
                    pad=int(math.floor(kernel[l]/2)),
                    # weight_filler=dict(type='gaussian', std=stdValue), bias_filler=dict(type='constant'),
                    weight_filler=dict(type='xavier'), bias_filler=dict(type='constant'),
                    # weight_filler=dict(type='msra'), bias_filler=dict(type='constant'),
                    param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)])
            # Update last layer
            lastLayer = convName
            # if not addBinaryLayer: # Only for C1
            #     lastLayer = convName
            # Verbose
            if not deploy:
                print '%s\tch=%d\t%.1f' % (lastLayer, numberOutputChannels[l], lr_m)

            if layerName[l+1][0] != 'L':
                if state == 'image':
                    # if batchNorm == 1:
                    #     batchNormName = 'bn%d_stage%d_L%d' % (convCounter, stage, level+1)
                    #     caffeNet.tops[batchNormName] = L.BatchNorm(
                    #         caffeNet.tops[lastLayer], param=[dict(lr_mult=0), dict(lr_mult=0), dict(lr_mult=0)])
                    #         #scale_filler=dict(type='constant', value=1), shift_filler=dict(type='constant', value=0.001))
                    #     lastLayer = batchNormName
                    ReLUname = 'relu%d_%d_CPM_L%d' % (poolCounter, localCounter, level+1)
                else:
                    # if addBatchNorm or addBinaryLayer:
                    if addBatchNorm:
                        batchNormName = 'Mbn%d_stage%d_L%d' % (convCounter, stage, level+1)
                        caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                        scaleNormName = 'Mscale%d_stage%d_L%d' % (convCounter, stage, level+1)
                        caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                        lastLayer = scaleNormName
                        if not deploy:
                            print batchNormName
                            print scaleNormName
                    ReLUname = 'Mrelu%d_stage%d_L%d' % (convCounter, stage, level+1)
                if not isFinalModel and level == 0:
                    ReLUname += '_temp'
                # PReLU
                if usePReLU:
                    if state == 'image':
                        ReLUname = 'p' + ReLUname
                    else:
                        ReLUname = 'Mp' + ReLUname[1:]
                    ReLUname = init + ReLUname
                    caffeNet.tops[ReLUname] = L.PReLU(caffeNet.tops[lastLayer], param=[dict(lr_mult=lrMultDistro[0], decay_mult=1)], in_place=True)
                # ReLU
                else:
                    ReLUname = init + ReLUname
                    caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
                # Rest
                if not deploy:
                    print ReLUname
                lastLayer = ReLUname
            else:
                # Concat previous
                if concatPreviousLoss:
                    concatName = lastLayer + '_eltwise_sum'
                    caffeNet.tops[concatName] = L.Eltwise(caffeNet.tops[lastLayer], caffeNet.tops[lastLayerES],
                                                          operation=P.Eltwise.SUM, coeff=[1.0,0.5])
                    # caffeNet.tops[concatName] = L.Concat(caffeNet.tops[lastLayer], caffeNet.tops[lastLayerES],
                    #                                      caffeNet.tops[convName+"_2"], concat_param=dict(axis=1))
                    lastLayer = concatName
            # if addBinaryLayer: # Only for C1
            #     caffeNet.tops[convName] = L.Convolution(
            #         caffeNet.tops[lastLayer], kernel_size=kernel[l], num_output=numberOutputChannels[l],
            #         pad=int(math.floor(kernel[l]/2)),
            #         # weight_filler=dict(type='gaussian', std=stdValue), bias_term=False,
            #         weight_filler=dict(type='xavier'), bias_term=False,
            #         # weight_filler=dict(type='msra'), bias_filler=dict(type='constant'),
            #         param=[dict(lr_mult=lr_m, decay_mult=0)], binary=True)
            #         # param=[dict(lr_mult=lr_m, decay_mult=1)], binary=True)
            #     lastLayer = convName

            convCounter += 1
            localCounter += 1
        # Skip connection
        elif layerName[l] == 'SC1' or layerName[l] == 'SC2' or layerName[l] == 'SC3':
            if layerName[l][-1] == '1':
                level = 0
            elif layerName[l][-1] == '2':
                level = 1
            # elif layerName[l][-1] == '3':
            #     level = 2
            else:
                raise ValueError("Wrong level selected.")

            convName = 'Mconv%d_stage%d_L%d' % (convCounter, stage, level+1)
            lr_m = lrMultDistro[2] * (isFinalModel or (stage == maximumPafStage or level == 0))
            if not isFinalModel and level == 0:
                convName += '_temp'

            # BN + ReLU
            originalLayer = lastLayer
            if convCounter != 1:
                batchNormName = 'Mbn%d_stage%d_L%d' % (convCounter, stage, level+1)
                caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer])
                scaleNormName = 'MScale%d_stage%d_L%d' % (convCounter, stage, level+1)
                caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                ReLUname = 'relu%d_stage%d_L%d' % (convCounter, stage, level+1)
                caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[scaleNormName], in_place=True)
                lastLayer = ReLUname
                if not deploy:
                    print batchNormName
                    print scaleNormName
                    print ReLUname

            if layerName[l+1][0] == 'L':
                raise ValueError("Loss layer should not be after SC.")
            factorOutput = 2

            for index in range(0,3):
                if index == 0:
                    bottomConvName = lastLayer
                else:
                    bottomConvName = convName + "_" + str(index-1)
                subConvName = convName + "_" + str(index)
                # kernel[l] = 7
                kernelOne = 1
                if index == 2:
                    caffeNet.tops[subConvName] = L.Convolution(
                        caffeNet.tops[bottomConvName], kernel_size=kernelOne, num_output=factorOutput*numberOutputChannels[l],
                        pad=int(math.floor(kernelOne/2)),
                        # weight_filler=dict(type='gaussian', std=0.01), bias_term=False,
                        weight_filler=dict(type='xavier'), bias_term=False,
                        param=[dict(lr_mult=lr_m, decay_mult=1)])
                else:
                    if index == 0:
                        kernelI = 1
                    else:
                        kernelI = kernel[l]
                    caffeNet.tops[subConvName] = L.Convolution(
                        caffeNet.tops[bottomConvName], kernel_size=kernelI, num_output=numberOutputChannels[l],
                        pad=int(math.floor(kernelI/2)),
                        # weight_filler=dict(type='gaussian', std=0.01), bias_filler=dict(type='constant'),
                        weight_filler=dict(type='xavier'), bias_filler=dict(type='constant'),
                        param=[dict(lr_mult=lr_m, decay_mult=1), dict(lr_mult=lr_m*2, decay_mult=0)])
                lastLayer = subConvName
                if not deploy:
                    print '%s\tch=%d\t%.1f' % (lastLayer, numberOutputChannels[l], lr_m)

                if index != 2:
                    if state == 'image':
                        ReLUname = 'relu%d_%d_CPM_L%d_%d' % (poolCounter, localCounter, level+1, index)
                    else:
                        ReLUname = 'Mrelu%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                    if not isFinalModel and level == 0:
                        ReLUname += '_temp'
                    caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
                    if not deploy:
                        print ReLUname
            # Reshape conv?
            if convCounter == 1:
                reshapeConvName = 'reshapeConv%d_stage%d_L%d' % (convCounter, stage, level+1)
                kernelReshape = 1
                caffeNet.tops[reshapeConvName] = L.Convolution(
                    caffeNet.tops[originalLayer], kernel_size=kernelReshape, num_output=factorOutput*numberOutputChannels[l],
                    pad=int(math.floor(kernelReshape/2)),
                    # weight_filler=dict(type='gaussian', std=0.01), bias_term=False,
                    weight_filler=dict(type='xavier'), bias_term=False,
                    param=[dict(lr_mult=lr_m, decay_mult=1)])
                lastLayer = reshapeConvName
                if not deploy:
                    print reshapeConvName
                originalLayer = reshapeConvName

            # Final eletwise
            eletwiseName = convName + "_eletwise"
            caffeNet.tops[eletwiseName] = L.Eltwise(caffeNet.tops[originalLayer],
                                                    caffeNet.tops[convName+"_2"],
                                                    operation=P.Eltwise.SUM)
            lastLayer = eletwiseName

            convCounter += 1
            localCounter += 1
        # Convolution layers
        #     - Baseline (body): 'DC1', 'DC2', 'DC3'
        #     - Foot: 'DC1f', 'DC2f', 'DC3f'
        #     - Hand: 'DC1h', 'DC2h', 'DC3h'
        elif (layerName[l][0:2] == 'DC' and layerName[l][2] >= '0' and layerName[l][2] <= '9'):
            if layerName[l][2] == '1':
                level = 0
            elif layerName[l][2] == '2':
                level = 1
            # elif layerName[l][2] == '3':
            #     level = 2
            else:
                raise ValueError("Wrong level selected.")
            concatPrevious = (layerName[l-1][0] == 'D')
            if concatPrevious:
                lastLayerDC = lastLayer
            if layerName[l+1][0] == 'L':
                raise ValueError("DC not implemented right before 'L' loss.")

            # Special cases: foot, hand
            isFoot = (layerName[l][-1] == 'f')
            isHand = (layerName[l][-1] == 'h')
            if isFoot:
                init = 'Foot_'
            elif isHand:
                init = 'Hand_'
            else:
                init = ''

            if state == 'image':
                # No image state in subsequent stages
                convName = 'conv%d_%d_CPM_L%d' % (poolCounter, localCounter, level+1)
                lr_m = lrMultDistro[1] * (isFinalModel or (stage == maximumPafStage or level == 0))
                if isFoot or isHand:
                    raise ValueError("Code not ready for this case.")
            else: # fuse
                convName = 'Mconv%d_stage%d_L%d' % (convCounter, stage, level+1)
                lr_m = lrMultDistro[2+2*(isFoot or isHand)] * (isFinalModel or (stage == maximumPafStage or level == 0))
            if not isFinalModel and level == 0:
                convName += '_temp'
            convName = init + convName
                #convCounter += 1
            #if stage == 1:
            #    lr_m = 1 * (isFinalModel or (stage == maximumPafStage or level == 0))
            #else:
            #    lr_m = lr_sub * (isFinalModel or (stage == maximumPafStage or level == 0))
            addBatchNorm = (batchNorm == 1 and layerName[l+1][0] != 'L')
            addBinaryLayer = (binaryConv and (layerName[l+1][0] != 'L' and kernel[l] > 1))

            for index in range(0,3):
                if index == 0:
                    bottomConvName = lastLayer
                else:
                    bottomConvName = convName + "_" + str(index-1)
                subConvName = convName + "_" + str(index)
                # # Binary BN + Scale + ReLU
                # if addBinaryLayer:
                #     if state == 'image':
                #         batchNormName = 'bn%d_%d_stage%d_%d_2' % (poolCounter, localCounter, level+1, index)
                #         scaleNormName = 'scale%d_%d_stage%d_%d_2' % (convCounter, stage, level+1, index)
                #     else:
                #         batchNormName = 'Mbn%d_stage%d_L%d_%d_2' % (convCounter, stage, level+1, index)
                #         scaleNormName = 'Mscale%d_stage%d_L%d_%d_2' % (convCounter, stage, level+1, index)
                #     caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=not addBinaryLayer)
                #     # caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[bottomConvName], in_place=(layerName[l-2] != 'C' or index > 0))
                #     # caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                #     caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                #     lastLayer = scaleNormName
                #     if not deploy:
                #         print batchNormName
                #         print scaleNormName
                #     # Binary activation
                #     if stage > 6:
                #         if state == 'image':
                #             ReLUname = 'bin_act%d_%d_CPM_L%d_%d' % (poolCounter, localCounter, level+1, index)
                #         else:
                #             ReLUname = 'Mbin_act%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                #         if not isFinalModel and level == 0:
                #             ReLUname += '_temp'
                #         caffeNet.tops[ReLUname] = L.BinaryActivation(caffeNet.tops[lastLayer], in_place=True)
                #         # caffeNet.tops[ReLUname] = L.PReLU(caffeNet.tops[lastLayer], in_place=True)
                #         if not deploy:
                #             print ReLUname
                #         lastLayer = ReLUname
                # Convolution
                if addBatchNorm:
                    caffeNet.tops[subConvName] = L.Convolution(caffeNet.tops[bottomConvName], kernel_size=kernel[l],
                                                               num_output=numberOutputChannels[l],
                                                               pad=int(math.floor(kernel[l]/2)),
                                                               weight_filler=dict(type='xavier'), bias_term=False,
                                                               param=[dict(lr_mult=lr_m, decay_mult=1*(not addBinaryLayer))], binary=addBinaryLayer)
                elif addBinaryLayer:
                    caffeNet.tops[subConvName] = L.Convolution(caffeNet.tops[bottomConvName], kernel_size=kernel[l],
                                                               num_output=numberOutputChannels[l],
                                                               pad=int(math.floor(kernel[l]/2)),
                                                               weight_filler=dict(type='xavier'),
                                                               bias_filler=dict(type='constant'),
                                                               param=[dict(lr_mult=lr_m, decay_mult=1),
                                                                      dict(lr_mult=lr_m*2, decay_mult=0)], binary=3)
                else:
                    caffeNet.tops[subConvName] = L.Convolution(caffeNet.tops[bottomConvName], kernel_size=kernel[l],
                                                               num_output=numberOutputChannels[l],
                                                               pad=int(math.floor(kernel[l]/2)),
                                                               param=[dict(lr_mult=lr_m, decay_mult=1),
                                                                      dict(lr_mult=lr_m*2, decay_mult=0)],
                                                               # weight_filler=dict(type='gaussian', std=0.01),
                                                               weight_filler=dict(type='xavier'),
                                                               # weight_filler=dict(type='msra'),
                                                               bias_filler=dict(type='constant'))
                lastLayer = subConvName
                if not deploy:
                    print '%s\tch=%d\t%.1f' % (lastLayer, numberOutputChannels[l], lr_m)

                # # For eltwise
                # if index < 2:
                #     if state == 'image':
                #         ReLUname = 'relu%d_%d_CPM_L%d_%d' % (poolCounter, localCounter, level+1, index)
                #     else:
                #         ReLUname = 'Mrelu%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                #     if not isFinalModel and level == 0:
                #         ReLUname += '_temp'
                #     caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
                #     if not deploy:
                #         print ReLUname
                # # For concat
                # # Batch Norm + scale + ReLU
                # batchNormName = 'Mbn%d_stage%d_%d' % (convCounter, stage, index)
                # caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[subConvName], in_place=True)
                # scaleNormName = 'Mscale%d_stage%d_%d' % (convCounter, stage, index)
                # caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                # lastLayer = scaleNormName
                # if not deploy:
                #     print batchNormName
                #     print scaleNormName

                # Normal BN + Scale + ReLU
                # # BN + Scale
                # # if addBatchNorm or addBinaryLayer:
                # if addBatchNorm:
                #     if state == 'image':
                #         batchNormName = 'bn%d_%d_stage%d_%d' % (poolCounter, localCounter, level+1, index)
                #         scaleNormName = 'scale%d_%d_stage%d_%d' % (convCounter, stage, level+1, index)
                #     else:
                #         batchNormName = 'Mbn%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                #         scaleNormName = 'Mscale%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                #     caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                #     caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                #     lastLayer = scaleNormName
                #     if not deploy:
                #         print batchNormName
                #         print scaleNormName
                # PReLU
                if usePReLU:
                    if state == 'image':
                        ReLUname = 'prelu%d_%d_CPM_L%d_%d' % (poolCounter, localCounter, level+1, index)
                    else:
                        ReLUname = 'Mprelu%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                    if not isFinalModel and level == 0:
                        ReLUname += '_temp'
                    ReLUname = init + ReLUname
                    caffeNet.tops[ReLUname] = L.PReLU(caffeNet.tops[lastLayer], param=[dict(lr_mult=lrMultDistro[0], decay_mult=1)], in_place=True)
                # ReLU
                else:
                    if state == 'image':
                        ReLUname = 'relu%d_%d_CPM_L%d_%d' % (poolCounter, localCounter, level+1, index)
                    else:
                        ReLUname = 'Mrelu%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                    if not isFinalModel and level == 0:
                        ReLUname += '_temp'
                    ReLUname = init + ReLUname
                    caffeNet.tops[ReLUname] = L.ReLU(caffeNet.tops[lastLayer], in_place=True)
                # Rest
                if not deploy:
                    print ReLUname
                lastLayer = ReLUname
                # if addBinaryLayer:
                #     if state == 'image':
                #         batchNormName = 'bn%d_%d_stage%d_%d' % (poolCounter, localCounter, level+1, index)
                #         scaleNormName = 'scale%d_%d_stage%d_%d' % (convCounter, stage, level+1, index)
                #     else:
                #         batchNormName = 'Mbn%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                #         scaleNormName = 'Mscale%d_stage%d_L%d_%d' % (convCounter, stage, level+1, index)
                #     caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
                #     caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
                #     lastLayer = scaleNormName
                #     if not deploy:
                #         print batchNormName
                #         print scaleNormName

            # Final concat
            concatName = convName + "_concat"
            # concatName = convName + "_eltwise"
            # if False:
            # # if concatPrevious and not extraGT:
            #     caffeNet.tops[concatName] = L.Eltwise(caffeNet.tops[convName+"_0"], caffeNet.tops[convName+"_1"],
            #                                           caffeNet.tops[convName+"_2"], caffeNet.tops[lastLayerDC],
            #                                           operation=P.Eltwise.SUM, coeff=[0.25,0.25,0.25,0.25])
            # else:
            #     # caffeNet.tops[concatName] = L.Concat(caffeNet.tops[convName+"_0"], caffeNet.tops[convName+"_1"],
            #     #                                      caffeNet.tops[convName+"_2"], concat_param=dict(axis=1))
            #     caffeNet.tops[concatName] = L.Eltwise(caffeNet.tops[convName+"_0"], caffeNet.tops[convName+"_1"],
            #                                           caffeNet.tops[convName+"_2"], operation=P.Eltwise.SUM,
            #                                           coeff=[1/3.0,1/3.0,1/3.0])
            caffeNet.tops[concatName] = L.Concat(caffeNet.tops[convName+"_0"], caffeNet.tops[convName+"_1"],
                                                 caffeNet.tops[convName+"_2"], concat_param=dict(axis=1))
            # caffeNet.tops[concatName] = L.Eltwise(caffeNet.tops[convName+"_0"], caffeNet.tops[convName+"_1"],
            #                                       caffeNet.tops[convName+"_2"], operation=P.Eltwise.SUM)
            lastLayer = concatName

            # For eltwise
            # # Batch Norm + scale
            # batchNormName = 'Mbn%d_stage%d' % (convCounter, stage)
            # caffeNet.tops[batchNormName] = L.BatchNorm(caffeNet.tops[lastLayer], in_place=True)
            # scaleNormName = 'Mscale%d_stage%d' % (convCounter, stage)
            # caffeNet.tops[scaleNormName] = L.Scale(caffeNet.tops[batchNormName], bias_term=True, in_place=True)
            # lastLayer = scaleNormName
            # if not deploy:
            #     print batchNormName
            #     print scaleNormName

            # # ReLU
            # ReLUname = 'Mrelu%d_stage%d' % (convCounter, stage)
            # caffeNet.tops[ReLUname] = L.PReLU(caffeNet.tops[lastLayer], in_place=True)
            # lastLayer = ReLUname

            convCounter += 1
            localCounter += 1
        # Pooling layers
        elif layerName[l] == 'P':
            # Vgg layers
            vggLastLayers += [lastLayer]
            vggLastLayersIndex = len(vggLastLayers)-1
            # Pooling
            caffeNet.tops['pool%d_stage%d' % (poolCounter, stage+1)] = L.Pooling(
                caffeNet.tops[lastLayer], kernel_size=kernel[l], stride=stride[l], pool=P.Pooling.MAX)
            lastLayer = 'pool%d_stage%d' % (poolCounter, stage+1)
            poolCounter += 1
            localCounter = 1
            convCounter += 1
            if not deploy:
                print lastLayer
        # Loss layers
        # elif layerName[l] == 'L': # Old layer never used with PAF style
        #     # Loss: caffeNet.loss layer is only in training and testing nets, but not in deploy net.
        #     if not deploy:
        #         level = sKeypointLevel
        #         name = 'weight_stage%d' % stage
        #         caffeNet.tops[name] = L.Eltwise(
        #             caffeNet.tops[lastLayer], caffeNet.tops[labelName[(level+2)]], operation=P.Eltwise.PROD)
        #         caffeNet.tops['loss_stage%d' % stage] = L.EuclideanLoss(
        #             caffeNet.tops[name], caffeNet.tops[labelName[level]])

        #     if not deploy:
        #         print 'loss %d' % stage
        #     stage += 1
        #     convCounter = 1
        #     poolCounter = 1
        #     dropCounter = 1
        #     localCounter = 1
        #     state = 'image'
        elif layerName[l] == 'L':
            # Loss: caffeNet.loss layer is only in training and testing nets, but not in deploy net.
            if not deploy:
                # GT
                finalLossName = 'final_loss'
                caffeNet.tops[finalLossName] = L.Concat(caffeNet.tops[labelName[0]], caffeNet.tops[labelName[1]], concat_param=dict(axis=1))
                # Weights
                finalWeightName = 'final_weights'
                caffeNet.tops[finalWeightName] = L.Concat(caffeNet.tops[labelName[2]], caffeNet.tops[labelName[3]], concat_param=dict(axis=1))

                name = 'weight_stage%d' % (stage)
                # Eltwise product
                caffeNet.tops[name] = L.Eltwise(
                    caffeNet.tops[lastLayer], caffeNet.tops[finalWeightName], operation=P.Eltwise.PROD)
                # Euclidean loss
                caffeNet.tops['loss_stage%d' % stage] = L.EuclideanLoss(
                    caffeNet.tops[name], caffeNet.tops[finalLossName], loss_weight=lrMultDistro[5])
                print 'loss %d ' % (stage)

            stage += 1
            convCounter = 1
            poolCounter = 1
            dropCounter = 1
            localCounter = 1
            state = 'image'
        # Loss layers
        # Convolution layers:
        #     - Baseline (body): 'L1', 'L2', 'L3'
        #     - Foot: 'L1f', 'L2f', 'L3f'
        #     - Hand: 'L1h', 'L2h', 'L3h'
        #     - Deploy (i.e., no loss): 'L1d', 'L2d', 'L3d'
        #     - 'L1_2', 'L2_2', 'L3_2'
        #     - 'L1c', 'L2c', 'L3c'
        elif (layerName[l][0] == 'L' and layerName[l][1] >= '0' and layerName[l][1] <= '9'):
            # Special cases: foot, hand
            isFoot = (layerName[l][-1] == 'f')
            isHand = (layerName[l][-1] == 'h')
            isFakeDeploy = (layerName[l][-1] == 'd')
            weight = lrMultDistro[3+2*(isFoot or isHand)]

            # Loss: caffeNet.loss layer is only in training and testing nets, but not in deploy net.
            if layerName[l][1] == '1':
                level = 0
                if isFoot:
                    lastLayerL1f = lastLayer
                elif isHand:
                    lastLayerL1h = lastLayer
                else:
                    lastLayerL1 = lastLayer
            elif layerName[l][1] == '2':
                level = 1
                if isFoot:
                    lastLayerL2f = lastLayer
                elif isHand:
                    lastLayerL2h = lastLayer
                else:
                    lastLayerL2 = lastLayer
            elif layerName[l][1] == '3':
                level = 2
                if isFoot:
                    lastLayerL3f = lastLayer
                elif isHand:
                    lastLayerL3h = lastLayer
                else:
                    lastLayerL3 = lastLayer
            else:
                raise ValueError("Wrong level selected.")

            if not deploy and not isFakeDeploy:
                previousLayer = lastLayer
                # # Deconvolution layer
                # if True:
                #     factor = 2
                #     numberChannels = numberOutputChannels[l-1]
                #     convName = 'Mdeconv%d_stage%d_L%d' % (convCounter, stage, level+1)
                #     bilinearUpsampling(factor, numberChannels, convName, L, caffeNet, lastLayer, deploy)
                #     previousLayer = convName

                name = 'weight_stage%d_L%d' % (stage, level+1)
                if not extraGT or len(layerName[l]) < 4:
                    # Eltwise product
                    caffeNet.tops[name] = L.Eltwise(
                        caffeNet.tops[previousLayer], caffeNet.tops[labelName[(level+2)]], operation=P.Eltwise.PROD)
                    # Euclidean loss
                    caffeNet.tops['loss_stage%d_L%d' % (stage, level+1)] = L.EuclideanLoss(
                        caffeNet.tops[name], caffeNet.tops[labelName[level]], loss_weight=weight)
                else:
                    caffeNet.tops[name] = L.Eltwise(
                        caffeNet.tops[previousLayer], caffeNet.tops[labelName[(level+2)]+'_2'], operation=P.Eltwise.PROD)
                    caffeNet.tops['loss_stage%d_L%d' % (stage, level+1)] = L.EuclideanLoss(
                        caffeNet.tops[name], caffeNet.tops[labelName[level]+'_2'], loss_weight=weight)

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
            if not deploy:
                caffeNet.tops['drop%d_stage%d' % (dropCounter, stage)] = L.Dropout(
                    caffeNet.tops[lastLayer], in_place=True, dropout_param=dict(dropout_ratio=0.5))
                dropCounter += 1
        # Concat layers
        #     - Default: '@'
        #     - '@1', '@2', '@V'
        #     - Foot and hand: '@f', '@h':
        #     - Upsampling: '@U'
        elif layerName[l][0] == '@':
            #if not sharePoint:
            #    sharePoint = lastLayer

            nextLevel = layerName[l+1][-1]
            # Special cases: foot, hand
            isFoot = (layerName[l][-1] == 'f')
            isHand = (layerName[l][-1] == 'h')
            if isFoot:
                init = 'Foot_'
                nextLevel += layerName[l+1][-2]
            elif isHand:
                init = 'Hand_'
                nextLevel += layerName[l+1][-2]
            else:
                init = ''

            nextLayer = init + 'concat_stage%d_L%s' % (stage, nextLevel)
            # lastLayerLX
            if layerName[l] == '@' or isFoot or isHand:
                if lastLayerL1 != '' and lastLayerL2 != '' and lastLayerL1f and lastLayerL2f:
                    caffeNet.tops[nextLayer] = L.Concat(
                        caffeNet.tops[sharePoint], caffeNet.tops[lastLayerL1], caffeNet.tops[lastLayerL2], caffeNet.tops[lastLayerL1f], caffeNet.tops[lastLayerL2f], concat_param=dict(axis=1))
                elif lastLayerL1 != '' and lastLayerL2 != '' and lastLayerL2f:
                    caffeNet.tops[nextLayer] = L.Concat(
                        caffeNet.tops[sharePoint], caffeNet.tops[lastLayerL1], caffeNet.tops[lastLayerL2], caffeNet.tops[lastLayerL2f], concat_param=dict(axis=1))
                elif lastLayerL1 != '' and lastLayerL2 != '':
                    caffeNet.tops[nextLayer] = L.Concat(
                        caffeNet.tops[sharePoint], caffeNet.tops[lastLayerL1], caffeNet.tops[lastLayerL2], concat_param=dict(axis=1))
                else:
                    caffeNet.tops[nextLayer] = L.Concat(
                        caffeNet.tops[sharePoint], caffeNet.tops[lastLayer], concat_param=dict(axis=1))
            elif layerName[l] == '@1':
                caffeNet.tops[nextLayer] = L.Concat(
                    caffeNet.tops[sharePoint], caffeNet.tops[lastLayerL1], concat_param=dict(axis=1))
            elif layerName[l] == '@2':
                caffeNet.tops[nextLayer] = L.Concat(
                    caffeNet.tops[sharePoint], caffeNet.tops[lastLayerL2], concat_param=dict(axis=1))
            elif layerName[l] == '@V':
                caffeNet.tops[nextLayer] = L.Concat(
                    caffeNet.tops[lastLayer], caffeNet.tops[vggLastLayers[vggLastLayersIndex]], concat_param=dict(axis=1))
            elif layerName[l] == '@U':
                nextLayer = 'net_output_small'
                caffeNet.tops[nextLayer] = L.Concat(
                    caffeNet.tops[lastLayerL1], caffeNet.tops[lastLayerL2], concat_param=dict(axis=1))
            # # Before lastLayerLX
            # caffeNet.tops[nextLayer] = L.Concat(
            #     caffeNet.tops[sharePoint], caffeNet.tops[lastLayer], concat_param=dict(axis=1))

            localCounter = 1
            state = 'fuse'
            lastLayer = nextLayer
            if layerName[l] == '@V':
                vggLastLayersIndex -= 1
            else:
                vggLastLayersIndex = len(vggLastLayers)-1
            if not deploy:
                print lastLayer
        # Sharepoint index (the output of the last layer is shared by multiple stages)
        elif layerName[l] == '$':
            sharePoint = lastLayer
            poolCounter += 1
            localCounter = 1
            stage += 1
            state = 'fuse'
            if not deploy:
                print 'share'
        # Reset (e.g., switch body to foot)
        elif layerName[l] == 'reset':
            stage = 0
            convCounter = 1
            poolCounter = 1
            dropCounter = 1
            localCounter = 1
            if not deploy:
                print 'reset'
        else:
            raise ValueError("Unknown parameter: " + layerName[l])

    # Return result
    if deploy:
        # Final concat
        if lastLayerL1f != '' and lastLayerL2f != '':
            caffeNet.tops['net_output'] = L.Concat(
                caffeNet.tops[lastLayerL1], caffeNet.tops[lastLayerL1f], caffeNet.tops[lastLayerL2], caffeNet.tops[lastLayerL2f], concat_param=dict(axis=1))
        else:
            caffeNet.tops['net_output'] = L.Concat(
                caffeNet.tops[lastLayerL1], caffeNet.tops[lastLayerL2], concat_param=dict(axis=1))
        # # Deconvolution layer
        # if True:
        #     factor = 2
        #     numberChannels = numberTotalParts+1
        #     deconvName = 'net_output'
        #     bilinearUpsampling(factor, numberChannels, deconvName, L, caffeNet, 'net_output_small', deploy)
        # Input
        deployInit = 'input: {}\n\
input_dim: {} # This value will be defined at runtime\n\
input_dim: {}\n\
input_dim: {} # This value will be defined at runtime\n\
input_dim: {} # This value will be defined at runtime\n'.format('"' + input + '"', dim1, dim2, dim3, dim4)
        # Assemble the input header with the net layers string. Remove the first placeholder layer from the net string
        layerText = 'layer {'
        return deployInit + layerText + layerText.join(str(caffeNet.to_proto()).split(layerText)[2:])
        # # ResNet style
        # return deployInit + getResNet50Init() + layerText + layerText.join(str(caffeNet.to_proto()).split(layerText)[2:])
    else:
        return str(caffeNet.to_proto())
        # # ResNet style
        # return getResNet50Init() + str(caffeNet.to_proto())



def getSolverPrototxt(learningRateInit, numberIterations, snapshotFolder):
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
type:"Adam"\n\
base_lr: %f\n\
momentum: 0.9\n\
momentum2: 0.999\n\
weight_decay: 0.0005\n\
# lr_policy: "step"   # The learning rate policy\n\
lr_policy: "multistep"   # The learning rate policy\n\
# gamma: 0.333\n\
gamma: 0.5\n\
# stepsize: 136106    # Previously: 29166 68053 136106 (previous one)\n\
# stepvalue: 10000\n\
# stepvalue: 20000\n\
# stepvalue: 30000\n\
# stepvalue: 40000\n\
# stepvalue: 50000\n\
# stepvalue: 60000\n\
# stepvalue: 70000\n\
# stepvalue: 80000\n\
# stepvalue: 90000\n\
# stepvalue: 100000\n\
stepvalue: 200000\n\
stepvalue: 300000\n\
stepvalue: 360000\n\
stepvalue: 420000\n\
stepvalue: 480000\n\
stepvalue: 540000\n\
stepvalue: 600000\n\
stepvalue: 700000\n\
stepvalue: 800000\n\
stepvalue: 900000\n\
# Output - Model Saving and Loss Output\n\
display: 20 # Previously: 5   # Display every X iterations\n\
max_iter: %d   # Maximum number of iterations, previously: 600000\n\
snapshot: 2000   # Snapshot intermediate results, previously: 2000. Mine: 10000?\n\
snapshot_prefix: "%s/pose"\n\
solver_mode: GPU   # CPU or GPU\n' % (learningRateInit, numberIterations, snapshotFolder)
    return string



def getBash(caffeFolder, pretrainedModelPath):
    enterKey = ' \\\n    '
    return ('#!/usr/bin/env sh\n' + caffeFolder
            + '/build/tools/caffe train' + enterKey + '--solver=pose_solver.prototxt'
            + enterKey + '--gpu=$1 --weights=' + pretrainedModelPath
            + enterKey + ' 2>&1 | tee ./training_log.txt\n')



def getResumeBash(caffeFolder):
    enterKey = ' \\\n    '
    return ('#!/usr/bin/env sh\n' + caffeFolder
            + '/build/tools/caffe train' + enterKey + '--solver=pose_solver.prototxt'
            + enterKey + '--gpu=$1 --snapshot=INSERT_PATH_HERE'
            + enterKey + ' 2>&1 | tee ./resumed_training_log.txt\n')
