function writeJson(jsonStruct, jsonFileName)
    opt.FileName = jsonFileName;
    opt.FloatFormat = '%.3f';
    savejson('', jsonStruct, opt);
end
