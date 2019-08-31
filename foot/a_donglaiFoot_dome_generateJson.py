#!/usr/bin/python

# from ../training/a5_dome_generateJson import a5_dome_generateJson
import sys
sys.path.append('..')
from training.a5_dome_generateJson import readpoint, domeToOP, getBodies, getCurrentData
import cv2
from datetime import datetime
import io
import json
import numpy as np
import os
import sys

sDatasetInputPath = '/media/posefs0c/panopticdb/body_foot/'
sDatasetInputJsonPath = sDatasetInputPath + 'sample_list.json'
sDatasetOutputPath = '../dataset/dome/'
sJsonPath = sDatasetOutputPath + 'dome_foot_it1.json'
sNumberKeypoints=19+4
sImageScale=368

# SMC_BodyJoint_rFoot      = 0
SMC_BodyJoint_rBigToe    = 1
SMC_BodyJoint_rSmallToe  = 2
# SMC_BodyJoint_lFoot      = 3
SMC_BodyJoint_lBigToe    = 4
SMC_BodyJoint_lSmallToe  = 5

def domeFootToOP(openposeSkeleton2D, domeFoot2D, scores, isInsideImage, isVisible):
    domeFoot2D = np.array(domeFoot2D).transpose()
    openposeSkeleton2D.append(readpoint(domeFoot2D, scores, SMC_BodyJoint_rBigToe,   isInsideImage, isVisible)) # OPENPOSE = 19
    openposeSkeleton2D.append(readpoint(domeFoot2D, scores, SMC_BodyJoint_rSmallToe, isInsideImage, isVisible)) # OPENPOSE = 20
    openposeSkeleton2D.append(readpoint(domeFoot2D, scores, SMC_BodyJoint_lBigToe,   isInsideImage, isVisible)) # OPENPOSE = 21
    openposeSkeleton2D.append(readpoint(domeFoot2D, scores, SMC_BodyJoint_lSmallToe, isInsideImage, isVisible)) # OPENPOSE = 22
                                                                                               # Background     # OPENPOSE = 23
    return openposeSkeleton2D

def generateJsonFile():
    # Create output directory
    if not os.path.exists(sDatasetOutputPath):
        os.makedirs(sDatasetOutputPath)
    # Read sequence names
    sequencePath = sDatasetInputPath + 'imgs'
    # Option a)
    sDatasetInputJsonPath
    # Read JSON struct
    with open(sDatasetInputJsonPath) as jsonFile:
        inputJsonStruct = json.load(jsonFile)
    # Print JSON struct
    totalWriteCount = len(inputJsonStruct)
    printEveryXIterations = max(1, round(totalWriteCount / 100))
    outputJsonData = []
    outputJsonCount = 0
    for inputJsonIndex, inputJsonElement in enumerate(inputJsonStruct):
        # Progress bar
        if inputJsonIndex % printEveryXIterations == 0:
            print 'Sample %d of %d' % (inputJsonIndex+1, totalWriteCount)
        # Data
        # print inputJsonElement
        bodyPath = sDatasetInputPath + str(inputJsonElement['body'])
        footPath = sDatasetInputPath + str(inputJsonElement['foot'])
        imagePath = str(inputJsonElement['img'])
        fullImagePath = sDatasetInputPath + imagePath
        footInside = inputJsonElement['foot_inside']
        if footInside:
            # Body 2D
            bodies = getBodies(bodyPath)
            # Foot 2D
            with open(footPath) as jsonFile:
                foot2DData = json.load(jsonFile)
            for bodyId in bodies:
                # Get right foot data for the body
                foot2D = -1
                for foot in foot2DData:
                    # if body2D['id'] == foot['id']:
                    if bodyId == foot['id']:
                        foot2D = foot
                        break
                # Percentage Visible and inside image
                visibility = [-occluded+1 for occluded in foot2D['occluded']]
                visibleAndInsideImg = [x * y for x, y in zip(visibility, foot2D['insideImg'])]
                percentageVisibleAndInsideImg = sum(visibleAndInsideImg) / float(len(visibleAndInsideImg))
                bodies[bodyId]['body'] = domeFootToOP(bodies[bodyId]['body'], foot2D['foot2d'], foot2D['scores'], foot2D['insideImg'], None)
                bodies[bodyId]['percentageVisibleAndInsideImgFoot'] = percentageVisibleAndInsideImg
            # Remove whole image if there is people highly (but not fully) occluded people
            # This is due the fact that occlussion is not a perfect metric and it might fail
            for bodyId in bodies:
                if bodies[bodyId]['percentageVisibleAndInsideImgFoot'] < 0.2:
                    bodies = [];
                    break
            # If at least an available body
            if len(bodies) > 0:
                # Image
                image = cv2.imread(fullImagePath)
                # Generate output JSON
                for bodyId in bodies:
                    if bodies[bodyId]['percentageVisibleAndInsideImg'] > 0.3 and bodies[bodyId]['percentageVisibleAndInsideImgFoot'] > 0.5:
                        currentData = getCurrentData(bodies, bodyId, imagePath, image, outputJsonCount)
                        # Add information to JSON data
                        outputJsonCount = outputJsonCount+1
                        outputJsonData.append(currentData)
                        # # Debugging - Write JSON file after every sequence
                        # writeEveryXIterations = max(1, round(totalWriteCount / 500))
                        # # I.e. if it crashes, at least a have a JSON until the last successful sequence
                        # if inputJsonIndex % writeEveryXIterations == 0:
                        #     print('Saving in ' + sJsonPath)
                        #     with open(sJsonPath, 'w+') as jsonFile:
                        #         jsonFile.write(json.dumps({"root":outputJsonData}))
    # Write JSON file
    with open(sJsonPath, 'w+') as jsonFile:
        jsonFile.write(json.dumps({"root":outputJsonData}))

# Main function
if __name__ == "__main__":
    startTime= datetime.now()
    generateJsonFile()
    print('Time elpased (hh:mm:ss.ms) {}'.format(datetime.now()-startTime))
