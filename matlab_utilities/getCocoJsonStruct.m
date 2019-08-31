function cocoJsonStruct = getCocoJsonStruct(predictions, imageIds)
    %% Convert to COCO JSON format
    fprintf('Converting to COCO JSON format...\n');
    cocoJsonStruct = struct('image_id', [], 'category_id', [], 'keypoints', [], 'score', []);
    count = 1;
    numberKeypoints = 17;
    for imageId = 1:length(predictions)
        for person = 1:length(predictions(imageId).annorect)
            cocoJsonStruct(count).image_id = imageIds(imageId);
            cocoJsonStruct(count).category_id = 1;
            cocoJsonStruct(count).keypoints = zeros(3, numberKeypoints);
            for p = 1:length(predictions(imageId).annorect(person).annopoints.point)
                point = predictions(imageId).annorect(person).annopoints.point(p);
                cocoJsonStruct(count).keypoints(1, point.id) = point.x - 0.5;
                cocoJsonStruct(count).keypoints(2, point.id) = point.y - 0.5;
                cocoJsonStruct(count).keypoints(3, point.id) = 1;
            end
            cocoJsonStruct(count).keypoints = reshape(cocoJsonStruct(count).keypoints, [1 3*numberKeypoints]);
            cocoJsonStruct(count).score = predictions(imageId).annorect(person).annopoints.score ...
                                        * length(predictions(imageId).annorect(person).annopoints.point);
            count = count + 1;
        end
    end
    fprintf('Converted to COCO JSON format!\n\n');
end
