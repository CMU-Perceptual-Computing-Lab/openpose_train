#!/usr/bin/python

# MPII annotation meaning:
# http://human-pose.mpi-inf.mpg.de/#download

import cv2
from datetime import datetime
import io
import json
import numpy as np
import os
import sys
from b1_dome_generateJson import getTime

sDatasetFolder = os.path.abspath('../dataset/') + '/'
sMpiiHandImagesFolder = sDatasetFolder + 'COCO/Tomas/hand_labels/' + 'manual_train/'
sDatasetOutputPath = sDatasetFolder + 'dome/'
sJsonPath = sDatasetOutputPath + 'MPII_hand.json'
sImageScale=368
sNumberKeypoints=19+2*20

BodyJoint_rAnkle    = 0
BodyJoint_rKnee     = 1
BodyJoint_rHip      = 2
BodyJoint_lAnkle    = 3
BodyJoint_lKnee     = 4
BodyJoint_lHip      = 5
# BodyJoint_pelvis    = 6
# BodyJoint_thorax    = 7
# BodyJoint_upperNeck = 8
# BodyJoint_headTop   = 9
BodyJoint_rWrist    = 10
BodyJoint_rElbow    = 11
BodyJoint_rShoulder = 12
BodyJoint_lShoulder = 13
BodyJoint_lElbow    = 14
BodyJoint_lWrist    = 15
# Unknown
BodyJoint_nose = -1
BodyJoint_neck = -1
BodyJoint_bodyCenter = -1
BodyJoint_rEye = -1
BodyJoint_lEye = -1
BodyJoint_rEar = -1
BodyJoint_lEar = -1

def readpoint(mpiiKeypoints2D, idx):
    if idx >= 0:
        x = mpiiKeypoints2D[0, idx]
        y = mpiiKeypoints2D[1, idx]
        isVisible = mpiiKeypoints2D[2, idx]
        # Keypoints
        # Value visible + inside image
        if 0.95 <= isVisible and isVisible <= 1.01:
            return [x, y, 1.0]
        # Value occluded but found
        else:
            return [x, y, 2.0]
    else:
        return [0, 0, 2.0]

def mpiiToOP(mpiiKeypoints2D):
    mpiiKeypoints2D = np.array(mpiiKeypoints2D).transpose()
    keypoints2D=[]
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_nose))          #OPENPOSE_Nose      = 0
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_neck))          #OPENPOSE_Neck      = 1
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rShoulder))     #OPENPOSE_RShoulder = 2
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rElbow))        #OPENPOSE_RElbow    = 3
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rWrist))        #OPENPOSE_RWrist    = 4
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lShoulder))     #OPENPOSE_LShoulder = 5
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lElbow))        #OPENPOSE_LElbow    = 6
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lWrist))        #OPENPOSE_LWrist    = 7
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_bodyCenter))    #OPENPOSE_LowerAbs  = 8
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rHip))          #OPENPOSE_RHip      = 9
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rKnee))         #OPENPOSE_RKnee     = 10
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rAnkle))        #OPENPOSE_RAnkle    = 11
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lHip))          #OPENPOSE_LHip      = 12
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lKnee))         #OPENPOSE_LKnee     = 13
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lAnkle))        #OPENPOSE_LAnkle    = 14
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rEye))          #OPENPOSE_REye      = 15
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lEye))          #OPENPOSE_LEye      = 16
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_rEar))          #OPENPOSE_REar      = 17
    keypoints2D.append(readpoint(mpiiKeypoints2D, BodyJoint_lEar))          #OPENPOSE_LEar      = 18
                                                                            #OPENPOSE_Bkg       = 19
    return keypoints2D

def handToOP(keypoints2D, hand2D, isRightHand):
    hand2D = np.array(hand2D).transpose()
    if not isRightHand:
        for index in range(1, 20+1): # hand[0] is wrist --> already in body
            keypoints2D.append(readpoint(hand2D, index))
        for index in range(1, 20+1): # hand[0] is wrist --> already in body
            keypoints2D.append([0.0, 0.0, 2.0])
    else:
        for index in range(1, 20+1): # hand[0] is wrist --> already in body
            keypoints2D.append([0.0, 0.0, 2.0])
        for index in range(1, 20+1): # hand[0] is wrist --> already in body
            keypoints2D.append(readpoint(hand2D, index))
    return keypoints2D

def getCurrentData(body, bbox, imagePath, image, outputJsonCount):
    currentData = {}
    currentData['dataset'] = 'MPII_hand'
    currentData['img_paths'] = imagePath
    # Output JSON
    currentData['img_width'] = image.shape[1]
    currentData['img_height'] = image.shape[0]
    currentData['objpos'] = [bbox[0]+bbox[2]/2, bbox[1]+bbox[3]/2]
    currentData['bbox'] = bbox
    # currentData['confidence'] = bbox['scores']
    # currentData['segment_area'] = []
    currentData['num_keypoints'] = sNumberKeypoints
    currentData['annolist_index'] = outputJsonCount
    currentData['joint_self'] = body
    currentData['scale_provided'] = bbox[3] / sImageScale
    currentData['joint_others'] = []
    currentData['scale_provided_other'] = []
    currentData['objpos_other'] = []
    # currentData['bbox_other'] = []
    # currentData['segment_area_other'] = []
    currentData['num_keypoints_other'] = 0
    currentData['people_index'] = 0
    currentData['numOtherPeople']= 0
    # Shared with Depth data
    currentData['depth_enabled'] = 0
    return currentData

def getBodyKeypoints(inputJsonStruct):
    # Get keypoints
    bodyKeypoints = inputJsonStruct['mpii_body_pts']
    body = mpiiToOP(bodyKeypoints)
    handKeypoints = inputJsonStruct['hand_pts']
    isRightHand = not inputJsonStruct['is_left']
    return handToOP(body, handKeypoints, isRightHand)

def getHandBoundingBox(inputJsonStruct):
    handKeypoints = inputJsonStruct['hand_pts']
    handCenter = inputJsonStruct['hand_box_center'] # Same than minX + width/2

    # Max/min
    minX = float("inf")
    maxX = 0
    minY = float("inf")
    maxY = 0
    for index in range(0, 20+1): # hand[0] is wrist --> already in body
        x = handKeypoints[index][0]
        y = handKeypoints[index][1]
        isVisible = handKeypoints[index][2]
        if isVisible:
            if minX > x:
                minX = x
            if maxX < x:
                maxX = x
            if minY > y:
                minY = y
            if maxY < y:
                maxY = y
    width = maxX - minX
    height = maxY - minY
    maxWH = 1.5 * max(width, height)
    bbox = [handCenter[0] - maxWH/2, handCenter[1] - maxWH/2, maxWH, maxWH]
    return bbox

def generateJsonFile():
    # Time measurement
    startTime = datetime.now()

    # Data to be saved
    outputJsonData = []
    outputJsonCount = 0

    # Prepare output JSON data
    filePaths = sorted(os.listdir(sMpiiHandImagesFolder)) #, reverse=True)
    totalWriteCount = len(filePaths)/2
    printEveryXIterations = max(1, round(totalWriteCount / 50))
    for index, filePath in enumerate(filePaths):
        if filePath[-5:] == '.json':
            # Progress bar
            realIndex = index/2
            if realIndex % printEveryXIterations == 0:
                print ('Sample %d of %d, ' + getTime(startTime)) % (realIndex, totalWriteCount)
            # Read JSON struct
            with open(sMpiiHandImagesFolder + filePath) as jsonFile:
                inputJsonStruct = json.load(jsonFile)
            # Image
            imagePath = filePath[:-5] + '.jpg'
            imageFullPath = sMpiiHandImagesFolder + imagePath
            image = cv2.imread(imageFullPath)
            # Get keypoints
            body = getBodyKeypoints(inputJsonStruct)
            bbox = getHandBoundingBox(inputJsonStruct)
            handCenter = inputJsonStruct['hand_box_center']
            currentData = getCurrentData(body, bbox, imagePath, image, outputJsonCount)
            # Add information to JSON data
            outputJsonData.append(currentData)
            outputJsonCount = outputJsonCount+1

    # How many samples?
    print 'How many samples? ' + str(outputJsonCount)

    # Write JSON file
    with open(sJsonPath, 'w+') as jsonFile:
        jsonFile.write(json.dumps({"root":outputJsonData}))

    # Time measurement
    print('Final ' + getTime(startTime))

# Main function
if __name__ == "__main__":
    generateJsonFile()
