function [X,Y,score] = findPeaks(map, threshold)
    map(map < threshold) = 0;

    mapAugmented = -1*ones(size(map)+2);
    mapAugmented1 = mapAugmented;
    mapAugmented2 = mapAugmented;
    mapAugmented3 = mapAugmented;
    mapAugmented4 = mapAugmented;

    mapAugmented(2:end-1, 2:end-1) = map;
    mapAugmented1(2:end-1, 1:end-2) = map;
    mapAugmented2(2:end-1, 3:end) = map;
    mapAugmented3(1:end-2, 2:end-1) = map;
    mapAugmented4(3:end, 2:end-1) = map;

    peakMap = (mapAugmented > mapAugmented1) ...
            & (mapAugmented > mapAugmented2) ...
            & (mapAugmented > mapAugmented3) ...
            & (mapAugmented > mapAugmented4);
    peakMap = peakMap(2:end-1, 2:end-1);
    [X,Y] = find(peakMap);
    score = zeros(length(X),1);
    for i = 1:length(X)
        score(i) = map(X(i),Y(i));
    end

    if ~isempty(X)
        deleIdx = [];
        flag = ones(1, length(X));
        for i = 1:length(X)
            if flag(i)>0
                for j = (i+1):length(X)
                    if norm([X(i)-X(j),Y(i)-Y(j)]) <= 6
                        flag(j) = 0;
                        deleIdx = [deleIdx;j];
                    end
                end
            end
        end
        X(deleIdx,:) = [];
        Y(deleIdx,:) = [];
        score(deleIdx,:) = [];
    end

    % Accurate peak location: considered neighboors
    xAcc = zeros(size(X));
    yAcc = zeros(size(Y));
    scoreAcc = zeros(size(diag(map(X, Y))));
    if numel(scoreAcc) > 0
        for dx = -3:3
            for dy = -3:3
                newX = X+dx;
                newY = Y+dy;
                newX = min(max(newX, 1), size(map, 1));
                newY = min(max(newY, 1), size(map, 2));
                score = diag(map(newX, newY)); % 20x slower: map(sub2ind(size(map), newX, newY))
                xAcc = xAcc + newX.*score;
                yAcc = yAcc + newY.*score;
                scoreAcc = scoreAcc + score;
            end
        end
        X = xAcc ./ scoreAcc;
        Y = yAcc ./ scoreAcc;
    end
end
