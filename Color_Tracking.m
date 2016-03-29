% This is for tracking a color in a video
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
LastTime = vid.Duration; % Total time of video
vidHeight = vid.Height; % Height in Pixels
vidWidth = vid.Width; % Width in Pixels
vid.CurrentTime = LastTime/2;
LastFrame = floor(LastTime*vid.FrameRate);
mid = readFrame(vid); % Reads the frame at the middle timestep in video for analyzing

readpix = impixel(mid);
red = readpix(1); % Red value
green = readpix(3); % Green Value
blue = readpix(2); % Blue value

p = .05;
rdiff = p*red; % Red
gdiff = p*green; % Green
bdiff = p*blue; % Blue
% vid.CurrentTime = 
trackedObj = ones(vidHeight,vidWidth,LastFrame);
[m, n, q] = size(trackedObj);
for i = LastFrame-1
    currentFrame = readFrame(vid);
    redchan = currentFrame(:,:,1); % Red Channel
    greenchan = currentFrame(:,:,2); % Green Channel
    bluechan = currentFrame(:,:,3); % Blue Channel
    
    for j = 1:m
        for k = 1:n
            if redchan(j,k) <= red+rdiff && redchan(j,k) >= red-rdiff && ...
               greenchan(j,k) <= green+gdiff && greenchan(j,k) >= green-gdiff && ...     
               bluechan(j,k) <= blue+bdiff && bluechan(j,k) >= blue-bdiff 

                trackedObj(j,k) = 1;
            else
                trackedObj(j,k) = 0;
            end
        end
    end
    
    
end
        
        
        
        
        