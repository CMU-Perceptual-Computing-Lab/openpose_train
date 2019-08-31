# Run OpenPose on Desired Dome sequences

import os
from datetime import datetime

# Time measurement
startTime= datetime.now() 

# Data
domePath = '/media/posefs0c/panoptic/';
outputPath = '/media/posefs0c/panoptic_foot/v1/';
sSequencePaths = [
    '161029_sports1/vgaImgs/',
    '170228_haggling_a3/vgaImgs/',
    '170228_haggling_b3/vgaImgs/',
    '170404_haggling_a3/vgaImgs/',
    '170404_haggling_b3/vgaImgs/',
    '170407_haggling_a3/vgaImgs/',
    '170407_haggling_b3/vgaImgs/'
];
sSequenceRanges = [
    [100, 1400],
    [8500, 13200],
    [11350, 18400],
    [4600, 9900],
    [8250, 15750],
    [6850, 11650],
    [8500, 14300]
];
opPath = '/home/gines/Dropbox/Perceptual_Computing_Lab/openpose/openpose/';
opBasicCommand = 'cd ' + opPath + ' && ./build/examples/openpose/openpose.bin --model_pose BODY_23'
numberSequences = len(sSequencePaths);
if numberSequences != len(sSequenceRanges):
    raise ValueError("numberSequences != len(sSequenceRanges)!")

# Create output folder
if not os.path.exists(outputPath):
    os.mkdir(outputPath)

# Processing DomeDB sequences
print('Processing DomeDB sequences...\n');
for index in range(0, numberSequences):
# for index in range(0, 1):
    for panel in range(1, 20+1):
        print('\n')
        for camera in range(1, 24+1):
            ## For debugging
            # if panel != 3:
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
                        + ' --frame_first ' + str(sSequenceRanges[index][0]) + ' --frame_last ' + str(sSequenceRanges[index][1]) \
                        + ' --write_keypoint_json ' + outputFolder + ' --no_display --render_pose 0'
            os.system(bashCommand);
            # print(bashCommand)

print('\nDomeDB sequences processed!\n');

# Total running time
timeElapsed = datetime.now() - startTime 
print('Time elpased (hh:mm:ss.ms) {}'.format(timeElapsed))
