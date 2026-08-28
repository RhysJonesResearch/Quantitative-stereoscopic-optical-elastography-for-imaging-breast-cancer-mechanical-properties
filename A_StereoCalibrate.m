%% 0. Resave jpg's split from both to left and right
inputDir = 'F:\Rhys\MATLAB Workspace\Probe_19\Both';
leftDir = 'F:\Rhys\MATLAB Workspace\Probe_19\Left';
rightDir = 'F:\Rhys\MATLAB Workspace\Probe_19\Right';

% 2. Get a list of all JPG files
filePattern = fullfile(inputDir, '*.jpg');
files = dir(filePattern);

for k = 1:length(files)
    baseFileName = files(k).name;
    fullFileName = fullfile(inputDir, baseFileName);
    img = imread(fullFileName);
    leftImg  = img(:, 1:640, :);
    rightImg = img(:, 641:1280, :);
    [~, name, ext] = fileparts(baseFileName);
    
    imwrite(leftImg,  fullfile(leftDir, ['Left_', name(6:7), ext]));
    imwrite(rightImg, fullfile(rightDir, ['Right_', name(6:7), ext]));
end

%% 1. Path to image files
leftImages = imageDatastore(fullfile('F:\Rhys\MATLAB Workspace\Probe_19\Left','*.jpg'));
rightImages = imageDatastore(fullfile('F:\Rhys\MATLAB Workspace\Probe_19\Right','*.jpg'));

%% 2. Detect calibration pattern (checkerboard)
[imagePoints, boardSize] = detectCheckerboardPoints(leftImages.Files, rightImages.Files);

%% 3. Generate world coordinates of the checkerboard keypoints
squareSize = 1; % millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

%% 4. Calibrate the stereo camera system
% This returns the 'stereoParams' object containing intrinsics and extrinsics
I = readimage(leftImages,1); 
imageSize = [size(I,1) size(I,2)];
stereoParams = estimateCameraParameters(imagePoints,worldPoints, ...
    "ImageSize",imageSize);
%% 5. visualize calibration
figure
showReprojectionErrors(stereoParams)
figure
showExtrinsics(stereoParams)

%% 6. Rectification and Undistortion
% Load a pair of raw images to process
I1 = readimage(leftImages, 1); 
I2 = readimage(rightImages, 1);
% 'rectifyStereoImages' handles both lens distortion and alignment
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

%% DON'tRUN. Rectification and Undistortion
% Load a pair of raw images to process
I1 = imread('F:\Rhys\MATLAB Workspace\Probe_19\Left\Left_41.jpg');
I2 = imread('F:\Rhys\MATLAB Workspace\Probe_19\Right\Right_41.jpg');
% 'rectifyStereoImages' handles both lens distortion and alignment
[J1, J2] = rectifyStereoImages(I1, I2, stereoParams);

%% 7. Visualize the result
figure
imshowpair(J1, J2, 'montage');
title('Rectified Stereo Pair with Horizontal Alignment Check');
hold on;
[height, width, ~] = size(J1);
yPositions = linspace(1, height, 10); % num lines at end
for i = 1:length(yPositions)
    line([0, 2*width], [yPositions(i), yPositions(i)], ...
         'Color', 'cyan', 'LineWidth', 0.8, 'LineStyle', '--');
end
hold off;
%% 8. Save parameters
save('F:\Rhys\MATLAB Workspace\Probe_19\stereoParams.mat', 'stereoParams');
