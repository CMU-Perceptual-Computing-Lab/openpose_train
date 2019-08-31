function losses = caffeToMatlabLosses(fileToGrep, finalFile, textToSearch)
    % Get losses:
    command = ['grep -o -P ''', textToSearch, '.{0,20}'' ', fileToGrep, ' | sed ''s/[^0-9  0-9 .]//g'' > ', finalFile];
    system(command);
    fileID = fopen(finalFile, 'r');
    formatSpec = '%f';
    losses = fscanf(fileID, formatSpec); % Read file: https://www.mathworks.com/help/matlab/ref/fscanf.html
    delete(finalFile)
end
