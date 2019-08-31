function [candidates, candidatesCell] = nms(heatMaps, param, numberBodyParts)
    %% NMS (Non-Maximum Suppression) to find joint candidates
    count = 0;
    candidates = [];
    candidatesCell = cell(numberBodyParts, 1);
    for bodyPart = 1:numberBodyParts
        [Y,X,score] = findPeaks(heatMaps(:,:,bodyPart), param.NMSThreshold);
        counter = (1:numel(Y))' + count;
        candidatesCell{bodyPart} = [X, Y, score, counter];
        candidates = [candidates;
                      X, Y, score, bodyPart*ones([numel(Y),1])]; % Last part for visual debugging
        try
            count = counter(end);
        catch
        end
    end
end
