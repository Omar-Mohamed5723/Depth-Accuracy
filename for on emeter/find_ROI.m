clc
close all
clear

% Load a single calibration image
imageFile = 'D:/master of robotics/anatomy/project/matlab/calib 1/color_frame_1m_1.png'; % Adjust the file path as needed
image = imread(imageFile);

% Parameters of the checkerboard
squareSize = 40; % size of one square in mm
numSquaresX = 4; % number of squares along X-axis (including one white square between black squares)
numSquaresY = 3; % number of squares along Y-axis (including one white square between black squares)

% Detect the checkerboard corners
[imagePoints, boardSize] = detectCheckerboardPoints(image);

% Check if the checkerboard was detected
if ~isempty(imagePoints)
    % Display the detected corners
    figure, imshow(image);
    hold on;
    plot(imagePoints(:,1), imagePoints(:,2), 'ro');
    title('Detected Checkerboard Corners');

    % Calculate the ROI
    roiX = round(min(imagePoints(:,1)));
    roiY = round(min(imagePoints(:,2)));
    roiWidth = round(max(imagePoints(:,1)) - roiX);
    roiHeight = round(max(imagePoints(:,2)) - roiY);

    fprintf('ROI: X=%d, Y=%d, Width=%d, Height=%d\n', roiX, roiY, roiWidth, roiHeight);
else
    fprintf('Checkerboard not detected in the image.\n');
end
