sGenerateLightVersionForDebugging = False
# sGenerateLightVersionForDebugging = True
sDatasetFolder = "/media/posefs3b/Users/gines/Datasets/face/tomas_ready/"
sRawDatasetFolder = sDatasetFolder + 'raw_datasets/'
sDatasets =[
    # Standalone datasets, 1 person / image
    ["frgc_val"],
    ["multipie_val"],
    ["frgc_train"],
    ["multipie_train"],
    # Combined (too small by themselves), 1 person / image labeled, unlabeled images too
    ["face_mask_out_all"] # This one combines Helen + Ibug + LFPW
    # ["face_mask_out_train", "helen_raw", "ibug_raw", "lfpw_raw"], # Not used because the are not sorted
    # ["helen"],
    # ["ibug"],
    # ["lfpw"]
]

import cv2
import glob
import natsort
import json
import numpy as np
import os

def show_image(img, waitKeyValue = 1, name="win"):
    if img is not None:
        cv2.imshow(name,img)
        key = cv2.waitKey(waitKeyValue)
        if key == 32:
            while 1:
                key = cv2.waitKey(waitKeyValue)
                if key == 32:
                    break

def cocoann_to_np(cocoann):
    total_size = len(cocoann)/3
    # 0 not labeled (highly occluded or out of the image)
    # 1 labeled but not visible
    # 2 labeled and visible
    # 3 not in dataset
    nparr = np.zeros(shape=(total_size,3))
    for i in range(0,total_size):
        nparr[i,0] = cocoann[i*3 + 0]
        nparr[i,1] = cocoann[i*3 + 1]
        cocoann_prob =  cocoann[i*3 + 2]
        if cocoann_prob == 1:
            nparr[i,2] = 2
        elif cocoann_prob == 0:
            nparr[i,2] = 0
        elif cocoann_prob == 3:
            nparr[i,2] = 3
    return nparr

def load_pts(file):
    text_file = open(file, "r")
    lines = text_file.readlines()
    text_file.close()

    pts = []
    start = False
    for line in lines:
        line = line.strip()
        if len(line) == 0: continue
        if "{" in line: 
            start = True
            continue
        elif "}" in line:
            break

        if start:
            a,b = line.split(" ")
            pts.append((float(a), float(b), 1.))

    return pts

def getRectFromKeypoints(points, img_width, img_height, rect_scale = 0.05):
    minx = 1000000
    miny = 1000000
    maxx = 0
    maxy = 0
    for point in points:
        if point[2] == 1:
            if point[0] < minx:
                minx = point[0]
            if point[1] < miny:
                miny = point[1]
            if point[0] > maxx:
                maxx = point[0]
            if point[1] > maxy:
                maxy = point[1]

    rect = [minx, miny, maxx, maxy]

    # Increase fake rect a bit
    rect_scale = 0.1
    rect[0] = rect[0] - (rect[2] - rect[0])*rect_scale*1 # X
    rect[2] = rect[2] + (rect[2] - rect[0])*rect_scale*1 # X
    rect[1] = rect[1] - (rect[3] - rect[1])*rect_scale*5 # Y
    rect[3] = rect[3] + (rect[3] - rect[1])*rect_scale*1 # Y
    rect[0] = max(rect[0], 0)
    rect[2] = min(rect[2], img_width)
    rect[1] = max(rect[1], 0)
    rect[3] = min(rect[3], img_height)

    # (x1,y1,x2,y2) --> (x1,y1,w,h)
    rect[2] = rect[2] - rect[0]
    rect[3] = rect[3] - rect[1]

    return rect

def getDatasetImageAndAnnotPaths(datasetFolder):
    image_files = natsort.natsorted(glob.glob(datasetFolder + "*.jpg") + glob.glob(datasetFolder + "*.png"))
    pts_files = natsort.natsorted(glob.glob(datasetFolder + "*.pts"))
    print('There is a total of ' + str(len(image_files)) + ' image/pts pairs in the main folder.')
    # Read subdirectories if no images in main folder
    if len(image_files) == 0:
        folders = list(filter(lambda x: os.path.isdir(os.path.join(datasetFolder, x)), os.listdir(datasetFolder)))
        for folder in folders:
            fullFolder = datasetFolder + folder + "/"
            image_files += natsort.natsorted(glob.glob(fullFolder + "*.jpg")) + natsort.natsorted(glob.glob(fullFolder + "*.png"))
            pts_files += natsort.natsorted(glob.glob(fullFolder + "*.pts"))
        print('There is a total of ' + str(len(image_files)) + ' image/pts pairs in the subfolders.')
    # Sanity check
    if len(image_files) != len(pts_files):
        print('In ' + datasetFolder + ' , len(image_files) != len(pts_files)!: ' + str(len(image_files)) + " vs. " + str(len(pts_files)))
        assert(false)
    # Result
    # finalDictionary = dict()
    # finalDictionary["image_files"] = image_files
    # finalDictionary["pts_files"] = pts_files
    return {"image_files": image_files, "pts_files": pts_files}

def datasetToimagePathAndAnnots(datasetFolder, visualize, imageAndAnnotPaths = None):
    if imageAndAnnotPaths is None:
        image_files = glob.glob(datasetFolder + "*.jpg") + glob.glob(datasetFolder + "*.png")
        pts_files = glob.glob(datasetFolder + "*.pts")
        print('There is a total of ' + str(len(image_files)) + ' image/pts pairs in the main folder.')
        # Read subdirectories if no images in main folder
        if len(image_files) == 0:
            folders = list(filter(lambda x: os.path.isdir(os.path.join(datasetFolder, x)), os.listdir(datasetFolder)))
            for folder in folders:
                fullFolder = datasetFolder + folder + "/"
                image_files += glob.glob(fullFolder + "*.jpg") + glob.glob(fullFolder + "*.png")
                pts_files += glob.glob(fullFolder + "*.pts")
            print('There is a total of ' + str(len(image_files)) + ' image/pts pairs in the subfolders.')
    else:
        image_files = imageAndAnnotPaths["image_files"]
        pts_files = imageAndAnnotPaths["pts_files"]
    # NAT Sort files
    image_files = natsort.natsorted(image_files)
    pts_files = natsort.natsorted(pts_files)
    # Sanity check
    if len(image_files) != len(pts_files):
        print('len(image_files) != len(pts_files)!: ' + str(len(image_files)) + " vs. " + str(len(pts_files)))
        assert(false)

    totalWriteCount = len(image_files)
    printEveryXIterations = max(1, round(totalWriteCount / 10))

    imagePathAndAnnots = []
    numberSample = 0
    isValidationJson = 'val' in datasetFolder[-4:]
    for pts_file, image_file in zip(pts_files, image_files):
        numberSample += 1
        if numberSample % printEveryXIterations == 0:
            print('Sample %d of %d' % (numberSample+1, totalWriteCount))
        elif sGenerateLightVersionForDebugging:
            continue

        pts = load_pts(pts_file)

        # Debugging
        if visualize:
            # Read image
            img = cv2.imread(image_file)
            i = 0
            # Add annotations
            for pt in pts:
                cv2.circle(img,(int(pt[0]), int(pt[1])), 2, (0,1*255,0), -1)
                cv2.putText(img,str(i), (int(pt[0]), int(pt[1])), cv2.FONT_HERSHEY_SIMPLEX, 0.3, (0,255,255), 1)
                i+=1
            # Display it
            show_image(img, 0)

        # 68 and 69 are the pupils are not annotated
        if len(pts) == 68:
            if not isValidationJson:
                pts.append((0., 0., 3.))
                pts.append((0., 0., 3.))
        else:#if len(pts) != 70
            print('Not expected number of keypoints: ' + str(len(pts)))
            assert(False)

        annot = {"image_path": image_file, "annot": pts}
        imagePathAndAnnots.append(annot)

    return imagePathAndAnnots

def datasetsToimagePathAndAnnots(datasetFolder, datasets, visualize):
    if len(datasets) == 1:
        return datasetToimagePathAndAnnots(datasetFolder + datasets[0] + "/", visualize)
    else:
        # Read all images (sorted in NAT order)
        imageAndAnnotPaths = dict()
        imageAndAnnotPaths["image_files"] = []
        imageAndAnnotPaths["pts_files"] = []
        for dataset in datasets[1:]:
            imageAndAnnotPathI = getDatasetImageAndAnnotPaths(datasetFolder + dataset + "/")
            imageAndAnnotPaths["image_files"] += imageAndAnnotPathI["image_files"]
            imageAndAnnotPaths["pts_files"] += imageAndAnnotPathI["pts_files"]
        print('Final size: ' + str(len(imageAndAnnotPaths["image_files"])) + ' images.')
        print('Final size: ' + str(len(imageAndAnnotPaths["pts_files"])) + ' annotations.')
        return datasetToimagePathAndAnnots(datasetFolder + datasets[0] + "/", visualize, imageAndAnnotPaths)
        # # Process all images
        # imagePathAndAnnots = []
        # for dataset in datasets[1:]:
        #     imagePathAndAnnots += datasetToimagePathAndAnnots(datasetFolder + dataset + "/", visualize)
        #     print(' ')
        # print('Final size: ' + str(len(imagePathAndAnnots)) + ' image/annotation pairs.')
        # return imagePathAndAnnots

def imagePathAndAnnotsToJson(imagePathAndAnnots, jsonOutput, visualize):
    totalWriteCount = len(imagePathAndAnnots)
    printEveryXIterations = max(1, round(totalWriteCount / 10))

    imageId = -1
    annotations = []
    images = []
    for data in imagePathAndAnnots:
        imageId += 1
        if imageId % printEveryXIterations == 0:
            print('Sample %d of %d' % (imageId, totalWriteCount))

        # Load image
        img = cv2.imread(data["image_path"])

        # Bounding Box
        img_width = img.shape[1]
        img_height = img.shape[0]
        pts = data["annot"]
        # Rect
        rect = getRectFromKeypoints(data["annot"], img_width, img_height, 0.05)

        if not visualize:
            img = None

        # Debug - Display
        if img is not None:
            i = 0
            for pt in pts:
                cv2.circle(img,(int(pt[0]), int(pt[1])), 2, (0,1*255,0), -1)
                cv2.putText(img,str(i), (int(pt[0]), int(pt[1])), cv2.FONT_HERSHEY_SIMPLEX, 0.3, (0,255,255), 1)
                i+=1
            rectX = int(rect[0])
            rectY = int(rect[1])
            rectX2 = rectX + int(rect[2])
            rectY2 = rectY + int(rect[3])
            cv2.rectangle(img, (rectX, rectY), (rectX2, rectY2), (255,0,0), 2)
            show_image(img, 1000)

        # Dump to list
        pts_list = []
        for pt in pts:
            pts_list.append(pt[0])
            pts_list.append(pt[1])
            pts_list.append(pt[2])
        llist = cocoann_to_np(pts_list).tolist()
        keypoints = [item for sublist in llist for item in sublist]

        # Add person
        faceCocoInstance = dict()
        faceCocoInstance["segmentation"] = []
        faceCocoInstance["area"] = rect[2]*rect[3]
        if faceCocoInstance["area"] < 0:
            print('imageId ' + str(imageId))
            print('faceCocoInstance["area"] = ' + str(faceCocoInstance["area"]) + '< 0!')
            print('For keypoints = ' + str(keypoints))
            print('For data["image_path"] = ' + data["image_path"])
            print('area = ' + str(rect[2]) + '*' + str(rect[3]))
            assert(False)
        faceCocoInstance["iscrowd"] = 0
        faceCocoInstance["keypoints"] = keypoints
        faceCocoInstance["num_keypoints"] = len(faceCocoInstance["keypoints"])/3 # (x,y,visibility)
        faceCocoInstance["bbox"] = rect
        faceCocoInstance["category_id"] = 1
        faceCocoInstance["id"] = imageId
        # Image info
        imageFileName = os.path.basename(data["image_path"])
        faceCocoInstance["image_id"] = imageId
        faceCocoInstance["img_path"] = imageFileName
        faceCocoInstance["img_width"] = img_width
        faceCocoInstance["img_height"] = img_height

        # Add image
        imageCocoInstance = dict()
        # imageCocoInstance["license"] =
        imageCocoInstance["file_name"] = imageFileName
        # imageCocoInstance["coco_url"] =
        imageCocoInstance["height"] = img_height
        imageCocoInstance["width"] = img_width
        # imageCocoInstance["date_captured"] =
        # imageCocoInstance["flickr_url"] =
        imageCocoInstance["id"] = imageId

        # Add to annotations
        annotations.append(faceCocoInstance)
        images.append(imageCocoInstance)

    print('There is a total of ' + str(len(annotations)) + ' instances (i.e., #people).')

    # Generate final JSON-formated dictionary
    faceCocoJson = dict()
    faceCocoJson["info"] = dict()
    faceCocoJson["info"]["description"] = "Face Dataset in COCO JSON format"
    faceCocoJson["info"]["version"] = "1.0"
    # Licenses
    faceCocoJson["licenses"] = dict()
    faceCocoJson["licenses"]["url"] = "unknown"
    faceCocoJson["licenses"]["id"] = 1
    faceCocoJson["licenses"]["name"] = "unknown"
    # Categories
    faceCocoJson["categories"] = []
    category = dict()
    category["supercategory"] = "person"
    category["name"] = "person"
    category["id"] = 1
    # category["keypoints"] = 1
    # category["skeleton"] = 1
    faceCocoJson["categories"].append(category)
    # Images
    faceCocoJson["images"] = images
    # Annotations
    faceCocoJson["annotations"] = annotations
    # Save JSON
    json.dump(faceCocoJson, open(jsonOutput, 'wb'))

for dataset in sDatasets:
    print('Running datasetsToimagePathAndAnnots for ' + dataset[0] + '...')
    visualize = False
    imagePathAndAnnots = datasetsToimagePathAndAnnots(sRawDatasetFolder, dataset, visualize)
    # imagePathAndAnnots.sort(key=lambda x: x["image_path"], reverse=False) # They are already sorted
    print(' ')

    print('Running imagePathAndAnnotsToJson for ' + dataset[0] + '...')
    visualize = False
    cocoInit = imagePathAndAnnotsToJson(imagePathAndAnnots, sDatasetFolder + dataset[0] + ".json", visualize)
    print('\n\n')
