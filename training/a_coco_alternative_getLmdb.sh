######################### DOWNLOADING LMDB PREPARED DATASET #########################
# Parameters
FOLDER_LOCATION='../dataset/lmdb_coco/'
BASIC_URL='http://posefs1.perception.cs.cmu.edu/OpenPose/training/body_18/lmdb_for_training/'

# Create desired folder
mkdir $FOLDER_LOCATION

# Download LMDB files
wget -nc --directory-prefix=$FOLDER_LOCATION  	${BASIC_URL}data.mdb
wget -nc --directory-prefix=$FOLDER_LOCATION    ${BASIC_URL}lock.mdb
