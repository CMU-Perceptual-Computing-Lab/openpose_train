# Body MPII
----------------------------------------------------------------------------------------------------



## Introduction
It generates the initial body MPII JSONs, to be later used to generate the final JSONs and LMDB files following the instructions in the [training/](../training) directory.

- [mpii/a0_convertMatToInitialJson.m](./a0_convertMatToInitialJson.m): It generates the initial face JSONs.
- [mpii/a1_generateFinalJsonAndMasks.m](./a1_generateFinalJsonAndMasks.m): It generates the final JSON and masks for the non-labeled bodies to be later used to generate the final LMDB.
