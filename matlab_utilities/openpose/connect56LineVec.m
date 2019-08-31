function [subset, candidates] = connect56LineVec(image, heatMaps, param, visualize)
    if nargin < 4
        visualize = 0;
    end
% clc
    %% NMS (Non-Maximum Suppression) to find joint candidates
    numberBodyParts = 18;
    [candidates, candidatesCell] = nms(heatMaps, param, numberBodyParts);

    %% Greedy algorithm
    height = size(heatMaps,1)/2;
    subsetSize = numberBodyParts + 2;
    % find connection in the specified sequence, center 29 is in the position 15
    % +1 from C++ to Matlab
    bodyPartPairs = [1,2; 1,5; 2,3; 3,4; 5,6; 6,7; 1,8; 8,9;   9,10; 1,11; 11,12; ...
                     12,13; 1,0; 0,14; 14,16; 0,15; 15,17; 2,16; 5,17]+1;
%     bodyPartPairs = [2 3; 2 6; 3 4; 4 5; 6 7; 7 8; 2 9; 9 10; 10 11; 2 12; 12 13; ...
%                      13 14; 2 1; 1 15; 15 17; 1 16; 16 18; 3 17; 6 18];
    % the middle joints heatmap correpondence
    % +1 from C++ to Matlab
    % -1 to remove background
    mapIdx = [31,32; 39,40; 33,34; 35,36; 41,42; 43,44; 19,20; 21,22; 23,24; ...
              25,26; 27,28; 29,30; 47,48; 49,50; 53,54; 51,52; 55,56; 37,38; 45,46]+1-1;
    % last number in each row is the total parts number of that person
    % the second last number in each row is the score of the overall configuration
    subset = [];
    % find the parts connection and cluster them into different subset
    numberBodyPartPairs = size(mapIdx,1);
    % For each PAF
    for pairIndex = 1:numberBodyPartPairs
        candidateA = candidatesCell{bodyPartPairs(pairIndex,1)};
        candidateB = candidatesCell{bodyPartPairs(pairIndex,2)};
        nA = size(candidateA,1);
        nB = size(candidateB,1);
        indexA = bodyPartPairs(pairIndex,1);
        indexB = bodyPartPairs(pairIndex,2);

        % Add parts into the subset in special case
        if (nA == 0 || nB == 0)
            if nA == 0 % nB = 0 or nB ~= 0
                for i = 1:nB
                    num = false;
                    for j = 1:size(subset,1)
                        if subset(j, indexB) == candidateB(i,4)
                            num = true;
                            break;
                        end
                    end
                    % if find no partB in the subset, create a new subset
                    if ~num
                        subset = [subset;
                                  zeros(1,subsetSize)];
                        subset(end, indexB) = candidateB(i,4);
                        subset(end, end) = 1;
                        subset(end, end-1) = candidateB(i,3);
                    end
                end
            else %if nA ~= 0, nB = 0
                for i = 1:nA
                    num = false;
                    for j = 1:size(subset,1)
                        if subset(j, indexA) == candidateA(i,4)
                            num = true;
                            break;
                        end
                    end
                    % if find no partA in the subset, create a new subset
                    if ~num
                        subset = [subset;
                                  zeros(1,subsetSize)];
                        subset(end, indexA) = candidateA(i,4);
                        subset(end, end) = 1;
                        subset(end, end-1) = candidateA(i,3);
                    end
                end
            end
        else
            temp = [];
            score_mid = heatMaps(:,:,mapIdx(pairIndex,:));
            for i = 1:nA
                for j = 1:nB
                    vec = candidateB(j,1:2) - candidateA(i,1:2);
                    normVec = sqrt(vec(1)^2+vec(2)^2);
                    vec = vec/normVec;

                    height_n = height; % Somehow it does not affect final accuracy, but affects score...
%                     if k > 13 && k < 18
%                         height_n = height/2;
%                     elseif k== 18 || k == 19
%                         height_n = height/1.25;
%                     else
%                         height_n = height;
%                     end

                    numInter = 10;
                    p_sum = 0;
                    p_count = 0;
                    mX = round(linspace(candidateA(i,1), candidateB(j,1), numInter));
                    mY = round(linspace(candidateA(i,2), candidateB(j,2), numInter));
                    for lm = 1:numInter
                        mapXY = squeeze(score_mid(mY(lm), mX(lm), 1:2));
                        score = vec(2)*mapXY(2) + vec(1)*mapXY(1);
                        if score > param.connectInterThreshold
                            p_sum = p_sum + score;
                            p_count = p_count +1;
                        end
                    end

                    suc_ratio = p_count/numInter;
% height_n, normVec, min(height_n/normVec-1,0)
                    mid_score = p_sum/p_count + min(height_n/normVec-1,0);
%                     mid_score = p_sum/p_count;

                    if mid_score > 0 && suc_ratio > param.connectMinAboveThreshold
                        score = mid_score;
                        % parts score + connection score
                        temp = [temp;
                                i j score];
                    end
                end
            end

            %% select the top num connection, assuming that each part occur only once
            % sort rows in descending order
            if size(temp,1) > 0
                temp = sortrows(temp,-3); %based on connection score
            end
            % set the connection number as the samller parts set number
            connectionK = [];
            minAB = min(nA, nB);
            occurA = zeros(1, nA);
            occurB = zeros(1, nB);
            counter = 0;
            for row = 1:size(temp,1)
                x = temp(row,1);
                y = temp(row,2);
                score = temp(row,3);
                if occurA(x) == 0 && occurB(y) == 0 %&& score> (1+thre)
                    connectionK = [connectionK;
                                   candidateA(x,4) candidateB(y,4) score];
                    counter = counter+1;
                    if counter == minAB
                        break;
                    end
                    occurA(x) = 1;
                    occurB(y) = 1;
                end
            end

            %% Cluster all the body part candidates into subset based on the part connection
            if size(connectionK,1) > 0
                % initialize first body part connection 15&16
                if pairIndex==1
                    subset = zeros(size(connectionK,1),subsetSize); %last number in each row is the parts number of that person
                    for i = 1:size(connectionK,1)
                        score = connectionK(i,3);
                        subset(i, bodyPartPairs(1, 1:2)) = connectionK(i,1:2);
                        subset(i, end) = 2;
                        % add the score of parts and the connection
                        subset(i, end-1) = sum(candidates(connectionK(i,1:2),3)) + score;
                    end
                % Add ears connections (in case person is looking to opposite direction to camera)
                elseif pairIndex==18 || pairIndex==19
                    indexA = bodyPartPairs(pairIndex,1);
                    indexB = bodyPartPairs(pairIndex,2);
                    partA = connectionK(:,1);
                    partB = connectionK(:,2);
                    for i = 1:size(connectionK,1)
                        for j = 1:size(subset,1)
                            if subset(j, indexA) == partA(i) && subset(j, indexB) == 0
                                subset(j, indexB) = partB(i);
                            elseif subset(j, indexB) == partB(i) && subset(j, indexA) == 0
                                subset(j, indexA) = partA(i);
                            end
                        end
                    end
                    continue;
                else
                    % A is already in the subset, find its connection B
                    indexA = bodyPartPairs(pairIndex,1);
                    indexB = bodyPartPairs(pairIndex,2);
                    partA = connectionK(:,1);
                    partB = connectionK(:,2);
                    for i = 1:size(connectionK,1)
                        num = 0;
                        for j = 1:size(subset,1)
                            if subset(j, indexA) == partA(i)
                                subset(j, indexB) = partB(i);
                                num = num+1;
                                subset(j, end) = subset(j,end)+1;
                                subset(j, end-1) = subset(j, end-1) + candidates(partB(i),3) + connectionK(i,3);
                            end
                        end
                        % if find no partA in the subset, create a new subset
                        if num==0
                            subset = [subset;
                                      zeros(1,subsetSize)];
                            subset(end, indexA) = partA(i);
                            subset(end, indexB) = partB(i);
                            subset(end, end) = 2;
                            subset(end, end-1) = sum(candidates(connectionK(i,1:2),3)) + connectionK(i,3);
                        end
                    end
                end
            end
        end
    end

    %% Delete people with very few body parts
    deleIdx = [];
    for i=1:size(subset,1)
        if (subset(i,end) < param.connectMinSubsetCnt) ...
                || (subset(i,end-1)/subset(i,end) < param.connectMinSubsetScore)
            deleIdx = [deleIdx;
                       i];
        end
    end
    subset(deleIdx,:) = [];

    %% Visualize image + keypoints
    colors = hsv(length(bodyPartPairs));
    facealpha = 0.6;
    stickwidth = 4;
    if visualize == 1
        joint_color = [255, 0, 0;  255, 85, 0;  255, 170, 0; ...
                       255, 255, 0;  170, 255, 0;   85, 255, 0; ...
                       0, 255, 0;  0, 255, 85;  0, 255, 170; ...
                       0, 255, 255;  0, 170, 255;  0, 85, 255; ...
                       0, 0, 255;   85, 0, 255;  170, 0, 255; ...
                       255, 0, 255;  255, 0, 170;  255, 0, 85];
        % Circles in body parts
        for subsetId = 1:size(subset,1)
            for i = 1:numberBodyParts
                index = subset(subsetId,i);
                if index == 0
                    continue;
                end
                X = candidates(index,1);
                Y = candidates(index,2);
                image = insertShape(image, 'FilledCircle', [X Y 5], 'Color', joint_color(i,:));
            end
        end
        imshow(image), hold on;

        % Ellipses between body parts
        for i = 1:(numberBodyPartPairs-2) % Remove ear-shoulder connection
        % for i = 1:numberBodyPartPairs
            for subsetId = 1:size(subset,1)
                index = subset(subsetId,bodyPartPairs(i,1:2));
                if sum(index==0) > 0
                    continue;
                end
                X = candidates(index,1);
                Y = candidates(index,2);
                if ~sum(isnan(X))
                    mX = mean(X);
                    mY = mean(Y);
                    [~,~,V] = svd(cov([X-mX Y-mY]));
                    v = V(2,:);
                    point = [X Y];
                    points = [point;
                              point + stickwidth*repmat(v,2,1);
                              point - stickwidth*repmat(v,2,1)];
                    A = cov([points(:,1)-mX points(:,2)-mY]);
                    if any(X)
                        filledEllipse(A,[mX mY],colors(i,:),facealpha);
                    end
                end
            end
            %export_fig(['video/connect_' num2str(i) '.png']);
        end
        hold off
    end
end
