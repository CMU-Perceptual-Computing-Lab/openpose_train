# Detectron to Masks
----------------------------------------------------------------------------------------------------



## Introduction
This code generates the masks for the parts of each image where the people is not labeled. Use only the following files:
- [detectron_to_masks/process_facemaskout.m](./process_facemaskout.m): Applied to the only face dataset that might contain unlabeled people, called Face Mask Out. This dataset is also the only face one that might contain more than 1 person per image.
- [detectron_to_masks/process_handdome.m](./process_handdome.m): Applied to the Hand Dome dataset.
- [detectron_to_masks/process_handmpii.m](./process_handmpii.m): Applied to the Hand MPII dataset.
