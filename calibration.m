% Initialize Kinect v2
depthVid = videoinput('kinect', 2); % Initialize depth video input object
colorVid = videoinput('kinect', 1); % Initialize color video input object

% Configure Video Input
triggerconfig(depthVid, 'manual'); % Set manual trigger for depth sensor
triggerconfig(colorVid, 'manual'); % Set manual trigger for color sensor

% Set TriggerRepeat to a value that allows multiple triggers
numCaptures = 3; % Number of distances to capture
depthVid.TriggerRepeat = numCaptures - 1; % Allow multiple triggers for depth sensor
colorVid.TriggerRepeat = numCaptures - 1; % Allow multiple triggers for color sensor

depthVid.FramesPerTrigger = 1; % Capture one frame per trigger for depth sensor
colorVid.FramesPerTrigger = 1; % Capture one frame per trigger for color sensor

% Start the video input object
start(depthVid); % Start depth video input
start(colorVid); % Start color video input
% List of distances for calibration images
distances = 1; % Distances in meters

% Capture calibration images
for i = 1:length(distances)
    disp(['Capturing at ', num2str(distances(i)), ' meters...']);
    % Place the checkerboard at the specified distance

    % Capture frames
    trigger(colorVid); % Trigger color video capture
    trigger(depthVid); % Trigger depth video capture

    [colorFrame, ~, ~] = getdata(colorVid); % Get color frame
    [depthFrame, ~, ~] = getdata(depthVid); % Get depth frame

    % Save the captured frames
    imwrite(colorFrame, ['color_frame_' num2str(distances(i)) 'm.png']); % Save color frame
    imwrite(depthFrame, ['depth_frame_' num2str(distances(i)) 'm.png']); % Save depth frame
end
% Stop the video input object
stop(depthVid); % Stop depth video input
stop(colorVid); % Stop color video input


% List of calibration images
imageFiles = {'color_frame_1m.png', 'color_frame_2m.png', 'color_frame_3m.png'};

% Detect checkerboard points in the images
[imagePoints, boardSize] = detectCheckerboardPoints(imageFiles);

% Display detected points on the first image
I = imread(imageFiles{1});
J = insertMarker(I, imagePoints(:, :, 1), 'o', 'Color', 'red', 'Size', 5);
imshow(J);
title('Detected Checkerboard Points');


% Generate world coordinates of the checkerboard corners
squareSize = 30; % or 35 depending on your checkerboard
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Estimate camera parameters
imageSize = [size(I, 1), size(I, 2)];
cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);

% Display the reprojection errors
figure;
showReprojectionErrors(cameraParams);
title('Reprojection Errors');

% Display detected and reprojected points
figure;
imshow(I);
hold on;
plot(imagePoints(:, 1, 1), imagePoints(:, 2, 1), 'go');
plot(cameraParams.ReprojectedPoints(:, 1, 1), cameraParams.ReprojectedPoints(:, 2, 1), 'r+');
legend('Detected Points', 'Reprojected Points');
title('Detected and Reprojected Points');
hold off;


% Validate calibration
figure;
showExtrinsics(cameraParams, 'CameraCentric');
title('Camera Extrinsics');

% Display calibration results
fprintf('Reprojection Errors:\n');
disp(cameraParams.ReprojectionErrors);

fprintf('Intrinsic Parameters:\n');
disp(cameraParams.IntrinsicMatrix);
