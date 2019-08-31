clc; clear; close all;
data = importdata('temp.txt');
for i = 1:size(data,1)
    if length(strfind(data{i}, 'polygon') > 2)
        fprintf('%s ', data{i}(12:14));
    end
end