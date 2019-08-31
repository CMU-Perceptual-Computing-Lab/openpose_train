%% Plotting losses
close all; clear variables; clc

% Add extra scripts
addpath('../matlab_utilities/')

% Get losses from Caffe output:
filesToGrep = {
    '../training_results/Data_2017/2_19NEG_2017/pose/body_19/training_log.txt';
%     '../training_results/6_19paf2bpCpm/pose/body_19/training_log_2.txt';
};
sampling_rate = 20;
textsToSearch = {
    ', loss = ', ...
    'loss_stage6_L2 = ', ...
    'loss_stage6_L1 = ', ...
...    'loss_stage5_L2 = ', ...
...    'loss_stage5_L1 = ', ...
...    'loss_stage4_L2 = ', ...
...    'loss_stage4_L1 = ', ...
};
numbersPerRow = 4;
offset = 1;

for fileToGrepIndex = 1:numel(filesToGrep)
    fileToGrep = filesToGrep{fileToGrepIndex};
    figureOffset = 2*(fileToGrepIndex-1);

    plotLoss(fileToGrep, textsToSearch{1}, sampling_rate, 1, 0, 0, figureOffset);
    for i = 2:numel(textsToSearch)
        plotLoss(fileToGrep, textsToSearch{i}, sampling_rate, numbersPerRow, offset, 0, figureOffset);
        hold on
    end
    for i=1:2
        figure(i+figureOffset)
        xlabel('10^3 iterations');
        ylabel('Loss');
        title('Training Loss - OpenPose');
        everyXIterationsText = [' (every ', int2str(sampling_rate),' iterations)'];
        legend(...
            ['Loss', everyXIterationsText], ...
        ...    ['Loss (average of ', int2str(span) , ' samples)'], ...
            ['loss_stage6_L2', everyXIterationsText], ...
            ['loss_stage6_L1', everyXIterationsText], ...
            ['loss_stage5_L2', everyXIterationsText], ...
            ['loss_stage5_L1', everyXIterationsText], ...
            ['loss_stage4_L2', everyXIterationsText], ...
            ['loss_stage4_L1', everyXIterationsText], ...
            ['loss_stage3_L2', everyXIterationsText], ...
            ['loss_stage3_L1', everyXIterationsText], ...
            ['loss_stage2_L2', everyXIterationsText], ...
            ['loss_stage2_L1', everyXIterationsText], ...
            ['loss_stage1_L2', everyXIterationsText], ...
            ['loss_stage1_L1', everyXIterationsText] ...
        );
        grid
    end
    % Average
    averagedOverXSamples = 20;
    % Average of main loss
    plotLoss(fileToGrep, textsToSearch{1}, sampling_rate, 1, 0, averagedOverXSamples, figureOffset);
    % % Average of each Li loss
    % for i = 2:numel(textsToSearch)
    %     plotLoss(fileToGrep, textsToSearch{i}, sampling_rate, numbersPerRow, offset, averagedOverXSamples, figureOffset);
    %     hold on
    % end
end

% Plot results
function plotLoss(fileToGrep, textToSearch, sampling_rate, numbersPerRow, offset, averagedOverXSamples, figureOffset)
    disp(' ');
    disp(fileToGrep);

    % Read losses - Y-axis
    finalFile = 'losses.txt';
    losses = caffeToMatlabLosses(fileToGrep, finalFile, textToSearch);
    losses = losses(offset+1:numbersPerRow:end);

    % X-axis
    x_axis = (0:numel(losses)-1) * sampling_rate * 1e-3;

    % Plot results
    if averagedOverXSamples > 0
        losses_smooth = smooth(losses, averagedOverXSamples);
        plot(x_axis, losses_smooth, 'LineWidth', 1.5)
    else
        figure(1+figureOffset), loglog(x_axis, losses, 'LineWidth', 1), hold on % 0 is excluded (0 -> -Inf dB)
%         figure(2*(fileToGrepIndex-1)+1+figureOffset), semilogx(x_axis, losses, 'LineWidth', 1), hold on
        figure(2+figureOffset), plot(x_axis, losses, 'LineWidth', 1), hold on
    end

    % Command line output
    disp(['Number of measurements: ', int2str(numel(losses))])
    disp(['Iterations: ', int2str(numel(losses)*sampling_rate)])
end
