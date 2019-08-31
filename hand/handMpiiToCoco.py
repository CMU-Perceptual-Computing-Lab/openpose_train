sGenerateLightVersionForDebugging = False
# sGenerateLightVersionForDebugging = True
sDatasetFolder = "../dataset/hand/"
sDisplayDebugging = sGenerateLightVersionForDebugging

import cv2
import glob
import natsort
import json
from coco_util import *

def split_file(name):
    splits = name.split('/')[-1]
    splits = splits.split('.')
    nameid = splits[0]
    if splits[1] == "jpg" or splits[1] == "json":
        splits = splits[0]
        splits= splits.split('_')
        return (splits[0], splits[1], splits[2])
    elif splits[2] == "jpg" or splits[2] == "json":
        splits = splits[1]
        splits= splits.split('_')
        return (nameid + splits[1], "01",  splits[2])

    print("Error")
    stop
    # 000015774_01_l.jpg
    # Alexander_mouse_cat_rooster.flv_000115_l.jpg

def runHands(jsonOutput, imageAndAnnotFolder):
    image_files = natsort.natsorted(glob.glob(imageAndAnnotFolder + "*.jpg"))
    pt_files = natsort.natsorted(glob.glob(imageAndAnnotFolder + "*.json"))
    print("Initial #annotations (left or right): " + str(len(image_files)))

    # Consolidate data
    hands_dict = dict()
    for image_file, pt_file in zip(image_files, pt_files):
        # Sanity check
        if len(load_json(pt_file)["hand_pts"]) != 21:
            print('Image ' + image_file + ' did not seem to have annotations.')
            stop
        # Read image and annotations
        img_id, pid_ifile, hand_dir = split_file(image_file)
        pt_id, pid_ptfile, pt_dir = split_file(pt_file)
        if (img_id[1] != pt_id[1]) or (pid_ifile[1] != pid_ptfile[1]):
            print("Error")
            stop
        if img_id not in hands_dict:
            hands_dict[img_id] = dict()
            hands_dict[img_id]["persons"] = dict()
            hands_dict[img_id]["image_path"] = image_file
        if pid_ifile not in hands_dict[img_id]["persons"]:
            hands_dict[img_id]["persons"][pid_ifile] = dict()
        if hand_dir not in hands_dict[img_id]["persons"][pid_ifile]:
            hands_dict[img_id]["persons"][pid_ifile][hand_dir] = dict()
        hands_dict[img_id]["persons"][pid_ifile][hand_dir]["pt_path"] = pt_file

    totalWriteCount = len(hands_dict)
    printEveryXIterations = max(1, round(totalWriteCount / 10))
    print("Real #images: " + str(totalWriteCount))

    # Iterate each image
    images = []
    annotations = []
    ii = -1
    pid = -1
    for key, value in natsort.natsorted(hands_dict.iteritems()):
        ii+=1

        if ii % printEveryXIterations == 0:
            print('Sample %d of %d' % (ii+1, totalWriteCount))
        elif sGenerateLightVersionForDebugging:
            continue

        #print(key)
        #if key != "000154": continue
        image_path = value["image_path"]

        # Image
        img = None
        img = cv2.imread(image_path)
        img_width = img.shape[1]
        img_height = img.shape[0]

        # Image Object
        image_object = dict()
        image_object["id"] = ii
        image_object["file_name"] = image_path.split("/")[-1]
        image_object["width"] = img_width
        image_object["height"] = img_height
        images.append(image_object)

        # Anno object
        person_array = []
        # anno = dict()
        # anno["image_path"] = image_path
        # anno["image_id"] = ii
        # anno["annorect"] = []
        # add = True

        # Iterate each person
        for person_key, person_value in value["persons"].iteritems():
            pid+=1

            # Load 
            mpii_body_pts = []
            left_hand_pts = []
            if "l" in person_value: 
                left_hand_pts = load_json(person_value["l"]["pt_path"])["hand_pts"]
                mpii_body_pts.extend(load_json(person_value["l"]["pt_path"])["mpii_body_pts"])
                mpii_body_pts.extend(load_json(person_value["l"]["pt_path"])["head_box"])
                mpii_body_pts.extend(left_hand_pts)
            right_hand_pts = []
            if "r" in person_value: 
                right_hand_pts = load_json(person_value["r"]["pt_path"])["hand_pts"]
                mpii_body_pts.extend(load_json(person_value["r"]["pt_path"])["mpii_body_pts"])
                mpii_body_pts.extend(load_json(person_value["r"]["pt_path"])["head_box"])
                mpii_body_pts.extend(right_hand_pts)

            # Populate with fake points if not there
            if len(left_hand_pts) == 0:
                for i in range(0, 21): left_hand_pts.append([0,0,0])
            if len(right_hand_pts) == 0:
                for i in range(0, 21): right_hand_pts.append([0,0,0])

            # Check if 21
            if len(left_hand_pts) != 21 or len(right_hand_pts) != 21:
                print("Error")
                stop

            # Draw
            # for pt in mpii_body_pts:
            #     if len(pt) == 3: 
            #         if pt[2] == 0: continue
            #     cv2.circle(img, (int(pt[0]), int(pt[1])), 2, (255,0,0), -1)
            for pt in left_hand_pts:
                if pt[2] == 0: continue
                cv2.circle(img, (int(pt[0]), int(pt[1])), 2, (0,0,255), -1)
            for pt in right_hand_pts:
                if pt[2] == 0: continue
                cv2.circle(img, (int(pt[0]), int(pt[1])), 2, (0,255,0), -1)

            # Mix together
            all_points = left_hand_pts
            all_points.extend(right_hand_pts)

            # Convert into caffe visibility?
            caffe_points = []
            for point in all_points:
                caffe_points.append(point[0])
                caffe_points.append(point[1])
                caffe_points.append(point[2])

            # Get rectangle
            rect = get_rect_from_points_only_bigger(mpii_body_pts, img_width, img_height, 0.1)
            rectW = rect[2]-rect[0]
            rectH = rect[3]-rect[1]
            # Display - Rectangle
            if sDisplayDebugging:
                cv2.rectangle(img, (int(rect[0]), int(rect[1])), (int(rect[2]), int(rect[3])), 255, 2)

            # Store Person Data
            data = dict()
            data["segmentation"] = [] # DONT HAVE
            data["num_keypoints"] = len(all_points)
            data["img_path"] = image_path.split("/")[-1]
            data["bbox"] = [rect[0], rect[1], rectW, rectH]
            data["area"] = data["bbox"][2]*data["bbox"][3]
            data["iscrowd"] = 0
            data["keypoints"] = caffe_points
            data["img_width"] = img_width
            data["img_height"] = img_height
            data["category_id"] = 1
            data["image_id"] = ii
            data["id"] = pid

            person_array.append(data)

        # Append Annot
        for arr in person_array:
            annotations.append(arr)

        # Display
        if sDisplayDebugging:
            show_image(img)
            cv2.waitKey(-1)

    # Json Object
    json_object = dict()
    json_object["info"] = dict()
    json_object["info"]["version"] = 1.0
    json_object["info"]["description"] = "Hands MPII Dataset in COCO Json Format"
    json_object["licenses"] = []
    json_object["images"] = images
    json_object["annotations"] = annotations

    # JSON writing
    print("Saving " + jsonOutput + "...")
    print("Final #Images: " + str(len(json_object["images"])))
    print("Final #Annotations (#labeled people): " + str(len(json_object["annotations"])))
    open(jsonOutput, 'w').close()
    with open(jsonOutput, 'w') as outfile:
        json.dump(json_object, outfile)
    print("Saved!")

# # Test
# sImageAndAnnotFolder = sDatasetFolder + "raw_datasets/hand_labels/manual_test/"
# sJsonOutput = sDatasetFolder + 'json/hand42_mpii_test.json'
# runHands(sJsonOutput, sImageAndAnnotFolder)
# print(' ')
# # Train
# sImageAndAnnotFolder = sDatasetFolder + "raw_datasets/hand_labels/manual_train/"
# sJsonOutput = sDatasetFolder + 'json/hand42_mpii_train.json'
# runHands(sJsonOutput, sImageAndAnnotFolder)
# Test v2
sImageAndAnnotFolder = sDatasetFolder + "hand_labels_v2/manual_test_v2/"
sJsonOutput = sDatasetFolder + 'json/hand42_mpii_test_v2.json'
runHands(sJsonOutput, sImageAndAnnotFolder)
print(' ')
# Train v2
sImageAndAnnotFolder = sDatasetFolder + "hand_labels_v2/manual_train_v2/"
sJsonOutput = sDatasetFolder + 'json/hand42_mpii_train_v2.json'
runHands(sJsonOutput, sImageAndAnnotFolder)
