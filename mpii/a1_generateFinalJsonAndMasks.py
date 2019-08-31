sMode = 1 # 1 for Mask generation, 2 for JSON generation
generateLightVersionForDebugging = False
# generateLightVersionForDebugging = True

import cv2
import numpy as np
import os
import json
from util import *
import math

###################################################
# 1. Find which images don't have people
###################################################

# Paths
sMpiiFolder = '../dataset/MPII/'
sOriginalJson = sMpiiFolder + 'mpii_human_pose_v1_u12_2/mpii_human_pose_v1_u12_1.json'
sImageFolder = sMpiiFolder + 'images/'
sJsonFolder = sMpiiFolder + 'json/'
sFinalJsonPath = sJsonFolder + 'root_mpii.json'
sMaskFolder = sMpiiFolder + 'mask/'
sImageScale = 368.
# Create directories
if not os.path.exists(sJsonFolder):
    os.mkdir(sJsonFolder)
if not os.path.exists(sMaskFolder):
    os.mkdir(sMaskFolder)

def show_image(img, waitKeyValue=1, window_name='OpenPose'):
    if img is not None:
        cv2.imshow(window_name,img)
        key = cv2.waitKey(waitKeyValue)
        if key == 32:
            while 1:
                key = cv2.waitKey(15)
                if key == 32:
                    break

###################################################
# 2. Convert it into a Image -> People form + Viz
###################################################

def mpiiann_to_np(mpiiann):
    nparr = np.zeros(shape=(16,3))
    for i in range(0,16):
        nparr[i,0] = mpiiann[i*3 + 0]
        nparr[i,1] = mpiiann[i*3 + 1]
        nparr[i,2] = (mpiiann[i*3 + 2] + 2) % 3
    return nparr

# Debugging
def getAnnotations():
    # enableDebugging = True
    enableDebugging = False
    mpii_anno = load_json(sOriginalJson)
    annotations = []

    # Iterate each image
    numberAnnotations = len(mpii_anno["annolist"])
    printEveryXFrames = max(1,numberAnnotations/20)
    for i in range(0, numberAnnotations):
        if i%printEveryXFrames == 0:
            print(str(int(float(i)/float(len(mpii_anno["annolist"]))*100)) + "%")
        elif generateLightVersionForDebugging:
            continue
        image_json = mpii_anno["annolist"][i]
        img_name = image_json["image"]["name"] # 019598286.jpg
        if mpii_anno["img_train"][i]: # if is annotated
            # Convert
            annorects = image_json["annorect"]
            if type(annorects) is dict:
                annorects = []
                annorects.append(image_json["annorect"])

            # Image
            img = cv2.imread(sImageFolder + img_name)
            try:
                img_width = int(img.shape[1])
                img_height = int(img.shape[0])
            except:
                print("Image not found: " + sImageFolder + img_name)
                continue
                # img_width = int(img.shape[1])
                # img_height = int(img.shape[0])

            # Anno object
            anno = dict()
            anno["image_path"] = img_name
            anno["mask_path"] = img_name[:-3] + 'png'
            anno["image_id"] = i
            anno["annorect"] = []

            # Iterate each person
            all_points_arr = []
            person_count = 0
            for p in range(0, len(annorects)):
                if "annopoints" not in annorects[p]:
                    continue
                person_json = annorects[p]

                # Caffe needs bbox has x,y,width,height
                head_bbox = (person_json["x1"],person_json["y1"],person_json["x2"],person_json["y2"])

                # Issues
                if len(person_json["annopoints"]) == 0:
                    continue
                annopoints = person_json["annopoints"]["point"]
                if type(annopoints) is dict:
                    continue

                # Iterate points
                all_points = dict()
                caffe_points = np.zeros((16*3))
                for person_point in annopoints:
                    point = (int(person_point["x"]), int(person_point["y"]))
                    id = person_point["id"]
                    is_visible = person_point["is_visible"]
                    if type(is_visible) is list: is_visible = False
                    if is_visible: is_visible = 2
                    else: is_visible = 1
                    all_points[id] = (point[0], point[1], is_visible)
                    caffe_points[id*3 + 0] = person_point["x"]
                    caffe_points[id*3 + 1] = person_point["y"]
                    caffe_points[id*3 + 2] = int(is_visible)

                all_points_arr.append(all_points)
                rect = get_rect_from_points(all_points, head_bbox)

                # TODO: Update/Remove after right bounding box and right segmentation
                if sMode == 2: # Gines: Removed for Masking: This was making the bounding box bigger (more true/false negatives...)
                    # Increase fake rect a bit
                    rect_scale = 0.05
                    rect[0] = rect[0] - (math.fabs(rect[0] - rect[2])*rect_scale*2) # X
                    rect[2] = rect[2] + (math.fabs(rect[0] - rect[2])*rect_scale*2) # X
                    rect[1] = rect[1] - (math.fabs(rect[1] - rect[3])*rect_scale*1) # Y
                    rect[3] = rect[3] + (math.fabs(rect[1] - rect[3])*rect_scale*2) # Y
                    rect[0] = max(rect[0], 0)
                    rect[2] = min(rect[2], img_width)
                    rect[1] = max(rect[1], 0)
                    rect[3] = min(rect[3], img_height)

                # Store Data
                data = dict()
                data["bbox"] = [rect[0], rect[1], rect[2]-rect[0], rect[3]-rect[1]]
                data["segmentation"] = [] # DONT HAVE
                data["area"] = data["bbox"][2]*data["bbox"][3]
                data["id"] = person_count
                data["iscrowd"] = -1 # DONT HAVE
                data["keypoints"] = caffe_points.tolist()
                data["num_keypoints"] = len(all_points.keys())
                data["img_width"] = img_width
                data["img_height"] = img_height
                data["scale"] = person_json["scale"]
                anno["annorect"].append(data)

                # Increase Person
                person_count = person_count+1

                # Debugging
                if enableDebugging:
                    # Convert
                    pt_kp = np.zeros(shape=(person_count, 16, 3))
                    for i in range(pt_kp.shape[0]):
                        for j in range(pt_kp.shape[1]):
                            if j in all_points_arr[i]:
                                pt_kp[i,j,0] = all_points_arr[i][j][0]
                                pt_kp[i,j,1] = all_points_arr[i][j][1]
                                pt_kp[i,j,2] = all_points_arr[i][j][2]

                        person_kp = pt_kp[i,:,:]
                        draw_lines_mpii(img, person_kp, colors[i])
                    cv2.rectangle(img, (int(head_bbox[0]), int(head_bbox[1])), (int(head_bbox[2]), int(head_bbox[3])), 255, 2)
                    cv2.putText(img,"P"+str(person_count), (int(rect[0]), int(rect[1])), cv2.FONT_HERSHEY_SIMPLEX, 1, (0,255,255), 2)
                    cv2.rectangle(img, (int(rect[0]), int(rect[1])), (int(rect[2]), int(rect[3])), colors[person_count], 2)


            # Add this annotation
            if person_count > 0:
                annotations.append(anno)
            # Debugging
            if enableDebugging:
                show_image(img, 0)

    return annotations

def generateMasks(train_annotations):
    numberAnnotations = len(train_annotations)

    # Iterate through each image
    printEveryXFrames = max(1,numberAnnotations/25)
    for i in range(0, numberAnnotations):
        if i%printEveryXFrames == 0:
            print(str(int(float(i)/float(numberAnnotations)*100)) + "%")

        w = train_annotations[i]["annorect"][0]["img_width"]
        h = train_annotations[i]["annorect"][0]["img_height"]
        numerPeople = len(train_annotations[i]["annorect"]);

        # Iterate through each image anno
        mask_img = np.zeros(shape=(h,w))
        # TODO: This is a really bad masking. Run something better!
        for p in range(0, numerPeople):
            bbox = train_annotations[i]["annorect"][p]["bbox"]
            p1x = bbox[0]
            p1y = bbox[1]
            width = bbox[2]
            height = bbox[3]
            p2x = p1x+width
            p2y = p1y+height
            # Original
            # cv2.rectangle(mask_img, (int(p1x),int(p1y)),(int(p2x),int(p2y)), 255, -1)
            # Gines' version: Reducing width to avoid introducing bkg people (less true & false negatives)
            # TODO: Update/Remove after right bounding box and right segmentation
            widthThin = min(width, 0.3*height)
            xHalf = p1x+0.5*width
            p1xThin = xHalf-0.5*widthThin
            p2xThin = xHalf+0.5*widthThin
            cv2.rectangle(mask_img, (int(p1xThin),int(p1y)),(int(p2xThin),int(p2y)), 255, -1)

        # Save bg
        cv2.imwrite(sMaskFolder + train_annotations[i]["mask_path"],  mask_img)

        # # Debugging
        # img = cv2.imread(sImageFolder+train_annotations[i]["image_path"])
        # mask = cv2.imread(sMaskFolder + train_annotations[i]["mask_path"],0)
        # res = cv2.bitwise_and(img,img, mask = mask)
        # show_image(img, 1, "Original")
        # show_image(res, 0, "Mask")

def saveOpenPoseJson(train_annotations):
    numberAnnotations = len(train_annotations)

    # Iterate through each image
    counter = -1
    jointAll = []
    printEveryXFrames = max(1,numberAnnotations/25)
    for i in range(0, numberAnnotations):
        if i%printEveryXFrames == 0:
            print(str(int(float(i)/float(numberAnnotations)*100)) + "%")

        w = train_annotations[i]["annorect"][0]["img_width"]
        h = train_annotations[i]["annorect"][0]["img_height"]
        numerPeople = len(train_annotations[i]["annorect"]);

        # Debug
        img = None
        # img = cv2.imread(sImageFolder+train_annotations[i]["image_path"])

        # Iterate through each image anno
        previousCenters = [];
        for p in range(0, numerPeople):
            # Skip person if num parts too low or seg area too small
            if train_annotations[i]["annorect"][p]["num_keypoints"] >= 5 and train_annotations[i]["annorect"][p]["area"] >= 32*32:
                # Skip person if distance to prev person is too small (So we combine them together)
                personCenter = [train_annotations[i]["annorect"][p]["bbox"][0] + train_annotations[i]["annorect"][p]["bbox"][2] / 2,
                                train_annotations[i]["annorect"][p]["bbox"][1] + train_annotations[i]["annorect"][p]["bbox"][3] / 2]
                addPerson = True;
                for k in range(0, len(previousCenters)):
                    dist = l2([previousCenters[k][0], previousCenters[k][1]], personCenter)
                    if dist < previousCenters[k][2]*0.3:
                        addPerson = False
                        break

                if img is not None:
                    bbox = train_annotations[i]["annorect"][p]["bbox"]
                    cv2.rectangle(img, (int(bbox[0]),int(bbox[1])),(int(bbox[0]+bbox[2]),int(bbox[1]+bbox[3])), 255, 2)
                    show_image(img, 1000)

                # Add Person
                if addPerson:
                    counter += 1
                    data = dict()
                    data["dataset"] = "MPII"
                    data["img_paths"] = train_annotations[i]["image_path"]
                    data["img_width"] = w
                    data["img_height"] = h
                    data["objpos"] = personCenter
                    data["image_id"] = train_annotations[i]["image_id"]
                    data["bbox"] = train_annotations[i]["annorect"][p]["bbox"]
                    data["segment_area"] = train_annotations[i]["annorect"][p]["area"]
                    data["num_keypoints"] = train_annotations[i]["annorect"][p]["num_keypoints"]
                    data["joint_self"] = mpiiann_to_np(train_annotations[i]["annorect"][p]["keypoints"]).tolist()
                    data["scale_provided"] = train_annotations[i]["annorect"][p]["bbox"][3] / sImageScale

                    # Add other people in same image
                    data["scale_provided_other"] = []
                    data["objpos_other"] = []
                    data["bbox_other"] = []
                    data["segment_area_other"] = []
                    data["num_keypoints_other"] = []
                    data["joint_others"] = []
                    counterOther = -1;
                    for o in range(0, numerPeople):
                        if o != p and train_annotations[i]["annorect"][o]["num_keypoints"] > 0:
                            counterOther = counterOther + 1
                            data["scale_provided_other"].append(train_annotations[i]["annorect"][o]["bbox"][3] / sImageScale)
                            otherPersonCenter = [train_annotations[i]["annorect"][o]["bbox"][0] + train_annotations[i]["annorect"][o]["bbox"][2] / 2,
                                train_annotations[i]["annorect"][o]["bbox"][1] + train_annotations[i]["annorect"][o]["bbox"][3] / 2]
                            data["objpos_other"].append(otherPersonCenter)
                            data["bbox_other"].append(train_annotations[i]["annorect"][o]["bbox"])
                            data["segment_area_other"].append(train_annotations[i]["annorect"][o]["area"])
                            data["num_keypoints_other"].append(train_annotations[i]["annorect"][o]["num_keypoints"])
                            data["joint_others"].append(mpiiann_to_np(train_annotations[i]["annorect"][o]["keypoints"]).tolist())
                    
                    # Write Indexes
                    data["annolist_index"] = i
                    data["people_index"] = p
                    data["numOtherPeople"] = len(data["joint_others"])

                    # Update previous center
                    previousCenters.append([personCenter[0], personCenter[1], max(train_annotations[i]["annorect"][p]["bbox"][2],train_annotations[i]["annorect"][p]["bbox"][3])])

                    # Add to jointAll
                    jointAll.append(data)

    # Save to JSON
    open(sFinalJsonPath, 'w').close()
    with open(sFinalJsonPath, 'w') as outfile:
        print("OP Annotations: " + str(len(jointAll)))
        json.dump(jointAll, outfile)

print('Running getAnnotations...')
train_annotations = getAnnotations()
if sMode == 1:
    print('Running generateMasks...')
    generateMasks(train_annotations)
if sMode == 2:
    print('Running saveOpenPoseJson...')
    saveOpenPoseJson(train_annotations)
print('Finished!')
print('Gines!!! Remember that final JSON is not been generated! Either enable sMode=1 for masks or sMode=2 for JSON file.')
