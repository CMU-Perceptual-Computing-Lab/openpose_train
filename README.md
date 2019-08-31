# OpenPose training code

<div align="center">
    <img src=".github/Logo_main_black.png", width="300">
</div>

--------------------------------------------------------------------------------------------------------------------------------------------------------------------



## Contents
1. [Introduction](#introduction)
2. [Functionality](#functionality)
3. [Testing](#testing)
4. [Training](#training)
5. [Citation](#citation)
6. [License](#license)



## Introduction
[**OpenPose Training**](https://github.com/CMU-Perceptual-Computing-Lab/openpose_training) includes the training code for [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose), as well as some experimental models that might not necessarily end up in OpenPose (to avoid confusing the OpenPose users with too many models).

It is **authored by [Gines Hidalgo](https://www.gineshidalgo.com), [Yaadhav Raaj](https://www.raaj.tech), [Haroon Idrees](https://scholar.google.com/citations?user=z74SfHcAAAAJ&hl=en), [Donglai Xiang](https://xiangdonglai.github.io), [Hanbyul Joo](https://jhugestar.github.io), [Tomas Simon](http://www.cs.cmu.edu/~tsimon), and [Yaser Sheikh](http://www.cs.cmu.edu/~yaser)**. It is based on [Realtime Multi-Person Pose Estimation](https://github.com/ZheC/Realtime_Multi-Person_Pose_Estimation). In addition, OpenPose would not be possible without the [**CMU Panoptic Studio dataset**](http://domedb.perception.cs.cmu.edu). We would also like to thank all the people who helped OpenPose in any way.

This repository and its documentation assumes knowledge of [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose). If you have not used OpenPose yet, you must familiare yourself with it before attempting to follow this documentation.



## Functionality
- **Training code** for [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose).
- Release of some **experimental models** that have not been included into [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose). These models are experimental and might present some issues compared to the models officially released inside OpenPose.
This project is licensed under the terms of the [license](LICENSE).
    - Whole-body pose estimation models from [Single-Network Whole-Body Pose Estimation](https://www.gineshidalgo.com/#section-5c3aab65b18d8).
    - Alternative to the `BODY_25` model of OpenPose, which higher accuracy but slower speed.



## Testing

For testing, use the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose). Simply copy your trained models into the `models` folder inside OpenPose, following the instructions provided for each different model.



## Training
Depending on the kind of model you are trying to learn, use the following training steps:

- a) Generate data for training:
    - COCO:
        - Option a)
            1. Run `cd training; bash a0_getData.sh` to obtain the COCO images in `dataset/COCO/images/`, keypoints annotations in `dataset/COCO/annotations/` and our custom [COCO official toolbox](https://github.com/gineshidalgo99/cocoapi) in `dataset/COCO/cocoapi/`.
            2. Run `a2_coco_jsonToMat.m` in Matlab to convert the annotation format from json to mat in `dataset/COCO/mat/`.
            3. Run `a3_coco_matToMasks.m` in Matlab to obatin the mask images for unlabeled person. You can use 'parfor' in Matlab to speed up the code.
            4. Run `a4_coco_matToRefinedJson.m` to generate a json file in `dataset/COCO/json/` folder. The json files contain raw informations needed for training.
            5. Run `python a4_genLMDB.py` to generate your COCO and background-COCO LMDBs.
        - Option b)
            - (OUTDATED) Alternatively, you could simply download our prepared LMDB for the COCO dataset (189GB file) by: `bash get_lmdb.sh`. Note, this option no longer works, that COCO LMDB file is no longer compatible.
    - Foot / Face / Hand:
        1. Run `a2_coco_jsonToMat.m` analogously to COCO, but with the foot/face/hand option.
        2. Run `a4_coco_matToRefinedJson.m` analogously to COCO, but with the foot/face/hand option.
        3. Run `python a4_genLMDB.py` again to generate your (COCO+foot)/face/hand LMDB.
    - MPII:
        1. Download [Images (12.9 GB)](https://datasets.d2.mpi-inf.mpg.de/andriluka14cvpr/mpii_human_pose_v1.tar.gz) and [Annotations (12.5 MB)](https://datasets.d2.mpi-inf.mpg.de/andriluka14cvpr/mpii_human_pose_v1_u12_2.zip) from the [MPII dataset](http://human-pose.mpi-inf.mpg.de/#download) into `dataset/MPII/`.
        2. Run `a0_convertMatToInitialJson.m`
        3. Run `python a1_generateFinalJsonAndMasks.py` with `sMode = 1` to generate the masks.
        4. Run `python a1_generateFinalJsonAndMasks.py` with `sMode = 2` to generate the final JSON file.
        5. Run `python a4_genLMDB.py` again to generate your MPII LMDB.

- b) Custom Caffe - Download and compile our modified Caffe:
    - Download link: [openpose_caffe_train](https://github.com/gineshidalgo99/openpose_caffe_train).
    - Compile it by running: `make all -j{num_cores} && make pycaffe -j{num_cores}`.
    - Note: It will be merged with caffe_rtpose (for testing) soon.

- c) Generate Caffe ProtoTxt and shell file for training:
    - Run `python d_setLayers.py`.

- d) Pre-trained model (VGG-19) - Get pre-trained model to initialize the first 10 layers of the network for training:
    - Download link: [VGG-19 model](https://gist.github.com/ksimonyan/3785162f95cd2d5fee77).

- e) Train:
    - Run `bash train_pose.sh 0,1,2,3` (generated by setLayers.py) to start the training with 4 GPUs (0-3).



## Citation
Please cite these papers in your publications if it helps your research (the face keypoint detector was trained using the procedure described in [Simon et al. 2017] for hands):

    @inproceedings{hidalgo2019singlenetwork,
      author = {Gines Hidalgo and Yaadhav Raaj and Haroon Idrees and Donglai Xiang and Hanbyul Joo and Tomas Simon and Yaser Sheikh
},
      booktitle = {ICCV},
      title = {Single-Network Whole-Body Pose Estimation},
      year = {2019}
    }

    @inproceedings{cao2018openpose,
      author = {Zhe Cao and Gines Hidalgo and Tomas Simon and Shih-En Wei and Yaser Sheikh},
      booktitle = {arXiv preprint arXiv:1812.08008},
      title = {Open{P}ose: realtime multi-person 2{D} pose estimation using {P}art {A}ffinity {F}ields},
      year = {2018}
    }

Links to the papers:

- [Single-Network Whole-Body Pose Estimation](https://www.gineshidalgo.com/#section-5c3aab65b18d8)
- [OpenPose: Realtime Multi-Person 2D Pose Estimation using Part Affinity Fields](https://arxiv.org/abs/1812.08008)



## License
OpenPose is freely available for free non-commercial use, and may be redistributed under these conditions. Please, see the [license](LICENSE) for further details. Interested in a commercial license? Check this [FlintBox link](https://flintbox.com/public/project/47343/). For commercial queries, use the `Directly Contact Organization` section from the [FlintBox link](https://flintbox.com/public/project/47343/) and also send a copy of that message to [Yaser Sheikh](http://www.cs.cmu.edu/~yaser/).
