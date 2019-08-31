%% Foot JSON to Mat format
close all; clear variables; clc;

% Time measurement
tic

% Read mat with info
load('/media/posefs0c/panopticdb/a2/training_samples.mat'); % All but the other 2
load('/media/posefs0c/panopticdb/a2/val_samples.mat'); % 160422_haggling1
load('/media/posefs0c/panopticdb/a2/test_samples.mat'); % 170407_haggling_a1,_a2,_a3,_b1,_b2,_b3
training_samples = training_samples;
val_samples = val_samples;
test_samples = test_samples;

%%
clc
for sampleId = 1:3
    if sampleId == 1
        disp('training_samples');
        samples = training_samples;
    elseif sampleId == 2
        disp('val_samples');
        samples = val_samples;
    elseif sampleId == 3
        disp('test_samples');
        samples = test_samples;
    else
        asser(false, 'This should not happen');
    end
    % Get number elements
    numberElements = numel(samples);
    % Create array
    samplesV = cell(numberElements, 1);
    for elementId = 1:numberElements
        samplesV{elementId} = samples(elementId).seqName;
    end
    unique(samplesV)
end

% Total running time
disp(['Total time: ', int2str(round(toc)), ' seconds.']);
