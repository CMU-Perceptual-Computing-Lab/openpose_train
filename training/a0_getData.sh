#!/bin/bash
######################### DOWNLOADING AND UNZIPPING REQUIRED FILES AND DATASET #########################
clear && clear

# User configurable options
DOWNLOAD_TEST_DATA=NO
REMOVE_ZIPS_AFTER_UNZIPPED=NO
REMOVE_IMAGES_FOLDERS_IF_PREVIOUSLY_UNZIPPED=YES

# Parameters
ANNOTATIONS_FOLDER=./cocoapi/
IMAGES_FOLDER=${ANNOTATIONS_FOLDER}images/



echo 'Installing pre-requisites'
sudo apt-get install python-matplotlib python-numpy python-pil python-scipy build-essential cython python-skimage
echo ' '



echo 'Creating dataset folder structure...'
cd ..
mkdir -p dataset
mkdir -p dataset/COCO/
cd dataset/COCO/
echo ' '

echo 'Cloning COCO API...'
# git clone https://github.com/cocodataset/cocoapi.git
git clone https://github.com/gineshidalgo99/cocoapi.git

echo 'Creating required folders in dataset/COCO/...'
mkdir -p json
mkdir -p mat
echo ' '

echo 'Removing previous image folders (optional)...'
if [ ${REMOVE_IMAGES_FOLDERS_IF_PREVIOUSLY_UNZIPPED} = "YES" ]; then
    echo Removing ${ANNOTATIONS_FOLDER}annotations/...
    rm -rf ${ANNOTATIONS_FOLDER}annotations/
    echo Removing ${IMAGES_FOLDER}train2017/...
    rm -rf ${IMAGES_FOLDER}train2017/
    echo Removing ${IMAGES_FOLDER}val2017/...
    rm -rf ${IMAGES_FOLDER}val2017/
else
    echo 'Skipped'
fi
echo ' '

echo 'Downloading and unzip -q oficial COCO dataset (multi-threaded)...'
wget -c http://images.cocodataset.org/annotations/annotations_trainval2017.zip -P $ANNOTATIONS_FOLDER
# Thread starts
unzip -q ${ANNOTATIONS_FOLDER}annotations_trainval2017.zip -d $ANNOTATIONS_FOLDER/ &
wget -c http://images.cocodataset.org/annotations/image_info_test2017.zip -P $ANNOTATIONS_FOLDER
wait
# Thread ends
# Thread starts
unzip -q ${ANNOTATIONS_FOLDER}image_info_test2017.zip -d $ANNOTATIONS_FOLDER/ &
wget -c http://images.cocodataset.org/zips/train2017.zip -P $IMAGES_FOLDER
wait
# Thread ends
# Thread starts
unzip -q ${IMAGES_FOLDER}train2017.zip -d $IMAGES_FOLDER &
wget -c http://images.cocodataset.org/zips/val2017.zip -P $IMAGES_FOLDER
wait
# Thread ends
unzip -q ${IMAGES_FOLDER}val2017.zip -d $IMAGES_FOLDER
echo ' '



echo 'Testing data (optional)...'
if [ ${DOWNLOAD_TEST_DATA} = "YES" ]; then
    # Download and unzip -q oficial COCO test dataset
    wget -c http://images.cocodataset.org/zips/test2017.zip -P $IMAGES_FOLDER
    if [ ${REMOVE_IMAGES_FOLDERS_IF_PREVIOUSLY_UNZIPPED} = "YES" ]; then
        echo Removing ${IMAGES_FOLDER}test2017/...
        rm -rf ${IMAGES_FOLDER}test2017/
    fi
    unzip -q ${IMAGES_FOLDER}test2017.zip -d $IMAGES_FOLDER
else
    echo 'Skipped'
fi
echo ' '



echo 'Optional - Saving space by removing original zip files (optional)...'
if [ ${REMOVE_ZIPS_AFTER_UNZIPPED} = "YES" ]; then
    rm -f person_keypoints_trainval2017.zip
    rm -f ${IMAGES_FOLDER}train2017.zip
    rm -f ${IMAGES_FOLDER}val2017.zip
    rm -f ${IMAGES_FOLDER}test2017.zip
else
    echo 'Skipped'
fi
echo ' '



echo 'Script finished'
