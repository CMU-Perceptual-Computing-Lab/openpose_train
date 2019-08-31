# To be installed first
# pip install lmdb

import cv2
import json
import lmdb
import numpy as np
import os.path
import scipy.io as sio
import struct
import sys

def generateLmdbFile(lmdbPath, imagesFolder, jsonFile, caffePythonPath, maskFolder = None):
    print('Creating ' + lmdbPath + ' from ' + jsonFile)
    sys.path.insert(0, caffePythonPath)
    import caffe

    env = lmdb.open(lmdbPath, map_size=int(1e12))
    txn = env.begin(write=True)

    try:
        jsonData = json.load(open(jsonFile))['root']
    except:
        jsonData = json.load(open(jsonFile)) # Raaj's MPII did not add root
    totalWriteCount = len(jsonData)
    print('Number training images: %d' % totalWriteCount)
    writeCount = 0
    randomOrder = np.random.permutation(totalWriteCount).tolist()
    if "face70_mask_out" in jsonData[0]['dataset']:
        minimumWidth = 300
    else:
        minimumWidth = 128
    printEveryXIterations = max(1, round(totalWriteCount / 100))

    for numberSample in range(totalWriteCount):
        if numberSample % printEveryXIterations == 0:
            print('Sample %d of %d' % (numberSample+1, totalWriteCount))
        index = randomOrder[numberSample]
        isBodyMpii = ("MPII" in jsonData[index]['dataset'] and len(jsonData[index]['dataset']) == 4)
        maskMiss = None
        # Read image and maskMiss (if COCO)
        if "COCO" in jsonData[index]['dataset'] \
            or "MPII_hand" in jsonData[index]['dataset'] \
            or "mpii-hand" in jsonData[index]['dataset'] \
            or isBodyMpii \
            or "panoptics" in jsonData[index]['dataset'] \
            or "car14" in jsonData[index]['dataset'] \
            or "car22" in jsonData[index]['dataset']:
            if "COCO" in jsonData[index]['dataset'] or isBodyMpii or "car22" in jsonData[index]['dataset']:
                if not maskFolder:
                    maskFolder = imagesFolder
                # Car22
                if isBodyMpii or "car22" in jsonData[index]['dataset']:
                    if isBodyMpii:
                        imageFullPath = os.path.join(imagesFolder, jsonData[index]['img_paths']);
                    else:
                        imageFullPath = os.path.join(imagesFolder, jsonData[index]['img_paths'][1:])
                    maskFileName = os.path.splitext(os.path.split(jsonData[index]['img_paths'])[1])[0];
                    maskMissFullPath = maskFolder + maskFileName + '.png'
                else:
                    imageIndex = jsonData[index]['img_paths'][-16:-4];
                    # COCO 2014 (e.g. foot)
                    if "2014/COCO_" in jsonData[index]['img_paths']:
                        if "train2014" in jsonData[index]['img_paths']:
                            kindOfData = 'train2014';
                        else:
                            kindOfData = 'val2014';
                        imageFullPath = os.path.join(imagesFolder, 'train2017', imageIndex + '.jpg');
                        kindOfMask = 'mask2014'
                        maskMissFullPath = maskFolder + 'mask2014/' + kindOfData + '_mask_miss_' + imageIndex + '.png'
                    # COCO 2017
                    else:
                        kindOfData = 'train2017';
                        imageFullPath = os.path.join(imagesFolder, kindOfData + '/' + jsonData[index]['img_paths']);
                        kindOfMask = 'mask2017'
                        maskMissFullPath = maskFolder + kindOfMask + '/' + kindOfData + '/' + imageIndex + '.png'
                # Read image and maskMiss
                if not os.path.exists(imageFullPath):
                    raise Exception('Not found image: ' + imageFullPath)
                image = cv2.imread(imageFullPath)
                if not os.path.exists(maskMissFullPath):
                    raise Exception('Not found image: ' + maskMissFullPath)
                maskMiss = cv2.imread(maskMissFullPath, 0) # 0 = Load grayscale image
            # MPII or car14
            else:
                imageFullPath = os.path.join(imagesFolder, jsonData[index]['img_paths']);
                image = cv2.imread(imageFullPath)
                # # Debug - Display image
                # print(imageFullPath)
                # cv2.imshow("image", image)
                # cv2.waitKey(0)
        elif "face70" in jsonData[index]['dataset'] \
            or "hand21" in jsonData[index]['dataset'] \
            or "hand42" in jsonData[index]['dataset']:
            imageFullPath = os.path.join(imagesFolder, jsonData[index]['image_path'])
            image = cv2.imread(imageFullPath)
            if "face70_mask_out" in jsonData[0]['dataset']:
                kindOfMask = 'mask2017'
                maskMissFullPath = maskFolder + jsonData[index]['image_path'][:-4] + '.png'
                if not os.path.exists(maskMissFullPath):
                    raise Exception('Not found image: ' + maskMissFullPath)
                maskMiss = cv2.imread(maskMissFullPath, 0) # 0 = Load grayscale image
            elif "face70" not in jsonData[index]['dataset']:
                kindOfMask = 'mask2017'
                maskMissFullPath = maskFolder + kindOfMask + '/' + jsonData[index]['dataset'][:6] + '/' + jsonData[index]['image_path'][:-4] + '.png'
                if not os.path.exists(maskMissFullPath):
                    raise Exception('Not found image: ' + maskMissFullPath)
                maskMiss = cv2.imread(maskMissFullPath, 0) # 0 = Load grayscale image
        elif "dome" in jsonData[index]['dataset']:
            # No maskMiss for "dome" dataset
            pass
        else:
            raise Exception('Unknown dataset called ' + jsonData[index]['dataset'] + '.')

        # COCO / MPII
        if "COCO" in jsonData[index]['dataset'] \
            or isBodyMpii \
            or "face70" in jsonData[index]['dataset'] \
            or "hand21" in jsonData[index]['dataset'] \
            or "hand42" in jsonData[index]['dataset'] \
            or "MPII_hand" in jsonData[index]['dataset'] \
            or "mpii-hand" in jsonData[index]['dataset'] \
            or "panoptics" in jsonData[index]['dataset'] \
            or "car14" in jsonData[index]['dataset'] \
            or "car22" in jsonData[index]['dataset']:
            try:
                height = image.shape[0]
                width = image.shape[1]
                # print("Image size: "+ str(width) + "x" + str(height))
            except:
                print('Image not found at ' + imageFullPath)
                height = image.shape[0]
            if width < minimumWidth:
                image = cv2.copyMakeBorder(image,0,0,0,minimumWidth-width,cv2.BORDER_CONSTANT,value=(128,128,128))
                if maskMiss is not None:
                    maskMiss = cv2.copyMakeBorder(maskMiss,0,0,0,minimumWidth-width,cv2.BORDER_CONSTANT,value=(0,0,0))
                width = minimumWidth
                # Note: width parameter not modified, we want to keep information
            metaData = np.zeros(shape=(height,width,1), dtype=np.uint8)
        # Dome
        elif "dome" in jsonData[index]['dataset']:
            # metaData = np.zeros(shape=(100,200), dtype=np.uint8) # < 50 keypoints
            # metaData = np.zeros(shape=(100,59*4), dtype=np.uint8) # 59 keypoints (body + hand)
            metaData = np.zeros(shape=(100,135*4), dtype=np.uint8) # 135 keypoints
        else:
            raise Exception('Unknown dataset!')
        # dataset name (string)
        currentLineIndex = 0
        for i in range(len(jsonData[index]['dataset'])):
            metaData[currentLineIndex][i] = ord(jsonData[index]['dataset'][i])
        currentLineIndex = currentLineIndex + 1
        # image height, image width
        heightBinary = float2bytes(float(jsonData[index]['img_height']))
        for i in range(len(heightBinary)):
            metaData[currentLineIndex][i] = ord(heightBinary[i])
        widthBinary = float2bytes(float(jsonData[index]['img_width']))
        for i in range(len(widthBinary)):
            metaData[currentLineIndex][4 + i] = ord(widthBinary[i])
        currentLineIndex = currentLineIndex + 1
        # (a) numOtherPeople (uint8), people_index (uint8), annolist_index (float), writeCount(float), totalWriteCount(float)
        metaData[currentLineIndex][0] = jsonData[index]['numOtherPeople']
        metaData[currentLineIndex][1] = jsonData[index]['people_index']
        annolistIndexBinary = float2bytes(float(jsonData[index]['annolist_index']))
        for i in range(len(annolistIndexBinary)): # 2,3,4,5
            metaData[currentLineIndex][2 + i] = ord(annolistIndexBinary[i])
        countBinary = float2bytes(float(writeCount)) # note it's writecount instead of numberSample!
        for i in range(len(countBinary)):
            metaData[currentLineIndex][6 + i] = ord(countBinary[i])
        totalWriteCountBinary = float2bytes(float(totalWriteCount))
        for i in range(len(totalWriteCountBinary)):
            metaData[currentLineIndex][10 + i] = ord(totalWriteCountBinary[i])
        numberOtherPeople = int(jsonData[index]['numOtherPeople'])
        currentLineIndex = currentLineIndex + 1
        # (b) objpos_x (float), objpos_y (float)
        objposBinary = float2bytes(jsonData[index]['objpos'])
        for i in range(len(objposBinary)):
            metaData[currentLineIndex][i] = ord(objposBinary[i])
        currentLineIndex = currentLineIndex + 1
        # try:
        # (c) scale_provided (float)
        scaleProvidedBinary = float2bytes(float(jsonData[index]['scale_provided']))
        for i in range(len(scaleProvidedBinary)):
            metaData[currentLineIndex][i] = ord(scaleProvidedBinary[i])
        currentLineIndex = currentLineIndex + 1
        # (d) joint_self (3*#keypoints) (float) (3 line)
        joints = np.asarray(jsonData[index]['joint_self']).T.tolist() # transpose to 3*#keypoints
        for i in range(len(joints)):
            rowBinary = float2bytes(joints[i])
            for j in range(len(rowBinary)):
                metaData[currentLineIndex][j] = ord(rowBinary[j])
            currentLineIndex = currentLineIndex + 1
        # (e) check numberOtherPeople, prepare arrays
        if numberOtherPeople!=0:
            # If generated with Matlab JSON format
            if "COCO" in jsonData[index]['dataset'] \
                or "car22" in jsonData[index]['dataset']:
                if numberOtherPeople==1:
                    jointOthers = [jsonData[index]['joint_others']]
                    objposOther = [jsonData[index]['objpos_other']]
                    scaleProvidedOther = [jsonData[index]['scale_provided_other']]
                else:
                    jointOthers = jsonData[index]['joint_others']
                    objposOther = jsonData[index]['objpos_other']
                    scaleProvidedOther = jsonData[index]['scale_provided_other']
            elif "dome" in jsonData[index]['dataset'] \
                or isBodyMpii \
                or "face70" in jsonData[index]['dataset'] \
                or "hand21" in jsonData[index]['dataset'] \
                or "hand42" in jsonData[index]['dataset'] \
                or "MPII_hand" in jsonData[index]['dataset'] \
                or "car14" in jsonData[index]['dataset']:
                jointOthers = jsonData[index]['joint_others']
                objposOther = jsonData[index]['objpos_other']
                scaleProvidedOther = jsonData[index]['scale_provided_other']
            else:
                raise Exception('Unknown dataset!')
            # (f) objpos_other_x (float), objpos_other_y (float) (numberOtherPeople lines)
            for i in range(numberOtherPeople):
                objposBinary = float2bytes(objposOther[i])
                for j in range(len(objposBinary)):
                    metaData[currentLineIndex][j] = ord(objposBinary[j])
                currentLineIndex = currentLineIndex + 1
            # (g) scaleProvidedOther (numberOtherPeople floats in 1 line)
            scaleProvidedOtherBinary = float2bytes(scaleProvidedOther)
            for j in range(len(scaleProvidedOtherBinary)):
                metaData[currentLineIndex][j] = ord(scaleProvidedOtherBinary[j])
            currentLineIndex = currentLineIndex + 1
            # (h) joint_others (3*#keypoints) (float) (numberOtherPeople*3 lines)
            for n in range(numberOtherPeople):
                joints = np.asarray(jointOthers[n]).T.tolist() # transpose to 3*#keypoints
                for i in range(len(joints)):
                    rowBinary = float2bytes(joints[i])
                    for j in range(len(rowBinary)):
                        metaData[currentLineIndex][j] = ord(rowBinary[j])
                    currentLineIndex = currentLineIndex + 1
        # (i) img_paths
        if "dome" in jsonData[index]['dataset'] and "hand21" not in jsonData[index]['dataset'] \
            and "hand42" not in jsonData[index]['dataset']:
            # for i in range(len(jsonData[index]['img_paths'])):
            #     metaData[currentLineIndex][i] = ord(jsonData[index]['img_paths'][i])
            for i in range(len(jsonData[index]['image_path'])):
                metaData[currentLineIndex][i] = ord(jsonData[index]['image_path'][i])
            currentLineIndex = currentLineIndex + 1

        # # (j) depth enabled(uint8)
        # if "dome" in jsonData[index]['dataset'] and "hand21" not in jsonData[index]['dataset'] \
        #     and "hand42" not in jsonData[index]['dataset']:
        #     metaData[currentLineIndex][0] = jsonData[index]['depth_enabled']
        #     currentLineIndex = currentLineIndex + 1

        # # (k) depth_path
        # if "dome" in jsonData[index]['dataset'] and "hand21" not in jsonData[index]['dataset'] \
        #     and "hand42" not in jsonData[index]['dataset']:
        #     if jsonData[index]['depth_enabled']>0:
        #         for i in range(len(jsonData[index]['depth_path'])):
        #             metaData[currentLineIndex][i] = ord(jsonData[index]['depth_path'][i])
        #         currentLineIndex = currentLineIndex + 1

        # COCO: total 7 + 4*numberOtherPeople lines
        # DomeDB: X lines
        # If generated with Matlab JSON format
        if "COCO" in jsonData[index]['dataset'] \
            or "hand21" in jsonData[index]['dataset'] \
            or "hand42" in jsonData[index]['dataset'] \
            or isBodyMpii \
            or "car22" in jsonData[index]['dataset'] \
            or "face70_mask_out" in jsonData[index]['dataset']:
            dataToSave = np.concatenate((image, metaData, maskMiss[...,None]), axis=2)
            dataToSave = np.transpose(dataToSave, (2, 0, 1))
        elif "face70" in jsonData[index]['dataset'] \
            or "MPII_hand" in jsonData[index]['dataset'] \
            or "mpii-hand" in jsonData[index]['dataset'] \
            or "panoptics" in jsonData[index]['dataset'] \
            or "car14" in jsonData[index]['dataset']:
            dataToSave = np.concatenate((image, metaData), axis=2)
            dataToSave = np.transpose(dataToSave, (2, 0, 1))
        elif "dome" in jsonData[index]['dataset']:
            dataToSave = np.transpose(metaData[:,:,None], (2, 0, 1))
        else:
            raise Exception('Unknown dataset!')

        datum = caffe.io.array_to_datum(dataToSave, label=0)
        key = '%07d' % writeCount
        txn.put(key, datum.SerializeToString())
        # Higher number --> Ideally faster, but much more RAM used. 2500 for carfusion was taking about 25GB of RAM.
        # Lower number --> Ideally slower, but much less RAM used
        if writeCount % 500 == 0:
            txn.commit()
            txn = env.begin(write=True)
        # print('%d/%d/%d/%d' % (numberSample, writeCount, index, totalWriteCount))
        writeCount = writeCount + 1
        # except Exception as err:
        #     print("Exception (sample skipped): ", err)
        #     if "dome" not in jsonData[index]['dataset']:
        #         raise Exception(err)
    txn.commit()
    env.close()

def generateNegativesLmdbFile(lmdbPath, imagesFolder, jsonFile, caffePythonPath):
    sys.path.insert(0, caffePythonPath)
    import caffe

    env = lmdb.open(lmdbPath, map_size=int(1e12))
    txn = env.begin(write=True)

    jsonData = json.load(open(jsonFile))
    totalWriteCount = len(jsonData)
    print('%d samples' % (totalWriteCount))
    writeCount = 0
    randomOrder = np.random.permutation(totalWriteCount).tolist()
    printEveryXIterations = max(1, round(totalWriteCount / 100))

    for numberSample in range(totalWriteCount):
        index = randomOrder[numberSample]
        if numberSample % printEveryXIterations == 0:
            print('Sample %d of %d' % (numberSample+1, totalWriteCount))
        # Read image
        imageFilePath = os.path.join(imagesFolder, jsonData[randomOrder[numberSample]])
        image = cv2.imread(imageFilePath)
        if image.shape[0] + image.shape[1] < 1:
            errorMessage = 'Image not found! ' + imageFilePath
            raise Exception(errorMessage)
        # Save image
        dataToSave = np.transpose(image, (2, 0, 1))
        datum = caffe.io.array_to_datum(dataToSave, label=0)
        key = '%07d' % writeCount
        txn.put(key, datum.SerializeToString())
        if writeCount % 2500 == 0:
            txn.commit()
            txn = env.begin(write=True)
        writeCount = writeCount + 1
    txn.commit()
    env.close()

def float2bytes(floats):
    if type(floats) is float:
        floats = [floats]
    else:
        for i in range(len(floats)):
            floats[i] = float(floats[i])
    # Make sure they are all floats
    return struct.pack('%sf' % len(floats), *floats)
