function segmentation_out = getDetectronSegmentation(det_output, j, im_width, im_height)

segmentation = []; segmentation_out = [];

for k = 1:size(det_output.contours{j},2)
    contour = squeeze(det_output.contours{j}{k});
    contour = fixEmptyContourAndTranspose(contour, det_output.boxes(j,1:4));
    contour = clipContour(contour, im_width, im_height);
    segmentation{k} = contour(:); clear contour;
end
segmentation_out{1} = mergeAndSimplifyContour(det_output, j, segmentation);

end

function contour = fixEmptyContourAndTranspose(contour, bbox)
if isempty(contour) || numel(contour(:)) <= 2
    bbox(3:4) = bbox(1:2)+bbox(3:4);
    contour = [bbox(1) bbox(2); bbox(3) bbox(2); bbox(3) bbox(4); bbox(1) bbox(4)];
end
contour = round(contour');
end

function contour = clipContour(contour, im_width, im_height)
contour(1,:) = max(0, min(im_width-1, contour(1,:)));
contour(2,:) = max(0, min(im_height-1, contour(2,:)));
end

function contour = mergeAndSimplifyContour(det_output, j, segmentation)
% j
%
% if j==3
%     a=[];
% end
segment_lengths = cell2mat(arrayfun(@(x) length(x{1}), segmentation, 'UniformOutput', false));
[~, ind_sort] = sort(segment_lengths, 'descend');
segmentation = segmentation(ind_sort);

xpts = segmentation{1}(1:2:end); ypts = segmentation{1}(2:2:end);
[xpts, ypts] = mergePolygons(xpts, ypts, [], []);
if size(segmentation,2) > 1
    for i=2:size(segmentation,2)
        [xpts, ypts] = mergePolygons(xpts, ypts, segmentation{i}(1:2:end), segmentation{i}(2:2:end));
    end
end

if ~isempty(xpts)
    contour=[xpts, ypts];
else
    bbox = det_output.boxes(j,1:4);
    bbox(3:4) = bbox(1:2)+bbox(3:4);
    contour = [bbox(1) bbox(2); bbox(3) bbox(2); bbox(3) bbox(4); bbox(1) bbox(4)];
end
contour = int32(contour)'; contour = contour(:);
end

function [xpts, ypts] = mergePolygons(x1, y1, x2, y2)
[xpts, ypts] = polyclip(x1, y1, x2, y2, 'uni');
if numel(xpts) > 1 % discard smaller contour if disjoint; greedy approach
    num_poly = [arrayfun(@(x) length(x{1}), xpts, 'UniformOutput', false)];
    [~, ind_largest] = max(cell2mat(num_poly));
    xpts = xpts(ind_largest); ypts = ypts(ind_largest);
%     fprintf('multi-polygon case!'); pause;
end
xpts = cell2mat(xpts); ypts = cell2mat(ypts);
end
