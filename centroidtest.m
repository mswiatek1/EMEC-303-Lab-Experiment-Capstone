clear; clc;

% Import video file of interest
filename= uigetfile({'*.*'},'Select the desired image file');
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

% Initialize Loop
N=LastFrame;
currentframe=readFrame(vid);

for i=1:N

    a=currentframe;
    [x1,y1,z1]=size(a);
    level=graythresh(a);
    BW=im2bw(a,level);
    background = imdilate(BW, ones(x1,y1,z1));
    diff = imabsdiff(BW, background);
    s=regionprops(diff,'centroid');
    centroids=cat(1, s.Centroid);

%     figure(1)
%     imshow(a)
%     hold on
%     plot(centroids(:,1),centroids(:,2),'r*')
%     hold off
% 
%     figure(2)
%     imshow(diff)
%     hold on
%     plot(centroids(:,1),centroids(:,2),'r*')
%     hold off
    
    currentframe=readFrame(vid);
end