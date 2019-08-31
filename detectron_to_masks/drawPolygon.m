function drawPolygon(segmnt, col, transparency)

if nargin < 3
    transparency = .3;
end
if nargin < 2 
    col = [rand rand rand];
end

if ~iscell(segmnt)
    h=fill(segmnt(1:2:end), segmnt(2:2:end), col, 'edgecolor', col);
    set(h,'facealpha',transparency)
else
    for k=1:size(segmnt,2)
        polygon = segmnt{k};
        h=fill(polygon(1:2:end), polygon(2:2:end), col, 'edgecolor', col);
        set(h,'facealpha',transparency)
    end
end

end