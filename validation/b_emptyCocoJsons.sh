#!/bin/bash
# Script to extract COCO JSON file for each trained model
clear && clear

echo "Parameters to change"
NUMBER_FOLDER=25
EXPERIMENT=1_25BAllMpii
NUMBER_FOLDER=135
EXPERIMENT=100_135AlmostSameBatchAllGPUs


echo "Common parameters to both files a_*.sh and b_*.sh"
SHARED_FOLDER=/media/posefs3b/Users/gines/openpose_train/training_results/${EXPERIMENT}/pose/body_${NUMBER_FOLDER}/
# SHARED_FOLDER=/media/posefs3b/Users/gines/openpose_train/training_results/${EXPERIMENT}/pose/body_${NUMBER_FOLDER}b/
# SHARED_FOLDER=/media/posefs3b/Users/gines/openpose_train/training_results/${EXPERIMENT}/pose/body_${NUMBER_FOLDER}d/
# SHARED_FOLDER=/media/posefs3b/Users/gines/openpose_train/training_results/${EXPERIMENT}/pose/body_${NUMBER_FOLDER}e/
# SHARED_FOLDER=/media/posefs3b/Users/gines/openpose_train/training_results/${EXPERIMENT}/pose/body_${NUMBER_FOLDER}n/
# SHARED_FOLDER=/media/posefs3b/Users/gines/openpose_train/training_results/${EXPERIMENT}/pose/body_${NUMBER_FOLDER}_x2/
echo " "

echo "Paths"
# Body
JSON_FOLDER_1=${SHARED_FOLDER}1scale/
JSON_FOLDER_4=${SHARED_FOLDER}4scales/
# Foot
JSON_FOLDER_1_foot=${SHARED_FOLDER}foot_1scale/
JSON_FOLDER_4_foot=${SHARED_FOLDER}foot_4scales/
# Face
JSON_FOLDER_1_frgc=${SHARED_FOLDER}frgc_1scale/
JSON_FOLDER_4_frgc=${SHARED_FOLDER}frgc_4scales/
JSON_FOLDER_1_mpie=${SHARED_FOLDER}mpie_1scale/
JSON_FOLDER_4_mpie=${SHARED_FOLDER}mpie_4scales/
JSON_FOLDER_1_faceMaskOut=${SHARED_FOLDER}faceMask_1scale/
JSON_FOLDER_4_faceMaskOut=${SHARED_FOLDER}faceMask_4scales/
# Hand
JSON_FOLDER_1_hand_dome=${SHARED_FOLDER}hand_dome_1scale/
JSON_FOLDER_4_hand_dome=${SHARED_FOLDER}hand_dome_4scales/
JSON_FOLDER_1_hand_mpii=${SHARED_FOLDER}hand_mpii_1scale/
JSON_FOLDER_4_hand_mpii=${SHARED_FOLDER}hand_mpii_4scales/

# Create folders
# Body
mkdir $JSON_FOLDER_1
mkdir $JSON_FOLDER_4
# Foot
mkdir $JSON_FOLDER_1_foot
mkdir $JSON_FOLDER_4_foot
# Face
mkdir $JSON_FOLDER_1_frgc
mkdir $JSON_FOLDER_4_frgc
mkdir $JSON_FOLDER_1_mpie
mkdir $JSON_FOLDER_4_mpie
mkdir $JSON_FOLDER_1_faceMaskOut
mkdir $JSON_FOLDER_4_faceMaskOut
# Hand
mkdir $JSON_FOLDER_1_hand_dome
mkdir $JSON_FOLDER_4_hand_dome
mkdir $JSON_FOLDER_1_hand_mpii
mkdir $JSON_FOLDER_4_hand_mpii
echo " "





# Different code than a_*.sh
echo "Running OpenPose for each model"
MODEL_FOLDER=$(dirname $(dirname ${SHARED_FOLDER}))/
pwd
# Sorted in natural order (NAT sort)
for modelPath in `ls -v ${SHARED_FOLDER}*.caffemodel`; do
# Not NAT sort
# for modelPath in ${SHARED_FOLDER}*.caffemodel; do
    modelName=$(basename ${modelPath})
    finalJsonFile4=${JSON_FOLDER_4}${modelName}_4.json
    finalJsonFile1_f=${JSON_FOLDER_1_f}${modelName}_1.json
    finalJsonFile4_f=${JSON_FOLDER_4_f}${modelName}_4.json

    echo "Processing $modelName in $EXPERIMENT"
    # 4 scales
    if [ -f $finalJsonFile4 ]; then
        echo "4-scale model already exist."
    else
        touch $finalJsonFile4
    fi

    # 1 scale - Foot
    if [ -f $finalJsonFile1_f ]; then
        echo "1-scale foot model already exist."
    else
        touch $finalJsonFile1_f
    fi

    # 4 scales - Foot
    if [ -f $finalJsonFile4_f ]; then
        echo "4-scale foot model already exist."
    else
        touch $finalJsonFile4_f
    fi

    # Face - 4 scales
    finalJsonFile4_frgc=${JSON_FOLDER_4_frgc}${modelName}_4.json
    finalJsonFile4_mpie=${JSON_FOLDER_4_mpie}${modelName}_4.json
    finalJsonFile4_faceMaskOut=${JSON_FOLDER_4_faceMaskOut}${modelName}_4.json
    if [ -f $finalJsonFile4_frgc ]; then
        echo "4-scale face model already exist."
    else
        touch $finalJsonFile4_frgc
        touch $finalJsonFile4_mpie
        touch $finalJsonFile4_faceMaskOut
    fi

    # Hand - 4 scales
    finalJsonFile4_hand_dome=${JSON_FOLDER_4_hand_dome}${modelName}_4.json
    finalJsonFile4_hand_mpii=${JSON_FOLDER_4_hand_mpii}${modelName}_4.json
    if [ -f $finalJsonFile4_hand_dome ]; then
        echo "4-scale hand model already exist."
    else
        touch $finalJsonFile4_hand_dome
        touch $finalJsonFile4_hand_mpii
    fi

    # echo $modelPath
    echo " "
done
echo " "





echo "Finished! Exiting script..."
echo " "
