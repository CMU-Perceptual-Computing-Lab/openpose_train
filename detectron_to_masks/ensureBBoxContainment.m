function bbox = ensureBBoxContainment(bbox1, bbox2, im_dim)
    b1_x1 = bbox1(1); b1_y1 = bbox1(2);
    b1_x2 = bbox1(1) + bbox1(3);
    b1_y2 = bbox1(2) + bbox1(4);
    
    b2_x1 = bbox2(1); b2_y1 = bbox2(2);
    b2_x2 = bbox2(1) + bbox2(3);
    b2_y2 = bbox2(2) + bbox2(4);
    
    bbox_x1 = max(0, min(b1_x1, b2_x1));
    bbox_y1 = max(0, min(b1_y1, b2_y1));
    bbox_x2 = min(im_dim(1), max(b1_x2, b2_x2));
    bbox_y2 = min(im_dim(2), max(b1_y2, b2_y2));
    
    bbox = [bbox_x1 bbox_y1 bbox_x2-bbox_x1 bbox_y2-bbox_y1];
end