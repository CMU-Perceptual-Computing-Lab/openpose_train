function avgPrecAndRecall = getPrecisionAndRecallUpToX(resFiles, cocoGt, type, lastImageNumber)
    numberFiles = numel(resFiles);
    avgPrec = zeros(numberFiles, 1);
    avgRecall = zeros(numberFiles, 1);
    % Start parpool if not started
    startParallel();
    parfor fileIndex=1:numel(resFiles)
        %% initialize COCO detections api
        resFile = resFiles{fileIndex};
        disp(' ')
        disp(['Results for: ', resFile])
        try
            cocoDt=cocoGt.loadRes(resFile);
            % This should read only the used indexes (problem: only where people
            % located)
            % imgIds = unique([cocoDt.data.annotations.image_id])';
            % Use next line instead (it can be don before the for loop) if I want to
            % do sequential image reading
            imgIds = sort(cocoGt.getImgIds());
            if lastImageNumber ~= -1
                imgIds = imgIds(1:find(imgIds==lastImageNumber));
            end

            %% run COCO evaluation code (see CocoEval.m)
            cocoEval=CocoEval(cocoGt,cocoDt,type);
            cocoEval.params.imgIds=imgIds;
            cocoEval.evaluate();
            cocoEval.accumulate();
            [avgPrec(fileIndex), avgRecall(fileIndex)] = cocoEval.summarize();
        catch exception
            disp('Exception ocurred in avgPrecAndRecall = getPrecisionAndRecall(resFiles, cocoGt, type, lastImageNumber)');
            disp(exception);
            avgPrec(fileIndex) = 0;
            avgRecall(fileIndex) = 0;
        end
    end
    avgPrecAndRecall = {avgPrec, avgRecall};
end
