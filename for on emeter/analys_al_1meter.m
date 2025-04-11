clc;
clear;
close all;

% Set the ROI coordinates (should match those used during data collection)
roiX = 864;
roiY = 327;
roiWidth = 211;
roiHeight = 127;

% Directory containing the depth images
dataDir = 'D:\master of robotics\anatomy\project\matlab\data_for_one_meter\aluminum_foil_1m';
depthFiles = dir(fullfile(dataDir, 'depth_*.png'));

% Number of images to analyze
numImages = length(depthFiles);

% Initialize arrays to store measured distances and errors
measuredDistances = zeros(1, numImages);
errors = zeros(1, numImages);

% Actual distance (in mm)
actualDistance = 1000;

for imgIdx = 1:numImages
    % Load the depth image
    depthImage = imread(fullfile(dataDir, depthFiles(imgIdx).name));
    
    % Ensure ROI is within the bounds of the depth image
    depthFrameHeight = size(depthImage, 1);
    depthFrameWidth = size(depthImage, 2);
    
    roiX = max(1, min(roiX, depthFrameWidth - roiWidth + 1));
    roiY = max(1, min(roiY, depthFrameHeight - roiHeight + 1));
    roiWidth = min(roiWidth, depthFrameWidth - roiX + 1);
    roiHeight = min(roiHeight, depthFrameHeight - roiY + 1);

    % Extract ROI from the depth frame
    roiDepth = depthImage(roiY:(roiY + roiHeight - 1), roiX:(roiX + roiWidth - 1));
    
    % Convert the depth image to double precision
    roiDepth = double(roiDepth);
    
    % Extract non-zero depth values from the ROI
    nonZeroDepths = roiDepth(roiDepth > 0);
    
    % Calculate the mean of non-zero depth values
    measuredDistance = mean(nonZeroDepths);
    
    % Calculate the error
    error = abs(measuredDistance - actualDistance);
    
    % Store the results
    measuredDistances(imgIdx) = measuredDistance;
    errors = error;
    
    fprintf('Image %d: Measured Distance = %.2f mm, Error = %.2f mm\n', imgIdx, measuredDistance, error);
end

% Calculate the mean error and standard deviation of the error
meanError = mean(errors);
stdError = std(errors);

fprintf('Mean Error: %.2f mm\n', meanError);
fprintf('Standard Deviation of Error: %.2f mm\n', stdError);

% Visualization
% Histogram of non-zero depth values from the last image
figure;
histogram(nonZeroDepths);
title('Histogram of Non-Zero Depth Values in ROI');
xlabel('Depth (mm)');
ylabel('Frequency');

% Bar graph for systematic errors
figure;
bar(errors);
title('Systematic Errors for Each Image');
xlabel('Image Index');
ylabel('Error (mm)');

% Scatter plot for measured vs actual distances
figure;
scatter(1:numImages, measuredDistances, 'filled');
hold on;
plot(1:numImages, repmat(actualDistance, 1, numImages), 'r--');
title('Measured Distances vs Actual Distance');
xlabel('Image Index');
ylabel('Distance (mm)');
legend('Measured Distance', 'Actual Distance');





