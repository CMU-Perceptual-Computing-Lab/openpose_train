# Face
----------------------------------------------------------------------------------------------------



## Introduction
It generates the initial face JSONs, to be later used to generate the final JSONs and LMDB files following the instructions in the [training/](../training) directory.

- [face/a1_datasetToJsonFormat.py](./a1_datasetToJsonFormat.py): It generates the initial face JSONs.
- [face/a2_createMaskOutFolder.bash](./a2_createMaskOutFolder.bash): It generates the mask for the non-labeled bodies to be later combined with the initial JSON to generate the final JSON and LMDB.
- [face/z0_multipieToPtsFormat.m](./z0_multipieToPtsFormat.m), [face/z1_visualizeCOFWColor.m](./z1_visualizeCOFWColor.m), and [face/z2_helenTxtToPtsFormat.m](./z2_helenTxtToPtsFormat.m) are deprecated files initially used for debugging.
