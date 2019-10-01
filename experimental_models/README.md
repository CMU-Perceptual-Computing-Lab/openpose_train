# Experimental Models
----------------------------------------------------------------------------------------------------



## Contents
1. [Introduction](#introduction)
2. [Single-Network Whole-Body Pose Estimation Model](#single-network-whole-body-pose-estimation-model)
3. [BODY_25 Model](#body-25-model)
4. [BODY_25B Model (Maximum Accuracy)](#body-25b-model-maximum-accuracy))



## Introduction
The `experimental_models` directory contains our experimental models, including the whole-body model from [Single-Network Whole-Body Pose Estimation](README.md#citation), as well as instructions to make it run inside [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose).



## Single-Network Whole-Body Pose Estimation Model
To use the `BODY_135` model trained for the [Single-Network Whole-Body Pose Estimation](../README.md#citation) paper (i.e., higher accuracy but slower speed than the default `BODY_135` model):
1. Download the Caffe model from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/pose_iter_XXXXXX.caffemodel](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/pose_iter_XXXXXX.caffemodel) into [experimental_models/100_135AlmostSameBatchAllGPUs/body_135/](./100_135AlmostSameBatchAllGPUs/body_135/) as `pose_iter_XXXXXX.caffemodel`.
2. Copy the `body_135` folder into the [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) models folder, such as you end up with the previous 2 files in the following paths:
    1. `openpose/models/pose/body_135/pose_deploy.prototxt`
    2. `openpose/models/pose/body_135/pose_iter_XXXXXX.caffemodel`. Note: This model corresponds to `pose_iter_464000.caffemodel` (i.e., trained for 464k iterations), and it was renamed simply to follow the OpenPose format.
3. Run the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) with your usual flags, while adding the `--model_pose BODY_135 --net_resolution -1x480`.
4. Alternatively to 3, for multi-scale (even higher accuracy), then use `--model_pose BODY_135 --net_resolution -1712x960 --scale_number 4 --scale_gap 0.25`.

In addition, we also include all the files generated for and during training in [experimental_models/100_135AlmostSameBatchAllGPUs/training_results/](./100_135AlmostSameBatchAllGPUs/training_results/). If you want to read the `training_log.txt` file, you can download it from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/training_log.txt](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/training_log.txt).



## BODY_25 Model
This model is already included with the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose), so simply run the default version of [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) in order to use it.



## BODY_25B Model (Maximum Accuracy)
Thanks to [Single-Network Whole-Body Pose Estimation](../README.md#citation), new models for BODY_25 were obtained with higher accuracy. We called it `BODY_25B` given that we add some extra PAF channels. To use the `BODY_25B` model trained for the [Single-Network Whole-Body Pose Estimation](../README.md#citation) paper (i.e., higher accuracy but slower speed than the default `BODY_25` model):
1. Download the Caffe model from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/pose_iter_XXXXXX.caffemodel](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/pose_iter_XXXXXX.caffemodel) into [experimental_models/1_25BSuperModel11FullVGG/body_25b/](./1_25BSuperModel11FullVGG/body_25b/) as `pose_iter_XXXXXX.caffemodel`.
2. Copy the `body_25b` folder into the [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) models folder, such as you end up with the previous 2 files in the following paths:
    1. `openpose/models/pose/body_25b/pose_deploy.prototxt`
    2. `openpose/models/pose/body_25b/pose_iter_XXXXXX.caffemodel`. Note: This model corresponds to `pose_iter_464000.caffemodel` (i.e., trained for 464k iterations), and it was renamed simply to follow the OpenPose format.
3. Run the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) with your usual flags, while adding the `--model_pose BODY_25B --net_resolution -1x480`.
4. Alternatively to 3, for multi-scale (even higher accuracy), then use `--model_pose BODY_25B --net_resolution 1712x960 --scale_number 4 --scale_gap 0.25`.

In addition, we also include all the files generated for and during training in [experimental_models/1_25BSuperModel11FullVGG/training_results/](./1_25BSuperModel11FullVGG/training_results/). If you want to read the `training_log.txt` file, you can download it from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/training_log.txt](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/training_log.txt).
