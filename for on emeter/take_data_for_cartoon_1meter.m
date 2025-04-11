delete(imaqfind);
clc;
close all;
clear;

% Load the calibration results
load('calibrationResults.mat', 'intrinsicMatrix', 'rotationMatrices');

% Set the ROI based on your calibration results
roiX = 864;
roiY = 327;
roiWidth = 211;
roiHeight = 127;

% Ensure ROI is within the bounds of the depth frame (512x424)
depthFrameWidth = 512;
depthFrameHeight = 424;

roiX = max(1, min(roiX, depthFrameWidth - roiWidth + 1));
roiY = max(1, min(roiY, depthFrameHeight - roiHeight + 1));

% Initialize Kinect v2 sensor
depthVid = videoinput('kinect', 2, 'Depth_512x424');
srcDepth = getselectedsource(depthVid);
depthVid.FramesPerTrigger = 1;
depthVid.TriggerRepeat = Inf;
triggerconfig(depthVid, 'manual');
start(depthVid);

% Number of images to capture
numImages = 10;

% Material to test
material = 'cardboard'; % Change to 'aluminum_foil' for the second surface

% Distance to capture data at (in meters)
distance = 1;  % 1 meter

% Directory to save captured depth data
outputDir = 'D:\master of robotics\anatomy\project\matlab\data_for_one_meter';
outputFolder = fullfile(outputDir, sprintf('%s_%dm', material, distance));
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

for imgIdx = 1:numImages
    % Capture depth frame
    trigger(depthVid);
    depthFrame = getdata(depthVid);
    
    % Extract ROI from the depth frame
    roiDepth = depthFrame(roiY:(roiY + roiHeight - 1), roiX:(roiX + roiWidth - 1));
    
    % Save the depth data
    outputFileName = fullfile(outputFolder, sprintf('depth_%d.png', imgIdx));
    imwrite(roiDepth, outputFileName);
    
    fprintf('Captured and saved depth data for %s at %dm, image %d\n', material, distance, imgIdx);
end

% Stop the Kinect sensor
stop(depthVid);
delete(depthVid);
clear depthVid;
