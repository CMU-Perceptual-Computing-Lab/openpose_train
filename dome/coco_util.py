import cv2
# import glob
# import natsort
import json
import numpy as np
# import os
# import magic
# import math

def project2D(joints, calib, imgwh=None, applyDistort=True):
    """
    Input:
    joints: N * 3 numpy array.
    calib: a dict containing 'R', 'K', 't', 'distCoef' (numpy array)

    Output:
    pt: 2 * N numpy array
    inside_img: (N, ) numpy array (bool)
    """
    x = np.dot(calib['R'], joints.T) + calib['t']
    xp = x[:2, :] / x[2, :]

    if applyDistort:
        X2 = xp[0, :] * xp[0, :]
        Y2 = xp[1, :] * xp[1, :]
        XY = X2 * Y2
        R2 = X2 + Y2
        R4 = R2 * R2
        R6 = R4 * R2

        dc = calib['distCoef']
        radial = 1.0 + dc[0] * R2 + dc[1] * R4 + dc[4] * R6
        tan_x = 2.0 * dc[2] * XY + dc[3] * (R2 + 2.0 * X2)
        tan_y = 2.0 * dc[3] * XY + dc[2] * (R2 + 2.0 * Y2)

        # xp = [radial;radial].*xp(1:2,:) + [tangential_x; tangential_y]
        xp[0, :] = radial * xp[0, :] + tan_x
        xp[1, :] = radial * xp[1, :] + tan_y

    # pt = bsxfun(@plus, cam.K(1:2,1:2)*xp, cam.K(1:2,3))';
    pt = np.dot(calib['K'][:2, :2], xp) + calib['K'][:2, 2].reshape((2, 1))

    if imgwh is not None:
        assert len(imgwh) == 2
        imw, imh = imgwh
        winside_img = np.logical_and(pt[0, :] > -0.5, pt[0, :] < imw-0.5) 
        hinside_img = np.logical_and(pt[1, :] > -0.5, pt[1, :] < imh-0.5) 
        inside_img = np.logical_and(winside_img, hinside_img) 
        inside_img = np.logical_and(inside_img, R2 < 1.0) 
        return pt, inside_img

    return pt

def load_json(path):
    if path.endswith(".json"):
        with open(path) as json_data:
            #print path
            d = json.load(json_data)
            json_data.close()
            return d

    print "Failed to Load JSON"
    stop
    return 0

def write_json(path, data):
    with open(path, 'w') as outfile:
        json.dump(data, outfile)

def show_image(img, waitKeyValue = 1, name="win"):
    if img is not None:
        cv2.imshow(name,img)
        key = cv2.waitKey(waitKeyValue)
        if key == 32:
            while 1:
                key = cv2.waitKey(waitKeyValue)
                if key == 32:
                    break

def get_rect_from_points_only(points):
    minx = 1000000
    miny = 1000000
    maxx = 0
    maxy = 0
    for point in points:
        if len(point) == 3: 
            if point[2] == 0 or point[2] == 3: continue
        if point[0] < minx:
            minx = point[0]
        if point[1] < miny:
            miny = point[1]
        if point[0] > maxx:
            maxx = point[0]
        if point[1] > maxy:
            maxy = point[1]
    return [int(minx), int(miny), int(maxx), int(maxy)]

def get_rect_from_points_only_bigger(points, imgageWidth, imgageHeight, ratio=0.1):
    rect = get_rect_from_points_only(points)
    rectW = rect[2]-rect[0]
    rectH = rect[3]-rect[1]
    rect[0] = int(max(0, rect[0]-ratio*rectW))
    rect[1] = int(max(0, rect[1]-ratio*rectH))
    rect[2] = int(min(imgageWidth-1, rect[2]+ratio*rectW))
    rect[3] = int(min(imgageHeight-1, rect[3]+ratio*rectH))
    return rect
