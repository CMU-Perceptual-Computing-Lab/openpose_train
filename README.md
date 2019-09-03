# OpenPose Training

<div align="center">
    <img src=".github/Logo_main_black.png", width="300">
</div>

----------------------------------------------------------------------------------------------------



## Contents
1. [Introduction](#introduction)
2. [Functionality](#functionality)
3. [Testing](#testing)
4. [Training](#training)
5. [Citation](#citation)
6. [License](#license)



## Introduction
[**OpenPose Training**](https://github.com/CMU-Perceptual-Computing-Lab/openpose_training) includes the training code for [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose), as well as some experimental models that might not necessarily end up in OpenPose (to avoid confusing its users with too many models).

It is **authored by [Gines Hidalgo](https://www.gineshidalgo.com), [Yaadhav Raaj](https://www.raaj.tech), [Haroon Idrees](https://scholar.google.com/citations?user=z74SfHcAAAAJ&hl=en), [Donglai Xiang](https://xiangdonglai.github.io), [Hanbyul Joo](https://jhugestar.github.io), [Tomas Simon](http://www.cs.cmu.edu/~tsimon), and [Yaser Sheikh](http://www.cs.cmu.edu/~yaser)**. It is based on [Realtime Multi-Person Pose Estimation](https://github.com/ZheC/Realtime_Multi-Person_Pose_Estimation). In addition, OpenPose would not be possible without the [CMU Panoptic Studio dataset](http://domedb.perception.cs.cmu.edu). We would also like to thank all the people who helped OpenPose in any way.

This repository and its documentation assumes knowledge of [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose). If you have not used OpenPose yet, you must familiare yourself with it before attempting to follow this documentation.



## Functionality
- **Training code** for [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose).
- Release of some **experimental models** that have not been included into [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose). These models are experimental and might present some issues compared to the models officially released inside OpenPose.
This project is licensed under the terms of the [license](LICENSE).
    - Whole-body pose estimation models from [Single-Network Whole-Body Pose Estimation](https://www.gineshidalgo.com/#section-5c3aab65b18d8).
    - Alternative to the `BODY_25` model of OpenPose, with higher accuracy but slower speed.



## Testing
See [testing/README.md](testing/README.md) for more details.



## Training
The [training/](training/) directory contains multiple scripts to generate the scripts for training and to actually train the models. See [training/README.md](training/README.md) for more details.



## Validation
The [validation/](validation/) directory contains multiple scripts to evaluate the accuracy of the trained models. See [validation/README.md](validation/README.md) for more details.



## Citation
Please cite these papers in your publications if it helps your research (the face keypoint detector was trained using the procedure described in [Simon et al. 2017] for hands):

    @inproceedings{hidalgo2019singlenetwork,
      author = {Gines Hidalgo and Yaadhav Raaj and Haroon Idrees and Donglai Xiang and Hanbyul Joo and Tomas Simon and Yaser Sheikh},
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
