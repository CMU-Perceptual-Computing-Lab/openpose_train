# Experimental Models
----------------------------------------------------------------------------------------------------



## Contents
1. [Introduction](#introduction)
2. [Single-Network Whole-Body Pose Estimation Model](#single-network-whole-body-pose-estimation-model)
3. [Body_25 Model](#body_25)



## Introduction
The `experimental_models` directory contains our experimental models, including the whole-body model from [Single-Network Whole-Body Pose Estimation](README.md#citation), as well as instructions to make it run inside [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose).



## Single-Network Whole-Body Pose Estimation Model
To use the model trained for the [Single-Network Whole-Body Pose Estimation](../README.md#citation) paper:
1. Download the Caffe model from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/body_135/pose_iter_XXXXXX.caffemodel](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/body_135/pose_iter_XXXXXX.caffemodel) into [experimental_models/100_135AlmostSameBatchAllGPUs/body_135/](./100_135AlmostSameBatchAllGPUs/body_135/) as `pose_iter_XXXXXX.caffemodel`.
2. Copy the body_135 folder into the [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) models folder, such as you end up with the previous 2 files in the following paths:
    1. `openpose/models/pose/body_135/pose_deploy.prototxt`
    2. `openpose/models/pose/body_135/pose_iter_XXXXXX.caffemodel`. Note: This model corresponds to `pose_iter_464000.caffemodel` (i.e., trained for 464k iterations), and it was renamed simply to follow the OpenPose format.
3. Run the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) with your usual flags, while adding the `--model_pose BODY_135`.

In addition, we also include all the files generated for and during training in [experimental_models/100_135AlmostSameBatchAllGPUs/training_results/](./100_135AlmostSameBatchAllGPUs/training_results/). If you want to read the `training_log.txt` file, you can download it from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/body_135/training_log.txt](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/body_135/training_log.txt).



## Body_25 Model
This model is already included with the official OpenPose, so simply run the default version of OpenPose in order to use it.
