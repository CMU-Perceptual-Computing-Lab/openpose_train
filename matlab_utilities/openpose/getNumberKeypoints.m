function numberKeypoints = getNumberKeypoints(keypoints)
    %% Estimate person bounding box
    % From 1-D vector to #keypoints x 3 (x,y,score)
    if size(keypoints,1) == numel(keypoints) || size(keypoints,2) == numel(keypoints)
        keypoints = reshape(keypoints, 3, [])';
    end
    % Remove non detected parts
    keypoints(keypoints(:,3)==0,:) = [];
    % Get numberKeypoints
    numberKeypoints = size(keypoints,1);
end
