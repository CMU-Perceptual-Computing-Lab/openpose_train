sGenerateLightVersionForDebugging = False
# sGenerateLightVersionForDebugging = True
sDisplayDebugging = sGenerateLightVersionForDebugging

import cv2
import glob
import json
import numpy as np
from coco_util import *
import datetime

def load_calib_data(calib_file):
    with open(calib_file) as f:
        calib = json.load(f)
        for key, val in calib.iteritems():
            if type(val) == list:
                calib[key] = np.array(val)
        return calib
    stop

def vflag_to_color(vflag):
    if vflag == 3:
        return (0,0,0)
    elif vflag == 1:
        return (0,0,255)
    elif vflag == 2:
        return (0,255,0)

def runWholeBody(datasetFolder, jsonData, jsonOutput):
    totalWriteCount = len(jsonData)
    printEveryXIterations = max(1, round(totalWriteCount / 100))
    print("Real #images: " + str(totalWriteCount))

    camera_cache = dict()

    images = []
    annotations = []
    ii = -1
    for data in jsonData:
        ii += 1

        if ii % printEveryXIterations == 0:
            print('Sample %d of %d: %s' % (ii+1, totalWriteCount, data["img"]))
        elif sGenerateLightVersionForDebugging:
            continue

        # Valid
        subjects_with_valid_face = 0
        try:
            subjects_with_valid_body = data["subjectsWithValidBody"]
            subjects_with_valid_Lhand = data["subjectsWithValidLHand"]
            subjects_with_valid_Rhand = data["subjectsWithValidRHand"]
        except Exception as e:
            print('\nError when generating subjects_with_valid_XXX. Image = ' + image_path)
            print('Error reported by Python: ' + str(e))
            print('data:')
            print(data)
            continue

        # No hand/face on image? Continue
        # if (len(subjects_with_valid_Lhand) + len(subjects_with_valid_Rhand) + subjects_with_valid_face <= 0): # 745870 annotations
        if (len(subjects_with_valid_Lhand)<=0 or len(subjects_with_valid_Rhand)<=0): # 201971 annotations
            # print "Skipped!"
            continue
        # print "There is useful data!"

        # Load camera param
        seq_name = data["img"].split("/")[1]
        frame_name = data["img"].split("/")[2]
        camera_id = data["img"].split("/")[3].split("_")[0] + "_" + data["img"].split("/")[3].split("_")[1]
        camera_id_x = int(data["img"].split("/")[3].split("_")[1])
        if seq_name not in camera_cache.keys():
            camera_cache[seq_name] = dict()
        if camera_id not in camera_cache[seq_name]:
            camera_cache[seq_name][camera_id] = dict()
        if not len(camera_cache[seq_name][camera_id].keys()):
            camera_cache[seq_name][camera_id] = load_calib_data(datasetFolder + "/annot_calib/" + seq_name + "/" + "calib_" + camera_id + ".json")
        calib = camera_cache[seq_name][camera_id]

        # Image
        image_path = data["img"]
        img_debug = None
        # # Slow code (it works for all HD/VGA images)
        # img = cv2.imread(datasetFolder + image_path)
        # if sDisplayDebugging:
        #     img_debug = img.copy()
        # img_width = img.shape[1]
        # img_height = img.shape[0]
        # Optimized code (only works for full HD images)
        img_width = 1920
        img_height = 1080
        # # Debugging
        # print(str(img_width) + 'x' + str(img_height))

        # Load Face Data
        face_data_path = "/media/posefs0c/panoptic/" + seq_name + "/hdFace3d/" + "faceRecon3D_hd"+frame_name+".json"
        validFace = True
        try:
            face_data_3d = load_json(face_data_path)
            face_data_2d = dict()
            for face_data in face_data_3d["people"]:
                face_id = face_data["id"]
                face_kp = np.array(face_data["face70"]["landmarks"])
                face_kp = face_kp.reshape((70,3))
                face_kp_2d = project2D(face_kp, calib, imgwh=(img_width, img_height), applyDistort=True)

                # Add based on Rules
                proj_data = []
                for i in range(0, 70):
                    if not face_kp_2d[1][i]:
                        proj_data.append([0,0,3])
                        continue
                    if face_data["face70"]["averageScore"][i] < 0.05:
                        proj_data.append([0,0,3])
                        continue

                    if camera_id_x not in face_data["face70"]["visibility"][i]:
                        proj_data.append([face_kp_2d[0][0,i],face_kp_2d[0][1,i],1])
                        subjects_with_valid_face+=1
                        continue

                    proj_point = (face_kp_2d[0][0,i],face_kp_2d[0][1,i],2)
                    proj_data.append(proj_point)
                    subjects_with_valid_face+=1

                face_data_2d[face_id] = proj_data
        except Exception as e:
            validFace = False
            print('\nError when generating face keypoints, pid = ' + str(pid), '. Image = ' + image_path + '. Face path: ' + face_data_path)
            print('Error reported by Python: ' + str(e))

        # Body - If Visible - Occluded flag shows all correct
        #        Not visible - It shows all

        # Image Object
        image_object = dict()
        image_object["id"] = ii
        image_object["file_name"] = image_path.split("/")[-3] + '/' + image_path.split("/")[-2] + '/' + image_path.split("/")[-1]
        image_object["width"] = img_width
        image_object["height"] = img_height
        images.append(image_object)

        # Body invalid but hand valid?

        # Check the flag subjectsIthValidLHand check it! # Trust this only
        # Onccluded - Occluded by someone else - Never triggered if 1 person
        # Self-Occluded - Itself

        annot2d = load_json(datasetFolder + data["annot_2d"])

        # Anno object
        person_array = []

        # Iterate each person
        for person_data in annot2d:
            pid = person_data["id"]

            # This case would mean that the 3D reconstruction rejected a person generated by the 2D data
            if pid == -1:
                continue

            # Body KPS
            # COCO                  DOME
            # {0,  "Nose"},         1
            # {1,  "LEye"},         15
            # {2,  "REye"},         17
            # {3,  "LEar"},         16
            # {4,  "REar"},         18
            # {5,  "LShoulder"},    3
            # {6,  "RShoulder"},    9
            # {7,  "LElbow"},       4
            # {8,  "RElbow"},       10
            # {9,  "LWrist"},       5
            # {10, "RWrist"},       11
            # {11, "LHip"},         6
            # {12, "RHip"},         12
            # {13, "LKnee"},        7
            # {14, "RKnee"},        13
            # {15, "LAnkle"},       8
            # {16, "RAnkle"},       14
            # domeToCocoOrder=[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18] # No re-order
            domeToCocoOrder=[1,15,17,16,18,3,9,4,10,5,11,6,12,7,13,8,14]
            body_kps = []
            if pid in subjects_with_valid_body:
                # COCO keypoints
                for domeI in range(0, 17):
                    i = domeToCocoOrder[domeI]
                    confidence = person_data["body"]["scores"][i]
                    inside_img = person_data["body"]["insideImg"][i]
                    occluded = person_data["body"]["occluded"][i]
                    vflag = 2
                    if occluded:
                        vflag = 1
                    if confidence < 0.05 or inside_img == 0:
                        body_kps.append([0,0,3])
                        continue
                    body_kp = (person_data["body"]["landmarks"][i][0],
                               person_data["body"]["landmarks"][i][1],
                               vflag)
                    body_kps.append(body_kp)
                    if img_debug is not None:
                        cv2.circle(img_debug,(int(body_kp[0]), int(body_kp[1])), 3, vflag_to_color(body_kp[2]), -1)
                # MPII keypoints
                for i in range(0, 2):
                    body_kps.append([0,0,3])
                # Foot keypoints
                for i in range(0, 6):
                    body_kps.append([0,0,3])
            else:
                print('\nError when generating body keypoints, pid = ' + str(pid), '. Image = ' + image_path)
                stop

            # LHand KPS
            try:
                lhand_kps = []
                if pid in subjects_with_valid_Lhand:
                    for i in range(1, 21):
                        confidence = person_data["left_hand"]["scores"][i]
                        inside_img = person_data["left_hand"]["insideImg"][i]
                        occluded = person_data["left_hand"]["self_occluded"][i]
                        vflag = 2
                        if occluded:
                            vflag = 1
                        if confidence < 0.05 or inside_img == 0:
                            lhand_kps.append([0,0,3])
                            continue
                        hand_kp = (person_data["left_hand"]["landmarks"][i][0],
                                   person_data["left_hand"]["landmarks"][i][1],
                                   vflag)
                        lhand_kps.append(hand_kp)
                        if img_debug is not None:
                            cv2.circle(img_debug,(int(hand_kp[0]), int(hand_kp[1])), 3, vflag_to_color(hand_kp[2]), -1)
                else:
                    # Need to create a bbox mask
                    if img_debug is not None:
                        points = []
                        for i in range(1, 21):
                            kp = (person_data["left_hand"]["landmarks"][i][0],
                                       person_data["left_hand"]["landmarks"][i][1])
                            points.append(kp)
                        rect = get_rect_from_points_only_bigger(points, img_width, img_height)
                        cv2.rectangle(img_debug, (rect[0], rect[1]), (rect[2], rect[3]), (255,0,0), 2)
                    # Add non-labeled keypoints
                    for i in range(1, 21):
                        lhand_kps.append([0,0,3])
            except Exception as e:
                lhand_kps = []
                for i in range(1, 21):
                    lhand_kps.append([0,0,3])
                print('\nError when generating left hand keypoints, pid = ' + str(pid), '. Image = ' + image_path)
                print('Error reported by Python: ' + str(e))
                print('person_data:')
                print(person_data)

            # RHand KPS
            try:
                rhand_kps = []
                if pid in subjects_with_valid_Rhand:
                    for i in range(1, 21):
                        confidence = person_data["right_hand"]["scores"][i]
                        inside_img = person_data["right_hand"]["insideImg"][i]
                        occluded = person_data["right_hand"]["self_occluded"][i]
                        vflag = 2
                        if occluded:
                            vflag = 1
                        if confidence < 0.05 or inside_img == 0:
                            rhand_kps.append([0,0,3])
                            continue
                        hand_kp = (person_data["right_hand"]["landmarks"][i][0],
                                   person_data["right_hand"]["landmarks"][i][1],
                                   vflag)
                        rhand_kps.append(hand_kp)
                        if img_debug is not None:
                            cv2.circle(img_debug,(int(hand_kp[0]), int(hand_kp[1])), 3, vflag_to_color(hand_kp[2]), -1)
                else:
                    # Need to create a bbox mask
                    if img_debug is not None:
                        points = []
                        for i in range(1, 21):
                            kp = (person_data["right_hand"]["landmarks"][i][0],
                                       person_data["right_hand"]["landmarks"][i][1])
                            points.append(kp)
                        rect = get_rect_from_points_only_bigger(points, img_width, img_height)
                        cv2.rectangle(img_debug, (rect[0], rect[1]), (rect[2], rect[3]), (255,0,0), 2)
                    # Add non-labeled keypoints
                    for i in range(1, 21):
                        rhand_kps.append([0,0,3])
            except Exception as e:
                rhand_kps = []
                for i in range(1, 21):
                    rhand_kps.append([0,0,3])
                print('\nError when generating right hand keypoints, pid = ' + str(pid), '. Image = ' + image_path)
                print('Error reported by Python: ' + str(e))
                print('person_data:')
                print(person_data)

            # If KP missing for hand, take the points and mask out

            # Face
            face_kps = []
            if validFace and pid in face_data_2d.keys():
                fkps = face_data_2d[pid]
                for kp in fkps:
                    face_kps.append(kp)
                for kp in fkps:
                    if img_debug is not None:
                        cv2.circle(img_debug,(int(kp[0]), int(kp[1])), 3, vflag_to_color(kp[2]), -1)
            else:
                for i in range(0, 70):
                    face_kps.append([0,0,3])

            # 19 + 20(no 21) + 20(no 21) + 70
            all_kps = body_kps + lhand_kps + rhand_kps + face_kps

            # Get rectangle
            rect = get_rect_from_points_only_bigger(all_kps, img_width, img_height, 0.1)
            rectW = rect[2]-rect[0]
            rectH = rect[3]-rect[1]
            # Display - Rectangle
            if img_debug is not None:
                cv2.rectangle(img_debug, (int(rect[0]), int(rect[1])), (int(rect[2]), int(rect[3])), 255, 2)

            # Store Person Data
            data = dict()
            data["segmentation"] = [] # DONT HAVE
            data["num_keypoints"] = len(all_kps)/3
            data["img_path"] = image_path.split("/")[-1]
            data["bbox"] = [rect[0], rect[1], rectW, rectH]
            data["area"] = data["bbox"][2]*data["bbox"][3]
            data["iscrowd"] = 0
            data["keypoints"] = np.array(all_kps).ravel().tolist()
            data["img_width"] = img_width
            data["img_height"] = img_height
            data["category_id"] = 1
            data["image_id"] = ii
            data["id"] = pid

            person_array.append(data)

        # Append Annot
        for arr in person_array:
            annotations.append(arr)

        # Visualize
        if img_debug is not None:
            cv2.imshow("win", cv2.pyrDown(img_debug))
            cv2.waitKey(0)

        # Create 100 images thats all

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
    print("Final #Annotations: " + str(len(json_object["annotations"])))
    open(jsonOutput, 'w').close()
    with open(jsonOutput, 'w') as outfile:
        json.dump(json_object, outfile)
    print("Saved!")

# Main script
print("VERY IMPORTANT: THIS SCRIPT ASSUMES ONLY FULL HD IMAGE RESOLUTION (FOR SPEEDUP). CHANGE CODE TO HANDLE NON-FULLHD IMAGES!!!")
print("Starting at "+ str(datetime.datetime.now()))
print("1 - Annotated and not visibile")
print("2 - Annotated and visibile")
print("3 - Not annotated, out of image or poor confidence")
print("Reading input JSON...")
sDatasetFolder = "/media/posefs0c/panopticdb/a4/"
sJsonData = load_json(sDatasetFolder + "sample_list_2d.json")
print("Generating output JSON...")
sOutputDatasetFolder = "../dataset/dome/"
sJsonOutput = sOutputDatasetFolder + 'dome135_train.json'
runWholeBody(sDatasetFolder, sJsonData, sJsonOutput)
print("Finished at "+ str(datetime.datetime.now()))
print("VERY IMPORTANT: THIS SCRIPT ASSUMES ONLY FULL HD IMAGE RESOLUTION (FOR SPEEDUP). CHANGE CODE TO HANDLE NON-FULLHD IMAGES!!!")
