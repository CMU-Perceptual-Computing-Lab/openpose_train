function predictions = getPoseKeypoints(imageFilePaths, numberGpus, numberGpuStart)
    %% Check numberGpus
    if ~exist('numberGpus', 'var')
        numberGpus = 1;
    end
    if ~exist('numberGpuStart', 'var')
        numberGpuStart = 0;
    end
    %% Load Caffe and model
    OPtoCOCO = [1,NaN, 7,9,11, 6,8,10, 13,15,17, 12,14,16, 3,2,5,4];
    param = config();
    caffe.reset_all();
    model = param.model;
    deployFile = model.deployFile;
    caffemodel = model.caffemodel;

    % Start parpool if not started
    disableWarnings = false;
    startParallel(disableWarnings);

    %% Process images
    % Iterate validation images
    fprintf('\nProcessing images...\n');
% imageFilePaths = imageFilePaths(1:201); % For debugging
    numberImages = numel(imageFilePaths);
    logEveryXFrames = numberGpus * round(max(1, round(numberImages / 50)) / numberGpus);
    visualize = 0;
    predictions = cell(numberGpus, 1);
    for predictionId = 1:numel(predictions)
        clear predictionsStruct;
        predictionsStruct(numberImages) = struct('annorect', [], 'candidates', []);
        predictions{predictionId} = predictionsStruct;
    end
    batchSize = ceil(numberImages/numberGpus);
%     for coreId = 0:numberGpus-1 % For debugging
    parfor coreId = 0:numberGpus-1
        caffe.set_mode_gpu();
        caffe.set_device(coreId+numberGpuStart);
        net = caffe.Net(deployFile, caffemodel, 'test');
        for imageId = (1+coreId*batchSize):((coreId+1)*batchSize)
            if imageId <= numberImages
                % Display progress
                progressDisplay(imageId*numberGpus, logEveryXFrames, numberImages);
                % Processing
                image = imread(imageFilePaths{imageId});
                predictions{coreId+1}(imageId) = parforFunction(image, param, net, visualize, OPtoCOCO);
            end
        end
    end
    fprintf('\nImages processed!\n\n');
    % All predictions into single struct
    fprintf('\nAll predictions into single struct...\n');
    for coreId = 1:numberGpus-1
        for imageId = (1+coreId*batchSize):((coreId+1)*batchSize)
            if imageId <= numberImages
                predictions{1}(imageId) = predictions{coreId+1}(imageId);
            end
        end
    end
    predictions = predictions{1};
    fprintf('All predictions into single struct!\n\n');

    % Remove parallel pool to clean GPU memory
    poolobj = gcp('nocreate');
    delete(poolobj);
end

function prediction = parforFunction(image, param, net, visualize, OPtoCOCO)
    prediction = struct('annorect', [], 'candidates', []);
    % Processing
    heatMaps = applyModel(image, param, net);
    [subset, candidates] = connect56LineVec(image, heatMaps, param, visualize);
    pointCounter = 0;
    for ridxPred = 1:size(subset,1)
        point = struct([]);
        partCounter = 0;
        for part = 1:param.model.np
            if part ~= 2 % 2 is neck (not in COCO)
                index = subset(ridxPred, part);
                if index > 0
                    partCounter = partCounter +1;
                    point(partCounter).x = candidates(index,1);
                    point(partCounter).y = candidates(index,2);
                    point(partCounter).score = candidates(index,3);
                    point(partCounter).id = OPtoCOCO(part);
                end
            end
        end
        pointCounter = pointCounter + 1;
        prediction.annorect(pointCounter).annopoints.point = point;
        % prediction.annorect(pointCounter).annopoints.score = subset(ridxPred,end-1)/subset(ridxPred,end);
        prediction.annorect(pointCounter).annopoints.score = subset(ridxPred, end-1);
    end
end
