function rectangle = getKeypointsRectangle(keypoints)
    %% Estimate person bounding box
    % From 1-D vector to #keypoints x 3 (x,y,score)
    if size(keypoints,1) == numel(keypoints) || size(keypoints,2) == numel(keypoints)
        keypoints = reshape(keypoints, 3, [])';
    end
    % Remove non detected parts
    keypoints(keypoints(:,3)==0,:) = [];
    % Get min/max x/y
    minX = min(keypoints(:,1));
    maxX = max(keypoints(:,1));
    minY = min(keypoints(:,2));
    maxY = max(keypoints(:,2));
    % Get rectangle
    rectangle = [minX, minY, maxX-minX+1, maxY-minY+1];
end
