function det_output = fixDetContours(det_output)

out_contours = [];

if iscell(det_output.contours)
    if numel(det_output.contours) == numel(det_output.classes) % normal case
        for i=1:numel(det_output.contours)
            if iscell(det_output.contours{i})
                for j = 1:numel(det_output.contours{i})
                    out = squeeze(det_output.contours{i}{j});
                    out_contours{i}{j} = checkNDarray(out);
                end
            else
                out = squeeze(det_output.contours{i});
                out_contours{i}{1} = checkNDarray(out);
            end
        end
        
    elseif numel(det_output.contours) == 1 && numel(det_output.classes) > 1 % abnormal case
        error('unable to assign multiple objects to single contour...\n');
    elseif numel(det_output.contours) > 1 && numel(det_output.classes) == 1 % abnormal case
        for i=1:numel(det_output.contours)
            out = squeeze(det_output.contours{i});
            out_contours{1}{i} = checkNDarray(out);
        end
    end
else 
    contour = squeeze(det_output.contours); % abnormal cases below
    if isvector(contour)
        error('unable to handle vectors...\n');
    elseif ismatrix(contour) 
        if ~any(size(contour)==2) 
            error('weird matrix...\n');
        end
        if numel(det_output.classes) ~= 1 
            error('# classes mismatches # contours...\n')
        end
        out = contour;
        out_contours{1}{1} = checkNDarray(out);
    else
        if numel(det_output.classes) ~= size(contour,1)
            error('unable to squeeze nd-array...\n');
        else
            for i = 1:numel(det_output.classes)
                out = squeeze(contour(i,:,:));
                out_contours{i}{1} = checkNDarray(out);
            end
        end
    end
end

if isempty(out_contours)
    for i = 1:numel(det_output.classes)
        bbox = det_output.boxes(i,1:4);
        bbox(3:4) = bbox(1:2)+bbox(3:4);
        contour = [bbox(1) bbox(2); bbox(3) bbox(2); bbox(3) bbox(4); bbox(1) bbox(4)];
        out_contours{i}{1} = contour;
    end
end
det_output.contours = out_contours;

end

function out = checkNDarray(out)
if ndims(out) > 2
    out = squeeze(out(1,:,:));
end
end