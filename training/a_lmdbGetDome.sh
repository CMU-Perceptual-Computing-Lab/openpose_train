OPENPOSE_URL=http://posefs1.perception.cs.cmu.edu/OpenPose/training/



# Whole-Body Dome
LMDB_NAME=lmdb_dome135
LMDB_PATH=../dataset/${LMDB_NAME}/
mkdir ${LMDB_PATH}
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/data.mdb
wget -nc --directory-prefix=${LMDB_PATH} 		${OPENPOSE_URL}${LMDB_NAME}/lock.mdb
