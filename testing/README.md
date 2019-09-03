# Testing
----------------------------------------------------------------------------------------------------



## Introduction
For testing, use the official [OpenPose](https://github.com/CMU-Perceptual-Computing-Lab/openpose). Simply copy the trained models into the `models` directory inside OpenPose, and run the scripts in [{OPENPOSE}/scripts/tests](https://github.com/CMU-Perceptual-Computing-Lab/openpose/tree/master/scripts/tests), following the instructions provided for each different model.

In addition, this directory contains:
- [testing/a_prepareTestDevFolder.m](./a_prepareTestDevFolder.m): It creates the `test_dev` image directory out of the test image directory. Useful to run the `test_dev` analysis.
