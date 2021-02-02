# Training
----------------------------------------------------------------------------------------------------



## Contents
1. [Prerequisites](#prerequisites)
2. [Training](#training)
    1. [Phase 1 - Generating LMDB Files](#phase-1-generating-lmdb-files)
    2. [Phase 2 - Training](#phase-2-training)
3. [Training Hardware](#training-hardware)
4. [Training Examples](#training-examples)
    1. [OpenPose BODY_25B](#openpose-body-25)
    2. [Single-Network Whole-Body Pose Estimation](#single-network-whole-body-pose-estimation)



## Prerequisites
All the following scripts are meant to be used with our modified version of the [Matlab COCO API](https://github.com/gineshidalgo99/cocoapi.git), cloned into `dataset/COCO/` as `dataset/COCO/cocoapi/`.



## Training
This directory contains multiple scripts to generate the scripts for training and to actually train the models. It is split into 2 sections:
1. [Body Training](#body-training): Used to train the COCO body model.
2. [Whole-Body Training](#whole-body-training): Used to train the whole-body model.
3. By mixing the scripts from points 1 and 2, any kind of training is possible (e.g., body and hands, face only, etc.). However, the only examples available are for: body (COCO), body-foot, and whole-body. Thus, only questions about these 3 types will be answered.

Depending on the kind of model you are trying to learn, use the following training steps:
1. Either download or generate the LMDB files for training:
    - Option a) Download the LMDB files ready to be used by running `cd training && bash a_downloadAndUpzipLmdbs.sh`. It will download them into `dataset/` with names following the format `dataset/lmdb_X`, where `X` will be similar to the dataset name.
    - Option b) Generate the LMDB files by yourself:
        - COCO:
            - Option a) Download the required LMDB by running `cd training; bash a_lmdbGetBody.sh`.
            - Option b)
                1. Run `cd training; bash a0_getData.sh` to obtain the COCO images in `dataset/COCO/cocoapi/images/`, keypoints annotations in `dataset/COCO/annotations/` and our custom [COCO official toolbox](https://github.com/gineshidalgo99/cocoapi) in `dataset/COCO/cocoapi/`.
                2. Run `a1_coco_jsonToNegativesJson.m` in Matlab to generate the LMDB with the images with no people on them.
                3. Run `a2_coco_jsonToMat.m` in Matlab to convert the annotation format from json to mat in `dataset/COCO/mat/`.
                4. Run `a3_coco_matToMasks.m` in Matlab to obatin the mask images for unlabeled person. You can use 'parfor' in Matlab to speed up the code.
                5. Run `a4_coco_matToRefinedJson.m` to generate a json file in `dataset/COCO/json/` directory. The json files contain raw informations needed for training.
                6. Run `python c_generateLmdbs.py` to generate the COCO and background-COCO LMDBs.
        - Foot / Face / Hand / Dome:
            - Option a) Download the required LMDBs by running `cd training; bash a_lmdbGetFace.sh; bash a_lmdbGetFoot.sh; bash a_lmdbGetHands.sh; bash a_lmdbGetDome.sh`.
            - Option b)
                1. Download the datasets.
                2. Run `a2_coco_jsonToMat.m` analogously to COCO, but with the foot/face/hand option.
                3. Run `a4_coco_matToRefinedJson.m` analogously to COCO, but with the foot/face/hand option.
                4. Run `python c_generateLmdbs.py` again to generate the (COCO+foot)/face/hand LMDB.
        - MPII:
            - Option a) Download the required LMDB by running `cd training; bash a_lmdbGetMpii.sh`.
            - Option b)
                1. Download [Images (12.9 GB)](https://datasets.d2.mpi-inf.mpg.de/andriluka14cvpr/mpii_human_pose_v1.tar.gz) and [Annotations (12.5 MB)](https://datasets.d2.mpi-inf.mpg.de/andriluka14cvpr/mpii_human_pose_v1_u12_2.zip) from the [MPII dataset](http://human-pose.mpi-inf.mpg.de/#download) into `dataset/MPII/`.
                2. Run `a0_convertMatToInitialJson.m`
                3. Run `python a1_generateFinalJsonAndMasks.py` with `sMode = 1` to generate the masks.
                4. Run `python a1_generateFinalJsonAndMasks.py` with `sMode = 2` to generate the final JSON file.
                5. Run `python c_generateLmdbs.py` again to generate the MPII LMDB.
2. Train model:
    - a) Download and compile our modified Caffe:
        - OpenPose Caffe Training: [github.com/CMU-Perceptual-Computing-Lab/openpose_caffe_train](https://github.com/CMU-Perceptual-Computing-Lab/openpose_caffe_train).
        - Compile it by running: `make all -j{num_cores} && make pycaffe -j{num_cores}`.
    - b) Generate the Caffe ProtoTxt and shell file for training by running `python d_setLayers.py`.
        - Set `sCaffeFolder` to the path of [OpenPose Caffe Train](https://github.com/CMU-Perceptual-Computing-Lab/openpose_caffe_train).
        - Set `sAddFoot` to 1 or 0 to enable/disable combined body-foot.
        - Set `sAddMpii`, `sAddFace` and `sAddHands` to 1 or 0 to enable/disable boyd mpii/face/hands (if 1, then all the above must be also 1).
        - Set `sAddDome` to 1 or 0 to enable/disable the Dome whole-body dataset (if 1, then all the above must be also 1).
        - Flag `sProbabilityOnlyBackground` fixes the percentage of images that will come from the non-people dataset (called negative dataset).
        - Sett `sSuperModel` to 1 train the whole-body dataset, or to train a heavier but also more accurate body-foot dataset. Set it to 0 for the original OpenPose body-foot dataset. 
        - Flags `carVersion` and `sAddDistance` are deprecated.
    - c) Download the pretrained [VGG-19 model](https://gist.github.com/ksimonyan/3785162f95cd2d5fee77) and unzip it into `dataset/vgg/` as `dataset/vgg/VGG_ILSVRC_19_layers.caffemodel` and `dataset/vgg/vgg_deploy.prototxt`. The first 10 layers are used as backbone.
    - d) Train:
        - Go to the auto-generated `training_results/pose/` directory.
        - Run `bash train_pose.sh 0,1,2,3` (generated by `d_setLayers.py`) to start the training with the 4 GPUs (0-3).



## Training Hardware
Our best resuls are obtained with 4-GPU machines and a batch size of 10, training for about 800k iterations (and picking the model with maximum accuracy among those).



## Training Examples
### OpenPose BODY_25B
To train an improved version of the `BODY_25B` OpenPose model available in OpenPose, set `sAddFoot = sAddMpii = 1`, and `sAddDome = sSuperModel = 0`. This should match the current example in [training/d_setLayers.py.example](./d_setLayers.py.example).

### Single-Network Whole-Body Pose Estimation
To train the model used for [Single-Network Whole-Body Pose Estimation](../README.md#citation) paper, set `sAddFoot = sAddMpii = sAddDome = sSuperModel = 1`.
