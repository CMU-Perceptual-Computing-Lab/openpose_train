sGenerateLightVersionForDebugging = False
# sGenerateLightVersionForDebugging = True
sDatasetFolder = "../dataset/hand/"
sDisplayDebugging = sGenerateLightVersionForDebugging

import cv2
import json
from coco_util import *

def runHands(jsonOutput, imageAndAnnotFolder):
    data = load_json(imageAndAnnotFolder + "hands_v143_14817.json")

    totalWriteCount = len(data["root"])
    printEveryXIterations = max(1, round(totalWriteCount / 10))
    print("Initial #annotations: " + str(totalWriteCount))

    ii=-1
    pid=-1
    annotations= []
    images = []
    for item in data["root"]:
        ii+=1
        pid+=1

        if ii % printEveryXIterations == 0:
            print('Sample %d of %d' % (ii+1, totalWriteCount))
        elif sGenerateLightVersionForDebugging:
            continue

        img = cv2.imread(imageAndAnnotFolder + item["img_paths"])
        # Fill hand keypoints
        all_points = []
        # Option a) Remove empty left hand
        # pass
        # # Option b) Add empty left hand
        # left_hand_pts = []
        # if len(left_hand_pts) == 0:
        #     for i in range(0, 21): left_hand_pts.append([0,0,0])
        # all_points.extend(left_hand_pts)

        right_hand_pts = item["joint_self"]
        all_points.extend(right_hand_pts)

        for pt in all_points:
            if pt[2] == 0: continue
            cv2.circle(img, (int(pt[0]), int(pt[1])), 2, (0,0,255), -1)

        # Convert into caffe visibility?
        caffe_points = []
        for point in all_points:
            caffe_points.append(point[0])
            caffe_points.append(point[1])
            caffe_points.append(point[2])

        # Add Image
        image_path = item["img_paths"]

        # Image
        img_width = img.shape[1]
        img_height = img.shape[0]

        # Add Image
        image_object = dict()
        image_object["id"] = ii
        image_object["file_name"] = image_path.split("/")[-1]
        image_object["width"] = img_width
        image_object["height"] = img_height
        images.append(image_object)

        # Get rectangle
        rect = get_rect_from_points_only_bigger(right_hand_pts, img_width, img_height, 10)
        rectW = rect[2]-rect[0]
        rectH = rect[3]-rect[1]

        # Store Person Data
        data = dict()
        data["segmentation"] = [] # DONT HAVE
        data["num_keypoints"] = len(all_points)
        data["img_path"] = image_path.split("/")[-1]
        data["bbox"] = [rect[0], rect[1], rect[2]-rect[0], rect[3]-rect[1]]
        data["area"] = data["bbox"][2]*data["bbox"][3]
        data["iscrowd"] = 0
        data["keypoints"] = caffe_points
        data["img_width"] = img_width
        data["img_height"] = img_height
        data["category_id"] = 1
        data["image_id"] = ii
        data["id"] = pid

        annotations.append(data)

        # Display
        if sDisplayDebugging:
            cv2.rectangle(img, (int(rect[0]), int(rect[1])), (int(rect[2]), int(rect[3])), 255, 2)
            show_image(img)
            cv2.waitKey(-1)

    # Json Object
    json_object = dict()
    json_object["info"] = dict()
    json_object["info"]["version"] = 1.0
    json_object["info"]["description"] = "Hands Dome Dataset in COCO Json Format"
    json_object["licenses"] = []
    json_object["images"] = images
    json_object["annotations"] = annotations

    # JSON writing
    print("Saving " + jsonOutput + "...")
    print("Final #Images: " + str(len(json_object["images"])))
    print("Final #Annotations: " + str(len(json_object["annotations"])))
    open(jsonOutput, 'w').close()
    with open(jsonOutput, 'w') as outfile:
        json.dump(json_object, outfile)
    print("Saved!")

sImageAndAnnotFolder = sDatasetFolder + "hand143_panopticdb/"
sJsonOutput = sDatasetFolder + 'json/hand21_dome_train.json'
runHands(sJsonOutput, sImageAndAnnotFolder)
