import cv2
import json
import math

def l2(a,b):
    return math.sqrt(pow(a[0]-b[0],2)+pow(a[1]-b[1],2))

def load_json(path):
    if path.endswith(".json"):
        with open(path) as json_data:
            #print path
            d = json.load(json_data)
            json_data.close()
            return d
    return 0

def get_rect_from_points(all_points, head_rect):
    points = []
    for key, value in all_points.iteritems():
        if value[0] == 0 and value[1] == 0:
            continue
        else:
            points.append(value)

    points.append((head_rect[0],head_rect[1]))
    points.append((head_rect[2],head_rect[3]))

    minx = 1000000
    miny = 1000000
    maxx = 0
    maxy = 0
    for point in points:
        if point[0] < minx:
            minx = point[0]
        if point[1] < miny:
            miny = point[1]
        if point[0] > maxx:
            maxx = point[0]
        if point[1] > maxy:
            maxy = point[1]
    return [minx, miny, maxx, maxy]

colors = [(255,0,0),(0,255,0),(0,0,255),(255,255,0),(0,255,255),(255,0,255),(128,255,0),(0,128,255),(128,0,255),(128,0,0),(0,128,0),(0,0,128),(50,50,0),(50,50,0),(0,50,128),(0,100,128),(100,30,128),(0,50,255),(50,255,128),(100,90,128),(0,90,255),(50,90,128),(255,0,0),(0,255,0),(0,0,255),(255,255,0),(0,255,255),(255,0,255),(128,255,0),(0,128,255),(128,0,255),(128,0,0),(0,128,0),(0,0,128),(50,50,0),(50,50,0),(0,50,128),(0,100,128),(100,30,128),(0,50,255),(50,255,128),(100,90,128),(0,90,255),(50,90,128)]

MAPPING = dict()
MAPPING["RANKLE"] = 0
MAPPING["RKNEE"] = 1
MAPPING["RHIP"] = 2
MAPPING["LHIP"] = 3
MAPPING["LKNEE"] = 4
MAPPING["LANKLE"] = 5
MAPPING["MIDHIP"] = 6 # called pelvis in MPII
MAPPING["MIDSHOULDER"] = 7 # called thorax in MPII
MAPPING["NECK"] = 8
MAPPING["TOP"] = 9
MAPPING["RWRIST"] = 10
MAPPING["RELBOW"] = 11
MAPPING["RSHOULDER"] = 12
MAPPING["LSHOULDER"] = 13
MAPPING["LELBOW"] = 14
MAPPING["LWRIST"] = 15

def nonzeropair(p1,p2):
    if (p1[0] == 0 and p1[1] == 0) or (p2[0] == 0 and p2[1] == 0):
        return False
    else:
        return True

def draw_lines_mpii(img, points, color):
    neck_point = (int(points[MAPPING["NECK"],0]),int(points[MAPPING["NECK"],1]))
    rshoulder_point = (int(points[MAPPING["RSHOULDER"],0]),int(points[MAPPING["RSHOULDER"],1]))
    relbow_point = (int(points[MAPPING["RELBOW"],0]),int(points[MAPPING["RELBOW"],1]))
    rwrist_point = (int(points[MAPPING["RWRIST"],0]),int(points[MAPPING["RWRIST"],1]))
    lshoulder_point = (int(points[MAPPING["LSHOULDER"],0]),int(points[MAPPING["LSHOULDER"],1]))
    lelbow_point = (int(points[MAPPING["LELBOW"],0]),int(points[MAPPING["LELBOW"],1]))
    lwrist_point = (int(points[MAPPING["LWRIST"],0]),int(points[MAPPING["LWRIST"],1]))
    rhip_point = (int(points[MAPPING["RHIP"],0]),int(points[MAPPING["RHIP"],1]))
    rknee_point = (int(points[MAPPING["RKNEE"],0]),int(points[MAPPING["RKNEE"],1]))
    rankle_point = (int(points[MAPPING["RANKLE"],0]),int(points[MAPPING["RANKLE"],1]))
    lhip_point = (int(points[MAPPING["LHIP"],0]),int(points[MAPPING["LHIP"],1]))
    lknee_point = (int(points[MAPPING["LKNEE"],0]),int(points[MAPPING["LKNEE"],1]))
    lankle_point = (int(points[MAPPING["LANKLE"],0]),int(points[MAPPING["LANKLE"],1]))
    top_point = (int(points[MAPPING["TOP"],0]),int(points[MAPPING["TOP"],1]))
    midhip_point = (int(points[MAPPING["MIDHIP"],0]),int(points[MAPPING["MIDHIP"],1]))
    midshoulder_point = (int(points[MAPPING["MIDSHOULDER"],0]),int(points[MAPPING["MIDSHOULDER"],1]))
    # This is always 0 or 1
    # print(midshoulder_point[0]*2 - rshoulder_point[0] - lshoulder_point[0])
    # print(midshoulder_point[1]*2 - rshoulder_point[1] - lshoulder_point[1])

    if nonzeropair(top_point, neck_point) : cv2.line(img, top_point, neck_point, color, 2)
    if nonzeropair(neck_point, midshoulder_point) : cv2.line(img, neck_point, midshoulder_point, color, 2)
    if nonzeropair(midshoulder_point, lshoulder_point) : cv2.line(img, midshoulder_point, lshoulder_point, color, 2)
    if nonzeropair(midshoulder_point, rshoulder_point) : cv2.line(img, midshoulder_point, rshoulder_point, color, 2)
    if nonzeropair(midshoulder_point, midhip_point) : cv2.line(img, midshoulder_point, midhip_point, color, 2)
    if nonzeropair(relbow_point, rshoulder_point) : cv2.line(img, relbow_point, rshoulder_point, color, 2)
    if nonzeropair(relbow_point, rwrist_point) : cv2.line(img, relbow_point, rwrist_point, color, 2)
    if nonzeropair(lelbow_point, lshoulder_point) : cv2.line(img, lelbow_point, lshoulder_point, color, 2)
    if nonzeropair(lelbow_point, lwrist_point) : cv2.line(img, lelbow_point, lwrist_point, color, 2)
    if nonzeropair(midhip_point, lhip_point) : cv2.line(img, midhip_point, lhip_point, color, 2)
    if nonzeropair(midhip_point, rhip_point) : cv2.line(img, midhip_point, rhip_point, color, 2)
    if nonzeropair(rknee_point, rhip_point) : cv2.line(img, rknee_point, rhip_point, color, 2)
    if nonzeropair(lknee_point, lhip_point) : cv2.line(img, lknee_point, lhip_point, color, 2)
    if nonzeropair(rknee_point, rankle_point) : cv2.line(img, rknee_point, rankle_point, color, 2)
    if nonzeropair(lknee_point, lankle_point) : cv2.line(img, lknee_point, lankle_point, color, 2)

    # Keypoint circles and person text
    for i in range(points.shape[0]):
        cv2.circle(img, (int(points[i,0]),int(points[i,1])), 5, (0, 0, 128*points[i,2]), -1)
        cv2.putText(img,str(i), (int(points[i,0]),int(points[i,1])), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0,255,255), 1)
