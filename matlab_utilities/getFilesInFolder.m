function filePaths = getFilesInFolder(folderToRead, fileExtension)
    % Get *.fileExtension file names
    fileNamesStruct = dir(folderToRead);
    fileNames = cell(1, numel(fileNamesStruct) - 2);
    currentIndex = 1;
    for fileIndex = 1:numel(fileNames)
        [~, ~, extension] = fileparts(fileNamesStruct(fileIndex+2).name);
        if ~exist('fileExtension', 'var') || strcmp(extension, fileExtension) || strcmp(extension, ['.', fileExtension])
            fileNames{currentIndex} = fileNamesStruct(fileIndex+2).name;
            currentIndex = currentIndex + 1;
        end
    end
    if currentIndex > 1
        fileNames = fileNames(1:currentIndex-1);
    else
        fileNames = cell(1,0);
    end

    % Get JSON file paths
    filePaths = fileNames;
    for fileIndex = 1:numel(filePaths)
        filePaths{fileIndex} = [folderToRead, '/', filePaths{fileIndex}];
    end
end
