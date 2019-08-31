function footJsonStruct = jsonToStruct(jsonPath)
    % Read foot file
    fileID = fopen(jsonPath, 'r');
    jsonString = fscanf(fileID, '%s');
    fclose(fileID);
    % Json struct
    footJsonStruct = jsondecode(jsonString);
end
