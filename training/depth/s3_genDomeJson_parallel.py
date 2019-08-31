#!/usr/bin/python

import json
import os
import io
import sys
import numpy as np
import cv2


SMC_BodyJoint_neck       = 0
SMC_BodyJoint_headTop    = 1
SMC_BodyJoint_bodyCenter = 2
SMC_BodyJoint_lShoulder  = 3
SMC_BodyJoint_lElbow     = 4
SMC_BodyJoint_lHand      = 5
SMC_BodyJoint_lHip       = 6
SMC_BodyJoint_lKnee      = 7
SMC_BodyJoint_lFoot      = 8
SMC_BodyJoint_rShoulder   = 9
SMC_BodyJoint_rElbow     = 10
SMC_BodyJoint_rHand      = 11
SMC_BodyJoint_rHip       = 12
SMC_BodyJoint_rKnee      = 13
SMC_BodyJoint_rFoot      = 14
SMC_BodyJoint_lEye       = 15
SMC_BodyJoint_lEar       = 16
SMC_BodyJoint_rEye       = 17
SMC_BodyJoint_rEar       = 18

scale=0.2

lmdb_dataset_path = '../dataset/dome/'
lmdb_depth_path = lmdb_dataset_path+'images/depth'
lmdb_mask_path = lmdb_dataset_path+'images/mask'
basePath = '/media/posefs0c/panoptic/'
#skelPath = '/media/posefs0c/panopticdb/a1/annot_2dskeleton/'
skelPath = '/media/posefs0c/panopticdb/a1/annot_2dskeleton_occlusion/'
bboxPath = '/media/posefs0c/panopticdb/a1/annot_bbox/'


def readpoint(dome_skel2d, dome_visibility, idx):
    if dome_visibility[idx][0] != 1:
        return [0.0, 0.0, 2.0]
    x = dome_skel2d[0, idx]
    y = dome_skel2d[1, idx]
    # To Gines: plz change this hard coding for your application
    if x<0.0 or x>384.0:
        return [0.0, 0.0, 2.0]
    if y<0.0 or y>216.0:
        return [0.0, 0.0, 2.0]
    return [x, y, 1.0]


def undistortpoint(points, cam):
    points = points.transpose()[:, np.newaxis, :]
    points = cv2.undistortPoints(points, cam['K'], cam['distCoef'])
    points = np.transpose(points, (2,0,1))[:,:,0]
    points = np.concatenate((points, np.ones((1,points.shape[1]))))
    points = np.dot(cam['K'],points)
    return points[:2,:]


def dome2coco(dome_skel2d):
    dome_skel2d = np.array(dome_skel2d).transpose()*scale

    openpose_skel2d=[]
    
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_headTop))    #OPENPOSE_Nose      = 0 
    #openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_neck))       #OPENPOSE_Neck      = 1 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rShoulder))  #OPENPOSE_RShoulder = 2 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rElbow))     #OPENPOSE_RElbow    = 3 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rHand))      #OPENPOSE_RWrist    = 4 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lShoulder))  #OPENPOSE_LShoulder = 5 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lElbow))     #OPENPOSE_LElbow    = 6 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lHand))      #OPENPOSE_LWrist    = 7 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rHip))       #OPENPOSE_RHip      = 8 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rKnee))      #OPENPOSE_RKnee     = 9 
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rFoot))      #OPENPOSE_RAnkle    = 10
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lHip))       #OPENPOSE_LHip      = 11
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lKnee))      #OPENPOSE_LKnee     = 12
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lFoot))      #OPENPOSE_LAnkle    = 13
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rEye))       #OPENPOSE_REye      = 14
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lEye))       #OPENPOSE_LEye      = 15
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_rEar))       #OPENPOSE_REar      = 16
    openpose_skel2d.append(readpoint(dome_skel2d, SMC_BodyJoint_lEar))       #OPENPOSE_LEar      = 17
                                                       #OPENPOSE_Bkg       = 18
    
    return openpose_skel2d


def dome2coco_undistortion(dome_skel2d, dome_visibility, cam):
    dome_skel2d = np.array(dome_skel2d).transpose()

    dome_skel2d = undistortpoint(dome_skel2d, cam)*scale
    
    openpose_skel2d=[]
    
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_headTop))    #OPENPOSE_Nose      = 0 
    #openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_neck))       #OPENPOSE_Neck      = 1 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rShoulder))  #OPENPOSE_RShoulder = 2 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rElbow))     #OPENPOSE_RElbow    = 3 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rHand))      #OPENPOSE_RWrist    = 4 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lShoulder))  #OPENPOSE_LShoulder = 5 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lElbow))     #OPENPOSE_LElbow    = 6 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lHand))      #OPENPOSE_LWrist    = 7 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rHip))       #OPENPOSE_RHip      = 8 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rKnee))      #OPENPOSE_RKnee     = 9 
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rFoot))      #OPENPOSE_RAnkle    = 10
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lHip))       #OPENPOSE_LHip      = 11
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lKnee))      #OPENPOSE_LKnee     = 12
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lFoot))      #OPENPOSE_LAnkle    = 13
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rEye))       #OPENPOSE_REye      = 14
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lEye))       #OPENPOSE_LEye      = 15
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_rEar))       #OPENPOSE_REar      = 16
    openpose_skel2d.append(readpoint(dome_skel2d, dome_visibility, SMC_BodyJoint_lEar))       #OPENPOSE_LEar      = 17
                                                                  #OPENPOSE_Bkg       = 18

        
    return openpose_skel2d




seqNames = []
dates = ['170221', '170224', '170228', '170404', '170407']
for date in dates:
    for t in ['1', '2', '3']:
        for ch in ['a', 'b', 'm']:
            rootFolderPath = '/media/posefs0c/panoptic/{}_haggling_{}{}/'.format(date, ch, t)
            if os.path.isdir(rootFolderPath):    
                seqNames.append('{}_haggling_{}{}'.format(date, ch, t))

for camIdx in range(31):
    json_path = '../dataset/dome/dome_{0:02d}.json'.format(camIdx) 
    if os.path.isfile(json_path):
        print camIdx, 'locked'
        continue
    else:
        print 'generating json for', camIdx
        with open(json_path, 'w+') as f:
            f.write('')
    datas = []       
    count_in_json = 0
    for seqName in seqNames:
        
        with open(basePath+'{0}/calibration_{0}.json'.format(seqName)) as cfile:
            calib = json.load(cfile)

        # Cameras are identified by a tuple of (panel#,node#)
        cameras = {(cam['panel'],cam['node']):cam for cam in calib['cameras']}

        # Convert data into numpy arrays for convenience
        for k,cam in cameras.iteritems():    
            cam['K'] = np.matrix(cam['K'])
            cam['distCoef'] = np.array(cam['distCoef'])
            cam['R'] = np.matrix(cam['R'])
            cam['t'] = np.array(cam['t']).reshape((3,1))
            
        cam = cameras[(0,camIdx)]
        
        panelIdx = 0 
        print 'reading', seqName, camIdx
        for fIdx in range(3000, 12000, 30):
            img_path = '{3}/hdImgs_undistort/{0:02d}_{1:02d}/{0:02d}_{1:02d}_{2:08d}.jpg'.format(panelIdx, camIdx, fIdx, seqName)
            depth_path = '{3}/hdDepth_dense/{0:02d}_{1:02d}/{0:02d}_{1:02d}_{2:08d}.png'.format(panelIdx, camIdx, fIdx, seqName)

            if not os.path.isfile(basePath+img_path):
                #print 'RGB image not exist:', img_paths
                break  
            if not os.path.isfile(basePath+depth_path):
                #print 'Depth image not exist:', depth_path
                continue  
            
            skel_2d_path = skelPath+'{3}/{2:08d}/body2DScene_{0:02d}_{1:02d}_{2:08d}.json'\
                .format(panelIdx, camIdx, fIdx, seqName)
            
            if not os.path.isfile(skel_2d_path):
                #print 'Json file not exist:', skel_2d_path
                continue 
            
            with open(skel_2d_path) as sfile:
                skel_2ds = json.load(sfile)
                
            bodies = {}
            for skel_2d in skel_2ds:
                bodies[skel_2d['id']]=dome2coco_undistortion(skel_2d['pose2d'], skel_2d['visibility'], cam)
            
            
            bbox_path = bboxPath+'{3}/{2:08d}/bbox_{0:02d}_{1:02d}_{2:08d}.json'\
                .format(panelIdx, camIdx, fIdx, seqName)
            
            if not os.path.isfile(bbox_path):
                #print 'Json file not exist:', bbox_path
                continue  
            
            with open(bbox_path) as bfile:
                bboxs = json.load(bfile)
            if len(bboxs)==0:
                continue
            if len(bboxs)>1:
                bboxs = [bbox[0] for bbox in bboxs]
            
            for bbox in bboxs:
                bid = bbox['id']
                if bid in bodies:
                    data = {}

                    data['dataset'] = 'domedb'
                    data['isValidation'] = 0
                    data['img_path'] = img_path
                    data['depth_path'] = depth_path

                    data['seqName'] = seqName
                    data['fIdx'] = fIdx
                    data['panelIdx'] = panelIdx
                    data['camIdx'] = camIdx
                    
                    data['depth_enabled'] = 255

                    data['img_width'] = 384
                    data['img_height'] = 216
                    data['scale_provided'] = 1.0
                    data['bbox'] = bbox['bbox']
                    data['confidence'] = bbox['scores']
                    
                    center = np.array([bbox['bbox'][0]+bbox['bbox'][2]/2, bbox['bbox'][1]+bbox['bbox'][3]/2])[:, None]
                    center = undistortpoint(center, cam)
                    data['objpos'] = (center.transpose()*scale).tolist()[0]

                    data['joint_self'] = bodies[bid]
                    
                    
                    data['objpos_other'] = []
                    data['joint_others'] = []
                    data['scale_provided_other'] = []
                    
                    
                    for otherbbox in bboxs:
                        otherbid = otherbbox['id']
                        if otherbid != bid:
                            center = np.array([otherbbox['bbox'][0]+otherbbox['bbox'][2]/2, \
                                               otherbbox['bbox'][1]+otherbbox['bbox'][3]/2])[:, None]
                            center = undistortpoint(center, cam)
                            data['objpos_other'].append((center.transpose()*scale).tolist()[0])
                            data['joint_others'].append(bodies[otherbid])
                            data['scale_provided_other'].append(1.0)


                    data['annolist_index'] = count_in_json
                    count_in_json = count_in_json+1
                    data['people_index'] = bid
                    data['numOtherPeople']= len(data['objpos_other'])
                    
                    datas.append(data)
            
    
    #write json
    with open(json_path, 'w+') as f:
        f.write(json.dumps({"root":datas}))
    print json_path, 'saved'    
    