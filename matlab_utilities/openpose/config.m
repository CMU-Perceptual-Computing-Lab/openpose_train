function param = config()
    loadConfigParameters

    % GPU device number (doesn't matter for CPU mode)
    gpuDeviceNumber = 0;

    % COCO parameters
%     param.scale_search = [0.5 1 1.5 2]; % 1
    param.scale_search = 1
    param.NMSThreshold = 0.1;
    param.connectInterThreshold = 0.05;
    param.connectMinSubsetCnt = 3;
    param.connectMinSubsetScore = 0.2;
    param.connectMinAboveThreshold = 0.8;

    param.model.caffemodel = sCocoModel;
    param.model.deployFile = sCocoProtoTxt;
    param.model.description = 'COCO Pose56 Two-level Linevec';
    param.model.boxsize = sImageScale;
    param.model.padValue = 0; % 128 gives -0.3 mAP (4 scales)
    param.model.np = sNumberKeyPoints;
    param.model.part_str = {'nose', 'neck', 'Rsho', 'Relb', 'Rwri', ...
                            'Lsho', 'Lelb', 'Lwri', ...
                            'Rhip', 'Rkne', 'Rank', ...
                            'Lhip', 'Lkne', 'Lank', ...
                            'Leye', 'Reye', 'Lear', 'Rear', 'pt19'};

    % Set and init MatCaffe
    addpath(sCaffePath);
    caffe.set_mode_gpu();
    caffe.set_device(gpuDeviceNumber);
    caffe.reset_all();
end
