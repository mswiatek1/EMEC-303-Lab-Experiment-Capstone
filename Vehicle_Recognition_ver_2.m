% Code for finding a moving an object in a video
% Adapted from http://www.mathworks.com/matlabcentral/answers/uploaded_files/6434/ExtractMovieAVIFrames.m

% Clear workspace and command window
clear all
clc

% Import video file of interest
filename= uigetfile({'*.*'},'Select the desired video file');
if isequal(filename,0)
    fprintf('No file was selected \n')
else
    fprintf('%s was selected \n',filename)
end

% Open Video, Collect info from the file
vid = VideoReader(filename);
v= readFrame(vid);
LastTime = vid.Duration; % Total number of frames in the video
vidHeight = vid.Height; % Height in Pixels
vidWidth = vid.Width; % Width in Pixels
LastFrame = floor(vid.Duration*vid.FrameRate);
NumberFramesWritten = 0;
FirstTime = LastTime/vid.FrameRate;
% Convert video to black and white binary
BWvid = zeros(vidHeight,vidWidth,LastFrame); % Preallocate array
BW2vid = zeros(vidHeight,vidWidth,LastFrame); % Preallocate array

for i = 1:LastFrame-1
    currentFrame = readFrame(vid);
    level = graythresh(currentFrame); % Threshold level for black/ white
    BWvid(:,:,i) = im2bw(currentFrame,level); % Convert image to black and white (binary)
    BW2vid(:,:,i) = bwareaopen(BWvid(:,:,i),500);
end

    background = imdilate(BW2vid, ones(1,1,100));
    diff = imabsdiff(BW2vid, background);
    
% centroids = zeros(LastFrame, 2);
%     
% for k = 1:LastFrame
% L = logical(diff(:, :, k));
% s = regionprops(L, 'area', 'centroid');
% area_vector = [s.Area];
% [tmp, idx] = max(area_vector);
% centroids(k, :) = s(idx(1)).Centroid;
% end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
