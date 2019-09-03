# Car
----------------------------------------------------------------------------------------------------



## Introduction
This is experimental work that never worked. I add some basic instructions, but do not expect any support nor answer to your questions.

- [car/a1_coco_jsonToNegativesJson.m](./a1_coco_jsonToNegativesJson.m): It reads the COCO dataset and creates a JSON with all the images without cars on them. Note: I found in practice that COCO does not seem to label all cars, so unfortunately images with cars still appear.
- [car/a2_valJsonsToImageValFolders.m](./a2_valJsonsToImageValFolders.m): It creates the validation image folders for each one of the 3 datasets so the accuracy can be tested.
- [car/a_jsonToTrainValJsons.m](./a_jsonToTrainValJsons.m): Deprecated. Analog to `a2_valJsonsToImageValFolders.m`, but only works with the `car-fusion` dataset.



## Citation
Even though this is unpublished work, it follows all the ideas from our main paper, [Single-Network Whole-Body Pose Estimation](../README.md#citation). so please, cite it if this helps in your research.
