# Experimental Models
----------------------------------------------------------------------------------------------------



## Contents
1. [Introduction](#introduction)
2. [Single-Network Whole-Body Pose Estimation Model](#single-network-whole-body-pose-estimation-model)
3. [Official BODY_25 Model](#official-body_25-model)
4. [BODY_25B Model - Option 1 (Maximum Accuracy, Less Speed)](#body_25b-model---option-1-maximum-accuracy-less-speed))
5. [BODY_25B Model - Option 2 (Recommended)](#body_25b-model---option-2-recommended))



## Introduction
Very important: All of these models only work on Nvidia GPU, they do not work on CPU or OpenCL modes.

The `experimental_models` directory contains our experimental models, including the whole-body model from [Single-Network Whole-Body Pose Estimation](README.md#citation), as well as instructions to make it run inside [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose).

Which model should I use?
1. If you want the model that trains body, face, hands, and feet in the same network, go for `BODY_135`.
2. If you want the maximum accuracy, regardless of the speed, train `BODY_25B Model - Option 1`.
3. If you want to maintain the current OpenPose speed, while increasing its accuracy, go for `BODY_25B Model - Option 2`.
4. If you are OK losing a bit of accuracy but simply want to fine-tune the current OpenPose, go for `BODY_25`.



## Single-Network Whole-Body Pose Estimation Model
To use the `BODY_135` model trained for the [Single-Network Whole-Body Pose Estimation](../README.md#citation) paper (i.e., higher accuracy but slower speed than the default `BODY_25` model):
1. Download the Caffe model from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/pose_iter_XXXXXX.caffemodel](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/pose_iter_XXXXXX.caffemodel) into [experimental_models/100_135AlmostSameBatchAllGPUs/body_135/](./100_135AlmostSameBatchAllGPUs/body_135/) as `pose_iter_XXXXXX.caffemodel`.
2. Copy the `body_135` folder into the [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) models folder, such as you end up with the previous 2 files in the following paths:
    1. `openpose/models/pose/body_135/pose_deploy.prototxt`
    2. `openpose/models/pose/body_135/pose_iter_XXXXXX.caffemodel`. Note: This model corresponds to `pose_iter_464000.caffemodel` (i.e., trained for 464k iterations), and it was renamed simply to follow the OpenPose format.
3. Run the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) with your usual flags, while adding the `--model_pose BODY_135 --net_resolution -1x480`.
4. Alternatively to 3, for multi-scale (even higher accuracy), then use `--model_pose BODY_135 --net_resolution -1712x960 --scale_number 4 --scale_gap 0.25`.

In addition, we also include all the files generated for and during training in [experimental_models/100_135AlmostSameBatchAllGPUs/training_results/](./100_135AlmostSameBatchAllGPUs/training_results/). If you want to read the `training_log.txt` file, you can download it from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/training_log.txt](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/100_135AlmostSameBatchAllGPUs/body_135/training_log.txt).



## Official BODY_25 Model
This model is already included with the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose), so simply run the default version of [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) in order to use it.

To allow fine-tuning the official OpenPose model, and although this model is not "experimental", we also include all the files generated for and during its training in [experimental_models/body_25/training_results/](./body_25/training_results/). If you want to read the `training_log.txt` file, you can download it from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/body_25/training_log.txt](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/body_25/training_log.txt).

Note: For this model, you must use `openpose/models/pose/body_25/pose_iter_584000.caffemodel` rather than a caffemodel called `pose_iter_XXXXXX.caffemodel` (just rename your best model with that name, regardless of the number of iterations). No special flags are required to run it.



## BODY_25B Model - Option 1 (Maximum Accuracy, Less Speed)
Thanks to [Single-Network Whole-Body Pose Estimation](../README.md#citation), new models for BODY_25 were obtained with higher accuracy. We called it `BODY_25B` given that we add some extra PAF channels and body keypoints. It adds the MPII head and neck keypoints, and it removes the artifially created neck and middle hip of `BODY_25` (that neck was simply the middle point of the shoulders and the middle hip the middle point of the hips).

To use the `BODY_25B` model trained for the [Single-Network Whole-Body Pose Estimation](../README.md#citation) paper (i.e., higher accuracy but slower speed than the default `BODY_25` model):
1. Download the Caffe model from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/pose_iter_XXXXXX.caffemodel](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/pose_iter_XXXXXX.caffemodel) into [experimental_models/1_25BSuperModel11FullVGG/body_25b/](./1_25BSuperModel11FullVGG/body_25b/) as `pose_iter_XXXXXX.caffemodel`.
2. Copy the `body_25b` folder into the [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) models folder, such as you end up with the previous 2 files in the following paths:
    1. `openpose/models/pose/body_25b/pose_deploy.prototxt`
    2. `openpose/models/pose/body_25b/pose_iter_XXXXXX.caffemodel`. Note: This model corresponds to `pose_iter_464000.caffemodel` (i.e., trained for 464k iterations), and it was renamed simply to follow the OpenPose format.
3. Run the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) with your usual flags, while adding the `--model_pose BODY_25B --net_resolution -1x480`.
4. Alternatively to 3, for multi-scale (even higher accuracy), then use `--model_pose BODY_25B --net_resolution 1712x960 --scale_number 4 --scale_gap 0.25`.

In addition, we also include all the files generated for and during training in [experimental_models/1_25BSuperModel11FullVGG/training_results/](./1_25BSuperModel11FullVGG/training_results/). If you want to read the `training_log.txt` file, you can download it from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/training_log.txt](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BSuperModel11FullVGG/body_25b/training_log.txt).



## BODY_25B Model - Option 2 (Recommended)
We also include a second version of `BODY_25B` that is as fast as the default `BODY_25`, but that it highly reduces the number of false positives, increasing its overall accuracy.

To use this variation of the `BODY_25B` model trained for the [Single-Network Whole-Body Pose Estimation](../README.md#citation) paper:
1. Download the Caffe model from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BBkg/body_25b/pose_iter_XXXXXX.caffemodel](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BBkg/body_25b/pose_iter_XXXXXX.caffemodel) into [experimental_models/1_25BBkg/body_25b/](./1_25BBkg/body_25b/) as `pose_iter_XXXXXX.caffemodel`.
2. Copy the `body_25b` folder into the [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) models folder, such as you end up with the previous 2 files in the following paths:
    1. `openpose/models/pose/body_25b/pose_deploy.prototxt`
    2. `openpose/models/pose/body_25b/pose_iter_XXXXXX.caffemodel`. Note: This model corresponds to `pose_iter_464000.caffemodel` (i.e., trained for 464k iterations), and it was renamed simply to follow the OpenPose format.
3. Run the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose) with your usual flags, while adding the `--model_pose BODY_25B`. Note that this model has been trained for the original and default `--net_resolution -1x368`, so this flag is not required.
4. Alternatively to 3, for multi-scale (even higher accuracy), then use `--model_pose BODY_25B --net_resolution 1312x736 --scale_number 4 --scale_gap 0.25`.

In addition, we also include all the files generated for and during training in [experimental_models/1_25BBkg/training_results/](./1_25BBkg/training_results/). If you want to read the `training_log.txt` file, you can download it from [posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BBkg/body_25b/training_log.txt](http://posefs1.perception.cs.cmu.edu/OpenPose/models/pose/1_25BBkg/body_25b/training_log.txt).
