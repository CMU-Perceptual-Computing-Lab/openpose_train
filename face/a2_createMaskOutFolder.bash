#!/bin/bash
clear && clear

BASE_FOLDER=/media/posefs3b/Users/gines/Datasets/face/tomas_ready/
FINAL_FOLDER=${BASE_FOLDER}face_mask_out/

echo 'Creating ${FINAL_FOLDER}...'
mkdir ${FINAL_FOLDER}

# Helen
echo 'Copying Helen images...'
cp -rf ${BASE_FOLDER}helen/trainset/*.jpg ${FINAL_FOLDER}
cp -rf ${BASE_FOLDER}helen/testset/*.jpg ${FINAL_FOLDER}

# Ibug
echo 'Copying Ibug images...'
cp -rf ${BASE_FOLDER}ibug/*.jpg ${FINAL_FOLDER}

# lfpw
echo 'Copying lfpw images...'
cp -rf ${BASE_FOLDER}lfpw/trainset/*.png ${FINAL_FOLDER}
cp -rf ${BASE_FOLDER}lfpw/testset/*.png ${FINAL_FOLDER}
