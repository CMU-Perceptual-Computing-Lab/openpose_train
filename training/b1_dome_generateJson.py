#!/usr/bin/python

import cv2
from datetime import datetime
import io
import json
import numpy as np
import os
import sys

sDatasetInputPath = '/media/posefs0c/panopticdb/a4/'
sDatasetInputJsonPath = sDatasetInputPath + 'sample_list_2d.json'
sDatasetOutputPath = '../dataset/dome/'
sImageScale=368
# Body (+ Face + Hands?)
sBodyOnly = True
# sBodyOnly = False
# Body
if sBodyOnly:
    sJsonPath = sDatasetOutputPath + 'dome.json'
    sNumberKeypoints=19
# Body + Hands
else:
    sJsonPath = sDatasetOutputPath + 'dome_bodyHands.json'
    sNumberKeypoints=19+2*20

SMC_BodyJoint_neck       = 0
SMC_BodyJoint_nose       = 1
SMC_BodyJoint_bodyCenter = 2
SMC_BodyJoint_lShoulder  = 3
SMC_BodyJoint_lElbow     = 4
SMC_BodyJoint_lWrist     = 5
SMC_BodyJoint_lHip       = 6
SMC_BodyJoint_lKnee      = 7
SMC_BodyJoint_lAnkle     = 8
SMC_BodyJoint_rShoulder  = 9
SMC_BodyJoint_rElbow     = 10
SMC_BodyJoint_rWrist     = 11
SMC_BodyJoint_rHip       = 12
SMC_BodyJoint_rKnee      = 13
SMC_BodyJoint_rAnkle     = 14
SMC_BodyJoint_lEye       = 15
SMC_BodyJoint_lEar       = 16
SMC_BodyJoint_rEye       = 17
SMC_BodyJoint_rEar       = 18

def getTime(startTime):
    return 'time (h:mm:ss.ms): {}'.format(datetime.now()-startTime)

def readpoint(domeKeypoints2D, scores, idx, isInsideImage, isVisible):
    x = domeKeypoints2D[0, idx]
    y = domeKeypoints2D[1, idx]
    # Keypoints
    # Value outside image or not found
    if isInsideImage[idx] != 1 or scores[idx] <= 0 or (isVisible and isVisible[idx] == 2):
        return [0.0, 0.0, 2.0]
    # Value occluded but found
    elif isVisible and (isVisible[idx] != 1 and isVisible[idx] != -1) <= 0:
        return [x, y, 0.0]
    # Value visible + inside image
    else:
        return [x, y, 1.0]

def domeToOP(domeKeypoints2D, scores, isInsideImage, isVisible):
    domeKeypoints2D = np.array(domeKeypoints2D).transpose()
    keypoints2D=[]
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_nose,       isInsideImage, isVisible)) #OPENPOSE_Nose      = 0
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_neck,       isInsideImage, isVisible)) #OPENPOSE_Neck      = 1
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rShoulder,  isInsideImage, isVisible)) #OPENPOSE_RShoulder = 2
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rElbow,     isInsideImage, isVisible)) #OPENPOSE_RElbow    = 3
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rWrist,     isInsideImage, isVisible)) #OPENPOSE_RWrist    = 4
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lShoulder,  isInsideImage, isVisible)) #OPENPOSE_LShoulder = 5
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lElbow,     isInsideImage, isVisible)) #OPENPOSE_LElbow    = 6
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lWrist,     isInsideImage, isVisible)) #OPENPOSE_LWrist    = 7
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_bodyCenter, isInsideImage, isVisible)) #OPENPOSE_LowerAbs  = 8
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rHip,       isInsideImage, isVisible)) #OPENPOSE_RHip      = 9
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rKnee,      isInsideImage, isVisible)) #OPENPOSE_RKnee     = 10
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rAnkle,     isInsideImage, isVisible)) #OPENPOSE_RAnkle    = 11
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lHip,       isInsideImage, isVisible)) #OPENPOSE_LHip      = 12
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lKnee,      isInsideImage, isVisible)) #OPENPOSE_LKnee     = 13
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lAnkle,     isInsideImage, isVisible)) #OPENPOSE_LAnkle    = 14
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rEye,       isInsideImage, isVisible)) #OPENPOSE_REye      = 15
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lEye,       isInsideImage, isVisible)) #OPENPOSE_LEye      = 16
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_rEar,       isInsideImage, isVisible)) #OPENPOSE_REar      = 17
    keypoints2D.append(readpoint(domeKeypoints2D, scores, SMC_BodyJoint_lEar,       isInsideImage, isVisible)) #OPENPOSE_LEar      = 18
                                                                                                               #OPENPOSE_Bkg       = 19
    return keypoints2D

def domeHandToOP(keypoints2D, domeHand2D, scores, isInsideImage, isVisible, isRightHand):
    domeHand2D = np.array(domeHand2D).transpose()
    for index in range(1, 20+1): # hand[0] is wrist --> already in body
        keypoints2D.append(readpoint(domeHand2D, scores, index, isInsideImage, isVisible))
    # Wrist - Repeated in both body and hand keypoints
    if not isRightHand:
        wristIndex = 7 # OPENPOSE_LWrist
    else:
        wristIndex = 4 # OPENPOSE_RWrist
    domeWrist = [domeHand2D[0][0], domeHand2D[1][0], 2.0]
    if scores[0] > 0 and isInsideImage[0] and isVisible[0]:
        domeWrist[2] = 0.0
    # TEMPORARY LINE
    old = keypoints2D[wristIndex]
    # If body wrist not visible
    if keypoints2D[wristIndex][2] > 1:
        # If hand wrist visible
        if domeWrist[2] < 2:
            keypoints2D[wristIndex] = domeHand2D[0]
    # If both visible
    # # Option a) Average
    # elif domeWrist[2] < 2:
    #     keypoints2D[wristIndex] = (domeHand2D[0] + keypoints2D[wristIndex]) / 2.0
    # Option b) Keep body (more robust)
    # If hand wrist not visible --> using body one (this includes if both not found)
    # if old != keypoints2D[wristIndex]:
    #     print ' '
    #     print domeWrist
    #     print old
    #     print keypoints2D[wristIndex]
    return keypoints2D

def getAnnotations2D(annot2DPath):
    with open(annot2DPath) as jsonFile:
        peopleData = json.load(jsonFile)
    bodies = {}
    for personData in peopleData:
        # Skip if no ID found (it happens in some faces and hands)
        if personData['id'] == -1:
            continue
        # Body keypoints
        body2D = personData['body']
        # Percentage Visible and inside image
        visibility = [-occluded+1 for occluded in body2D['occluded']]
        visibleAndInsideImg = [x * y for x, y in zip(visibility, body2D['insideImg'])]
        percentageVisibleAndInsideImg = sum(visibleAndInsideImg) / float(len(visibleAndInsideImg))
        if percentageVisibleAndInsideImg > 1e-6:
            bodies[personData['id']] = {}
            bodies[personData['id']]['percentageVisibleAndInsideImg'] = percentageVisibleAndInsideImg
            # Body and BBox
            bodies[personData['id']]['body'] = domeToOP(body2D['landmarks'], body2D['scores'], body2D['insideImg'], visibility)
            bodies[personData['id']]['bbox'] = body2D['bbox']

            # Hands
            if len(bodies) > 0 and not sBodyOnly:
                # hand2DData = personData['right_hand']
                hands = getHands(personData)
                if len(hands) > 0:
                    # Add hand keypoints to body
                    # Note: Currently, wrist keypoint in hand is discarded (as it is already in body).
                    # Making a smart average between body and hand wrist keypoints might be more robust.
                    for index in range(0, 2):
                        try:
                            bodies[personData['id']]['body'] = domeHandToOP(
                                bodies[personData['id']]['body'], hands[index]['landmarks'], hands[index]['scores'],
                                hands[index]['insideImg'], hands[index]['visibility'], index
                            )
                        except Exception as err:
                            print '1\n '
                            print index
                            print ' '
                            print bodies
                            print ' '
                            print bodies[personData['id']]
                            print ' '
                            print bodies[personData['id']]['body']
                            print '2\n '
                            print hands
                            print ' '
                            print hands[index]
                            print ' '
                            print hands[index]['landmarks']
                            print ' '
                            print hands[index]['scores']
                            print ' '
                            print hands[index]['insideImg']
                            print ' '
                            print hands[index]['visibility']
                            asdf
                else:
                    bodies = []
                    return bodies
    # # Security checks
    # if len(bodies) == 0:
    #     print('No bodies found in ' + annot2DPath)
    #     # raise Exception('No bodies found in ' + annot2DPath)
    # Remove whole image if there is people highly (but not fully) occluded people
    # This is due the fact that occlussion is not a perfect metric and it might fail
    for bodyId in bodies:
        if bodies[bodyId]['percentageVisibleAndInsideImg'] < 0.2:
            bodies = [];
            break
    # Return resulting bodies
    return bodies

def getHands(personData):
    hands = []
    # If overlapping or non-valid hands --> skip frame
    leftHand = personData['left_hand']
    rightHand = personData['right_hand']
    if leftHand['overlap'] or rightHand['overlap'] or not leftHand['valid'] or not rightHand['valid']:
        hands = [{}, {}]
        personData = [];
        for index in range(0, 2):
            if index == 0:
                hand2D = leftHand
            else:
                hand2D = rightHand
            # Percentage Visible and inside image
            visibility = [-occluded+1 for occluded in hand2D['occluded']]
            visibleAndInsideImg = [x * y * (-z+1) for x, y, z in zip(visibility, hand2D['insideImg'], hand2D['self_occluded'])]
            percentageVisibleAndInsideImg = sum(visibleAndInsideImg) / float(len(visibleAndInsideImg))
            hands[index]['percentageVisibleAndInsideImg'] = percentageVisibleAndInsideImg
            # Hand and BBox
            hands[index]['landmarks'] = hand2D['landmarks']
            hands[index]['scores'] = hand2D['scores']
            hands[index]['insideImg'] = hand2D['insideImg']
            hands[index]['visibility'] = visibleAndInsideImg
            # hands[index][hand2D['id']]['bbox'] = hand2D['bbox']

        # Remove whole image if there is people highly (but not fully) occluded people
        # This is due the fact that occlussion is not a perfect metric and it might fail
        minVisibilityRatio = 0.3
        if hands[0]['percentageVisibleAndInsideImg'] <= minVisibilityRatio and hands[1]['percentageVisibleAndInsideImg'] <= minVisibilityRatio:
            hands = []
        # Ocluded keypoint visibility from 0 to 2 (i.e. not labeled) if very few keypoints of that hand are visible
        else:
            for index in range(0, 2):
                if hands[index]['percentageVisibleAndInsideImg'] < minVisibilityRatio:
                    for subIndex in range(0, len(hands[index]['visibility'])):
                        if hands[index]['visibility'][subIndex] == 0:
                            hands[index]['visibility'][subIndex] = 2
    # Return resulting hands
    return hands

def getCurrentData(bodies, bodyId, imagePath, image, outputJsonCount):
    body = bodies[bodyId]['body']
    bbox = bodies[bodyId]['bbox']
    currentData = {}
    currentData['dataset'] = 'domedb'
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
    for otherBodyId in bodies:
        if otherBodyId != bodyId:
            otherBody = bodies[otherBodyId]['body']
            otherBbox = bodies[otherBodyId]['bbox']
            currentData['joint_others'].append(otherBody)
            currentData['scale_provided_other'].append(1.0)
            currentData['objpos_other'].append(
                [otherBbox[0]+otherBbox[2]/2, otherBbox[1]+otherBbox[3]/2]
            )
    # currentData['bbox_other'] = []
    # currentData['segment_area_other'] = []
    currentData['num_keypoints_other'] = sNumberKeypoints
    currentData['people_index'] = bodyId
    currentData['numOtherPeople']= len(currentData['objpos_other'])
    # Shared with Depth data
    currentData['depth_enabled'] = 0
    return currentData

def generateJsonFile():
    startTime = datetime.now()
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
    counter = 0
    for inputJsonIndex, inputJsonElement in enumerate(inputJsonStruct):
        # Progress bar
        if inputJsonIndex % printEveryXIterations == 0:
            print ('Sample %d of %d, ' + getTime(startTime)) % (inputJsonIndex+1, totalWriteCount)
        # Data
        # print inputJsonElement
        try:
            annot2DPath = sDatasetInputPath + str(inputJsonElement['annot_2d'])
            imagePath = str(inputJsonElement['img'])
            fullImagePath = sDatasetInputPath + imagePath
            subjectsWithValidBody = inputJsonElement['subjectsWithValidBody']
            if not sBodyOnly:
                # subjectsWithValidFace = inputJsonElement['subjectsWithValidFace']
                subjectsWithValidLHand = inputJsonElement['subjectsWithValidLHand']
                subjectsWithValidRHand = inputJsonElement['subjectsWithValidRHand']
        # subjectsWithValidFace missing if no face detected, analogous for L/R hand
        except Exception as err:
            continue
        # # Debugging
        # print ' '
        # print annot2DPath
        # print imagePath
        # print fullImagePath
        # print subjectsWithValidBody
        # print subjectsWithValidFace
        # print subjectsWithValidLHand
        # print subjectsWithValidRHand
        # # Counting how many valid samples
        # if len(subjectsWithValidBody) > 0 and subjectsWithValidBody == subjectsWithValidLHand and subjectsWithValidBody == subjectsWithValidRHand: # Total: 456989
        #     counter = counter + 1
        # continue
        # Preparing data
        if sBodyOnly or (len(subjectsWithValidBody) > 0 and subjectsWithValidBody == subjectsWithValidLHand and subjectsWithValidBody == subjectsWithValidRHand): # counter = 11038
        # if len(subjectsWithValidBody) > 0 and (subjectsWithValidBody == subjectsWithValidLHand or subjectsWithValidBody == subjectsWithValidRHand): # counter = ?
            # Body 2D
            bodies = getAnnotations2D(annot2DPath)
            # If at least an available body
            if len(bodies) > 0:
                # Image
                image = cv2.imread(fullImagePath)
                # Generate output JSON
                for bodyId in bodies:
                    # If some threshold of keypoints are visible and inside the image:
                    if bodies[bodyId]['percentageVisibleAndInsideImg'] > 0.4:
                        counter = counter + 1
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
    print 'Number of images in dataset: %d' % (counter)
    # Write JSON file
    with open(sJsonPath, 'w+') as jsonFile:
        jsonFile.write(json.dumps({"root":outputJsonData}))
    print('Final ' + getTime(startTime))

# Main function
if __name__ == "__main__":
    generateJsonFile()
