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
read(vid, Inf);
LastFrame = vid.NumberOfFrames; % Total number of frames in the video
vidHeight = vid.Height; % Height in Pixels
vidWidth = vid.Width; % Width in Pixels

NumberFramesWritten = 0;

% Convert video to black and white binary
BWvid = zeros(vidHeight,vidWidth,LastFrame); % Preallocate array
ObjMotVid = zeros(vidHeight,vidWidth,LastFrame); % Preallocate array
for i=1:LastFrame
    currentFrame = read(vid,i);
    level = graythresh(currentFrame); % Threshold level for black/ white
    BWvid(:,:,i) = im2bw(currentFrame,level); % Convert image to black and white (binary)
    %ObjMotVid(:,:,i) = BWvid(:,:,i) - BWvid(:,:,1); % Subtract first frame from video
    %BWcurrentFrame = im2bw(currentFrame,level);
%     A = 0.5;
%     if i == 1
%         Bkgd = currentFrame;
%     else
%         Bkgd = (1-A)*currentFrame+A*Bkgd;
%     end
    % Convert Bkgd to bw
    %BWBkgd = im2bw(Bkgd,level);
    %imshow(Bkgd)
    
    %diff = BWcurrentFrame - Bkgd;
end
 % diff = BWvid(:,:,i)-BWBkgd;
%implay(BWvid)
%implay(ObjMotVid)
%implay(Diff)

