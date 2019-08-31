function progressBarInit()
    % Create progress bar
    fprintf('Parfor progress:\n');
    fprintf(['0%%', repmat(' ',1,46), '50%%' repmat(' ',1,46) '100%%\n']);
    fprintf(['|', repmat('-',1,48), '|', repmat('-',1,49) '|\n.']);
end
