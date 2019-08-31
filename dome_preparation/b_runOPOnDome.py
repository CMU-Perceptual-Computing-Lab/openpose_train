# Run OpenPose on Desired Dome sequences

import os
from datetime import datetime

# Time measurement
startTime = datetime.now() 

# Data
domePath = '/media/posefs0c/panoptic/';
outputPath = '/media/posefs0c/panoptic_openpose/v1_2017_10_19/';
sSequencePaths = [
    '160224_haggling1/hdImgs/',
    '160226_haggling1/hdImgs/',
    '160422_haggling1/hdImgs/',
    '161202_haggling1/hdImgs/',
    '170221_haggling_b1/hdImgs/',
    '170221_haggling_b2/hdImgs/',
    '170221_haggling_b3/hdImgs/',
    '170221_haggling_m1/hdImgs/',
    '170221_haggling_m2/hdImgs/',
    '170221_haggling_m3/hdImgs/',
    '170224_haggling_a1/hdImgs/',
    '170224_haggling_a2/hdImgs/',
    '170224_haggling_a3/hdImgs/',
    '170224_haggling_b1/hdImgs/',
    '170224_haggling_b2/hdImgs/',
    '170224_haggling_b3/hdImgs/',
    '170228_haggling_a1/hdImgs/',
    '170228_haggling_a2/hdImgs/',
    '170228_haggling_a3/hdImgs/',
    '170228_haggling_b1/hdImgs/',
    '170228_haggling_b2/hdImgs/',
    '170228_haggling_b3/hdImgs/',
    '170404_haggling_a1/hdImgs/',
    '170404_haggling_a2/hdImgs/',
    '170404_haggling_a3/hdImgs/',
    '170404_haggling_b1/hdImgs/',
    '170404_haggling_b2/hdImgs/',
    '170404_haggling_b3/hdImgs/',
    '170407_haggling_a1/hdImgs/',
    '170407_haggling_a2/hdImgs/',
    '170407_haggling_a3/hdImgs/',
    '170407_haggling_b1/hdImgs/',
    '170407_haggling_b2/hdImgs/',
    '170407_haggling_b3/hdImgs/'
];
opPath = '/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/openpose/';
opBasicCommand = 'cd ' + opPath + ' && ./build/examples/openpose/openpose.bin'
numberSequences = len(sSequencePaths);

# Create output folder
if not os.path.exists(outputPath):
    os.mkdir(outputPath)

# Processing DomeDB sequences
print('Processing DomeDB sequences...\n');
for index in range(0, numberSequences):
# for index in range(0, 1):
    for panel in range(0, 1):
        print('\n')
        for camera in range(0, 30+1):
            ## For debugging
            # if panel != 0:
            #     continue
            # if camera != 1:
            #     continue
            ## Subfolder
            subSequencePath = sSequencePaths[index] + str(panel).zfill(2) + '_' + str(camera).zfill(2)
            ## Sequence names
            sequencePath = domePath + subSequencePath;
            # print(sequencePath + '\n');
            ## Output sequence folder
            outputFolder = outputPath + subSequencePath;
            if not os.path.exists(outputFolder):
                os.makedirs(outputFolder)
            print('\n' + outputFolder);
            ## Run Openpose
            bashCommand = opBasicCommand + ' --image_dir ' + sequencePath \
                        + ' --write_keypoint_json ' + outputFolder + ' --no_display --render_pose 0'
            os.system(bashCommand);
            # print(bashCommand)

print('\nDomeDB sequences processed!\n');

# Total running time
timeElapsed = datetime.now() - startTime 
print('Time elpased (hh:mm:ss.ms) {}'.format(timeElapsed))
