# Validation
----------------------------------------------------------------------------------------------------



## Contents
1. [Prerequisites](#prerequisites)
2. [Validation](#validation)
    1. [Auto-Validation during Training](#auto-validation-during-training)
    2. [Validation of Specific Models](#validation-of-specific-models)



## Prerequisites
All the following scripts are meant to be used with our modified version of the [Matlab COCO API](https://github.com/gineshidalgo99/cocoapi.git), cloned into `dataset/COCO/` as `dataset/COCO/cocoapi/`.



## Validation
This directory contains multiple scripts to evaluate the accuracy of the trained models. It is split into 2 sections:
1. [Auto-Validation during Training](#auto-validation-during-training): Used to find the best models of each training session.
2. [Validation of Specific Models](#validation-of-specific-models): Used to debug or analyze the best models accross different training sessions.

All the following scripts are meant to be used with our modified version of the [Matlab COCO API](https://github.com/gineshidalgo99/cocoapi.git), cloned into `dataset/COCO/` as `dataset/COCO/cocoapi/`.



### Auto-Validation during Training
In my case, I duplicate this repo once on each one of my servers. Then, I move the models and other useful files into a central NAS (i.e., storage) server. Finally, I process it. Script (a) is run on each server. Scripts (b)-(h) are run from the central server. This is why the following scripts:
- [validation/a_copyModels.sh.example](./a_copyModels.sh.example): While training OpenPose, this script automatically copies the important files (each model snapshot, all prototxt files, and the txt log file) into the desired folder with the desired name. Only `EXPERIMENT` and `SHARED_FOLDER` should be modified between experiments. This script should be duplicated and edited as `validation/a_copyModels.sh` on each training folder in order to be used (which is included in the gitignore file so it can be added in multiple training servers).
- [validation/a_copyModelsCar.sh.example](./a_copyModelsCar.sh.example): Analog to `validation/a_copyModels.sh.example`, but applied to the car dataset. Experimental and not released work. See [car/README.md](../car/README.md) for more details.
- [validation/b_emptyCocoJsons.sh](./b_emptyCocoJsons.sh): If there is not enough time to test all models, this script will generate empty files for the desired models (e.g., if not enough time to test them all, useful for the models generated during the first 150k iterations).
- [validation/b_getCocoJsons.sh.example](./b_getCocoJsons.sh.example): This script automatically test each model snapshot with OpenPose and generates the JSON file that can be read with the [official COCO API](https://github.com/cocodataset/cocoapi). It should also be renamed as `validation/b_getCocoJsons.sh` on each training duplicate of this repo.
- [validation/c_plotTrainLoss.m](./c_plotTrainLoss.m): Given the txt file auto-generated during training, this Matlab script displays a graph where the x-axis represents the number of iterations and the y-axis the loss during training. Usefull to make sure the network is behaving properly. Note that after about 20k-30k iterations, this graph does not seem to improve anymore. However, the accuracy during testing/validation still improves an additional 5-10% after that. If displayed in log-log scale, then you can appreciate it keeps improving.
- [validation/d_plotAccuracies.m](./d_plotAccuracies.m): Given all the generated JSON files, this Matlab script will display them all into the same figure. It allows multiple training sequences that will be displayed in different figures.



### Validation of Specific Models
- [validation/e_getValidations.m](./e_getValidations.m): Given specific JSON files, it prints the accuracy of that model on the command line.
- [validation/f_getFalsePosNeg.m](./f_getFalsePosNeg.m): Given a specific JSON file, it looks for images with false positives or negatives for model debugging.
- [validation/g_getLowAccurateImages.m](./g_getLowAccurateImages.m): Given a specific JSON file, it looks for images with low accuracy for model debugging.
- [validation/h_readCaffeNet.ipynb](./h_readCaffeNet.ipynb): Given a specific JSON file, it reads and displays the value of its layers.
