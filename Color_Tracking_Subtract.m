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
vid.currentTime = LastTime-(LastTime/vid.FrameRate);
last = readFrame(vid);

figure(1); clf(1)
    subplot(2,1,1)
    imshow(mid)
    subplot(2,1,2)
    imshow(mid-last)
     uiwait(msgbox('Zoom into the area of intereston the bottom image, press enter, click on the desired pixel, then press enter again','','modal'));
pause
hold on
readpix = impixel(mid-last);
hold off
red = readpix(1); % Red value
green = readpix(2); % Green Value
blue = readpix(3); % Blue value

%
p = 0.35;
rdiff = p*red; % Red
gdiff = p*green; % Green
bdiff = p*blue; % Blue
vid.CurrentTime = 0; % Rewind
FirstFrame=readFrame(vid); % First Frame as a background
trackedObj = zeros(vidHeight,vidWidth,LastFrame);
newrgb = zeros(vidHeight,vidWidth,LastFrame);
[m, n, q] = size(trackedObj);

% for i = 1:q-1
%     currentFrame = readFrame(vid)-last; %- FirstFrame;
%     redchan = currentFrame(:,:,1); % Red Channel
%     greenchan = currentFrame(:,:,2); % Green Channel
%     bluechan = currentFrame(:,:,3); % Blue Channel
%     i
%     % This loop finds black pixels and makes them similar to the board
% %     for jj = 1:m
% %         for kk = 1:n
% % %             redpix = redchan(j,k,i);
% % %             greenpix = greenchan(j,k,i);
% % %             bluepix = bluechan(j,k,i);
% %             if (redchan(jj,kk) <= 50 && greenchan(jj,kk) <= 50 && bluechan(jj,kk) <= 50)
% %                 redchan(jj,kk,i) = 140;
% %                 greenchan(jj,kk,i) = 140;
% %                 bluechan(jj,kk,i) = 130;
% %             end
% %         end
% %     end
% %     newrgb = cat(3,redchan,greenchan,bluechan);
% end

for i = 1:q-1
    
    currentFrame = readFrame(vid) -last;%- FirstFrame;
     redchan = currentFrame(:,:,1); % Red Channel
     greenchan = currentFrame(:,:,2); % Green Channel
     bluechan = currentFrame(:,:,3); % Blue Channel
     i;
    %imshow(newrgb)
    %redch = 
    % This loop finds the pixels within the range of the selected color and
    % marks them as a point if they are within the range.  If not, it is
    % set as zero
    for j = 1:m
        for k = 1:n
            if (redchan(j,k) <= red+rdiff && redchan(j,k) >= red-rdiff && ...
                greenchan(j,k) <= green+gdiff && greenchan(j,k) >= green-gdiff && ...     
                bluechan(j,k) <= blue+bdiff && bluechan(j,k) >= blue-bdiff)

                trackedObj(j,k,i) = 1;
            else
                trackedObj(j,k,i) = 0;
            end
        end
    end
    
%     figure(2); clf(2)
%     subplot(2,1,1)
%     imshow(currentFrame)
%     subplot(2,1,2)
%     imshow(trackedObj(:,:,i))
%     pause
    

    % Centroid Finding
%     a=currentFrame;
%     [x1,y1,z1]=size(a);
%     level=graythresh(a);
%     BW=im2bw(a,level);
%     background = imdilate(BW, ones(x1,y1,z1));
%     diff = imabsdiff(BW, background);
    s=regionprops(trackedObj,'centroid');
    centroids=cat(1, s.Centroid);
end

% Find Centroids in each frame
% for i = 1:q-1
%     i
%     
%    s = regionprops(trackedObj,'centroid');
%    centroids = cat(1, s.Centroid);
%    figure(2); clf(2);
%    imshow(trackedObj(:,:,i));
%    hold on
%    plot(centroids(:,1,i),centroids(:,2,i),'b*')
%    hold off
% 
% end









        
        
        
        