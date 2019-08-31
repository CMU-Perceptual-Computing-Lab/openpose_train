function iou = getIoU(rectangleA, rectangleB)
    %% Estimating IoU (Intersection over Union)
    % From [x, y, width, height ] to [xMin, yMin, xMax, yMax]
    rectangleA = [rectangleA(1:2), rectangleA(1:2) + rectangleA(3:4) - 1];
    rectangleB = [rectangleB(1:2), rectangleB(1:2) + rectangleB(3:4) - 1];
	% Intersection rectangle
	xMin = max(rectangleA(1), rectangleB(1));
	yMin = max(rectangleA(2), rectangleB(2));
	xMax = min(rectangleA(3), rectangleB(3));
	yMax = min(rectangleA(4), rectangleB(4));
    % If no intersection at all
    if xMin >= xMax || yMin >= yMax
        iou = 0;
    % If some intersection
    else
        % Area of intersection
        intersectionArea = (xMax - xMin + 1) * (yMax - yMin + 1);
        % Area of both rectangles
        boxAArea = (rectangleA(3) - rectangleA(1) + 1) * (rectangleA(4) - rectangleA(2) + 1);
        boxBArea = (rectangleB(3) - rectangleB(1) + 1) * (rectangleB(4) - rectangleB(2) + 1);
        % IoU = area overlap / area union
        iou = intersectionArea / (boxAArea + boxBArea - intersectionArea);
    end
end
