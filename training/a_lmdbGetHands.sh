OPENPOSE_URL=http://posefs1.perception.cs.cmu.edu/OpenPose/training/



# Hand 1 - Dome
LMDB_NAME=lmdb_hand_dome
LMDB_PATH=../dataset/${LMDB_NAME}/
mkdir ${LMDB_PATH}
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/data.mdb
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/lock.mdb



# Hand 2 - MPII
LMDB_NAME=lmdb_hand_mpii
LMDB_PATH=../dataset/${LMDB_NAME}/
mkdir ${LMDB_PATH}
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/data.mdb
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/lock.mdb
