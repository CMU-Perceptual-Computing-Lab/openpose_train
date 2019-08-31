function progressDisplay(iteration, logEveryXFrames, totalElements)
    % Display progress
    if mod(iteration, logEveryXFrames) == 0 && iteration <= totalElements
        fprintf('%d/%d', iteration, totalElements);
        if mod(iteration, 6*logEveryXFrames) == 0
            fprintf('\n');
        else
            fprintf('\t');
        end
    end
end
