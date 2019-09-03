#!/bin/bash

OPENPOSE_TRAINING_URL=http://posefs1.perception.cs.cmu.edu/OpenPose/training/

mkdir ../dataset
cd ../dataset

# COCO LMDB
DATASET_DIR=lmdb_coco2017
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb

# COCO Foot LMDB
DATASET_DIR=lmdb_coco2017_foot
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb

# COCO Negative LMDB
DATASET_DIR=lmdb_background
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb

# MPII LMDB
DATASET_DIR=lmdb_mpii
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb

# Face 1/3 LMDB
DATASET_DIR=lmdb_face_frgc
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb
# Face 2/3 LMDB
DATASET_DIR=lmdb_face_mask_out
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb
# Face 3/3 LMDB
DATASET_DIR=lmdb_face_multipie
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb

# Hand 1/2 LMDB
DATASET_DIR=lmdb_hand_dome
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb
# Hand 2/2 LMDB
DATASET_DIR=lmdb_hand_mpii
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb

# Dome Whole-Body LMDB
DATASET_DIR=lmdb_dome135
echo 'Downloading ${DATASET_DIR}...'
mkdir ${DATASET_DIR}
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}data.mdb
wget -nc --directory-prefix=${DATASET_DIR} 		${OPENPOSE_TRAINING_URL}${DATASET_DIR}lock.mdb
