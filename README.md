# OpenPose Training (Experimental)

<div align="center">
    <img src=".github/Logo_main_black.png", width="300">
</div>

-----------------



## Contents
1. [Introduction](#introduction)
2. [Functionality](#functionality)
3. [Testing](#testing)
4. [Training](#training)
5. [Citation](#citation)
6. [License](#license)



## Experimental Disclaimer
While [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose) is highly tested and stable, this training repository is highly experimental and not production ready. Use at your own risk.

This repository was used and tested on Ubuntu 16 with CUDA 8, and it compiles in Ubuntu 20 with WSL2 (Windows 11). It should work with other versions of Ubuntu and up to CUDA 10, but it might require modifications.



## Introduction
[**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose) has represented the **first real-time multi-person system to jointly detect human body, hand, facial, and foot keypoints (in total 135 keypoints) on single images**.

It is **authored by** [**Ginés Hidalgo**](https://www.gineshidalgo.com), [**Zhe Cao**](https://people.eecs.berkeley.edu/~zhecao), [**Tomas Simon**](http://www.cs.cmu.edu/~tsimon), [**Shih-En Wei**](https://scholar.google.com/citations?user=sFQD3k4AAAAJ&hl=en), [**Yaadhav Raaj**](https://www.raaj.tech), [**Hanbyul Joo**](https://jhugestar.github.io), **and** [**Yaser Sheikh**](http://www.cs.cmu.edu/~yaser). It is **maintained by** [**Ginés Hidalgo**](https://www.gineshidalgo.com) **and** [**Yaadhav Raaj**](https://www.raaj.tech). OpenPose would not be possible without the [**CMU Panoptic Studio dataset**](http://domedb.perception.cs.cmu.edu). We would also like to thank all the people who [has helped OpenPose in any way](doc/09_authors_and_contributors.md).

[**OpenPose Training**](https://github.com/CMU-Perceptual-Computing-Lab/openpose_training) includes the training code for [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose), as well as some experimental models that might not necessarily end up in OpenPose (to avoid confusing its users with too many models).

This repository and its documentation assumes knowledge of [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose). If you have not used OpenPose yet, you must familiare yourself with it before attempting to follow this documentation.



## Functionality
- **Training code** for [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose).
- Release of some **experimental models** that have not been included into [**OpenPose**](https://github.com/CMU-Perceptual-Computing-Lab/openpose). These models are experimental and might present some issues compared to the models officially released inside OpenPose.
This project is licensed under the terms of the [license](LICENSE).
    - `BODY_135`: Whole-body pose estimation models from [Single-Network Whole-Body Pose Estimation](https://arxiv.org/abs/1909.13423).
    - `BODY_25B`: Alternative to the `BODY_25` model of OpenPose, with higher accuracy but slower speed.



## Experimental Models
The `experimental_models` directory contains our experimental models, including the whole-body model from [Single-Network Whole-Body Pose Estimation](README.md#citation), as well as instructions to make it run inside [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose). See [experimental_models/README.md](experimental_models/README.md) for more details.



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

- [Single-Network Whole-Body Pose Estimation](https://arxiv.org/abs/1909.13423)
- [OpenPose: Realtime Multi-Person 2D Pose Estimation using Part Affinity Fields](https://arxiv.org/abs/1812.08008)



## License
OpenPose is freely available for free non-commercial use, and may be redistributed under these conditions. Please, see the [license](./LICENSE) for further details. Interested in a commercial license? Check this [FlintBox link](https://cmu.flintbox.com/#technologies/b820c21d-8443-4aa2-a49f-8919d93a8740). For commercial queries, use the `Contact` section from the [FlintBox link](https://cmu.flintbox.com/#technologies/b820c21d-8443-4aa2-a49f-8919d93a8740) and also send a copy of that message to [Yaser Sheikh](mailto:yaser@cs.cmu.edu).
