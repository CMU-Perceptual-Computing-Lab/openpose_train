OPENPOSE_URL=http://posefs1.perception.cs.cmu.edu/OpenPose/training/



# Face 1 - frgc
LMDB_NAME=lmdb_face_frgc
LMDB_PATH=../dataset/${LMDB_NAME}/
mkdir ${LMDB_PATH}
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/data.mdb
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/lock.mdb



# Face 2 - mask_out
LMDB_NAME=lmdb_face_mask_out
LMDB_PATH=../dataset/${LMDB_NAME}/
mkdir ${LMDB_PATH}
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/data.mdb
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/lock.mdb



# Face 3 - multipie
LMDB_NAME=lmdb_face_multipie
LMDB_PATH=../dataset/${LMDB_NAME}/
mkdir ${LMDB_PATH}
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/data.mdb
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/lock.mdb
