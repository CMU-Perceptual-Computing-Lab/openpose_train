function avgPrecAndRecall = getPrecisionAndRecall(resFiles, cocoGt, type)
    avgPrecAndRecall = getPrecisionAndRecallUpToX(resFiles, cocoGt, type, -1);
end
