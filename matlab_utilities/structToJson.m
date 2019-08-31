function structToJson(jsonPath, structToSave)
    % Json struct
    jsonString = jsonencode(structToSave);
    % Write foot file
    fileID = fopen(jsonPath, 'w');
    fprintf(fileID, jsonString);
    fclose(fileID);
end
