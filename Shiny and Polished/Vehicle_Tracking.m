% This is for tracking a color in a video, finding the centroid of the
% tracked color, and analyzing hte centroids vs time to find the position,
% velocity, and acceleration

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

%
level = graythresh(mid); % Threshold level for black/ white
I = im2bw(mid,level); % Convert image to black and white (binary)

% Insert image into figure

[rows, columns] = size(I);
figure(1); clf(1);
subplot(2,1,1);
imshow(I); % Shows frame grab converted to black and white
set(gcf, 'name','Spatial Calibration','numbertitle','off');
units = 'pixels';
Calibration = 1.0;
button = 1;
while button ~= 4
    % User input of required action
    button = menu('Pick One','Measure','Calibrate','Automatic A in Dr. Owkes Class','Proceed');
    if button == 4 % EXIT
        break; % End because user clicked exit
    elseif button == 1 % Measure
        %subplot(2,1,1);
        title('Left Click First Point; Right Click Last Point.');
        [x,y,profile]=improfile();
        % Calculate Distance of line
        dip = sqrt((x(1)-x(end))^2 + (y(1)-y(end))^2);
        subplot(2,1,2);
        plot(profile);
        grid on;
    elseif button == 2 % Calibration
        Prompt = {'Enter True Size','Enter Units'};
        defaultVals = {'12','Inches'};
        UserInput = inputdlg(Prompt,'Enter a known distance',2,defaultVals);
        if isempty(UserInput)
            return
        end
        % Transfer user input into matlab
        RealLength = str2double(UserInput{1});
        units = char(UserInput{2});
        % Check to make sure the number provided is a number
        if isnan(RealLength)
            warndlg('There is something wrong with the previous step. The pixel length will be used instead','Whoops! Something went wrong here!');
            RealLength = dip;
            units = 'pixels';
            Calibration = 1.0; 
            continue; % This skips to the end of the loop
        end
        Calibration = RealLength/dip;
    elseif button == 3
        errordlg('Sorry, the portion of code you are trying to access is no longer valid.  You will have to earn an A the hard way.','It was worth a shot!');
    end
    
end
    RealDistance = dip*Calibration;
    caption = sprintf('Intensity Profile Along Line \nThe distance = %f pixels = %f %s', dip, RealDistance, units);
    title(caption);
    ylabel('Color');
    xlabel('Pixels Along Line');
%

figure(2); clf(2);
imshow(mid);
     uiwait(msgbox('Zoom into the car on the image, press enter, click on the desired pixel, then press enter again','','modal'));
pause
hold on
readpix = impixel(mid);
hold off
red = readpix(1); % Red value
green = readpix(2); % Green Value
blue = readpix(3); % Blue value

%
p = 0.25;
rdiff = p*red; % Red
gdiff = p*green; % Green
bdiff = p*blue; % Blue
vid.CurrentTime = 0; % Rewind
FirstFrame = readFrame(vid); % First Frame as a background
trackedObj = zeros(vidHeight,vidWidth,LastFrame);
newrgb = zeros(vidHeight,vidWidth,LastFrame);
[m, n, q] = size(trackedObj);
timestep = vid.Duration/LastFrame;

for i = 1:q-1
    
    currentFrame = readFrame(vid);% 
     redchan = currentFrame(:,:,1); % Red Channel
     greenchan = currentFrame(:,:,2); % Green Channel
     bluechan = currentFrame(:,:,3); % Blue Channel
    
    
     
     
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
end 

% Centroid Finder
% This component of the code takes the black and white series of matrices
% titled trackedObj and condenses the white pixels to a single point.
% This centroid can then be utilized with the frame rate to determine
% velocity, acceleration, drag coefficient, friction coefficient, etc.

% initialize loop
A=zeros(size(single(trackedObj))); % initializes flattened video
x=zeros(1,q-1); % initializes x component storage
y=zeros(1,q-1); % initializes y component storage

% loop that finds the centroid of the white pixels
for i=1:q-1 % runs for every matrix in the set
    A(:,:,i)=single(trackedObj(:,:,i)); % this flattens the ith matrix
    s=regionprops(A(:,:,i),'centroid'); % this calculates the centroid
    if length(s)>0 % if there is a centroid found store it in the following way
        x(i)=s.Centroid(1); % checks x component
        y(i)=s.Centroid(2); % checks y component
    end
end
% for i=2:q-2 % loop to find (0,0) centroids and readjust them through linear interpolation
%     if x(i)==0 && y(i)==0
%         x(i)=abs((x(i-1)-x(i+1))/2); % new x value 
%         y(i)=abs((y(i-1)-y(i+1))/2); % new y value
%     end
% end
for i=1:q-1 % loop to cancel out any remaining (0,0) 
    if x(i)==0 % checks if x is 0
       x(i)=NaN; % deletes x
    end
    if y(i)==0 % checks if y is 0
       y(i)=NaN; % deletes y
    end
end

% Convert from camera pixels to units selected previously
newx = Calibration*x;
newy = -Calibration*y;
[a, b] = size(newx);

% Plot the path the car travels
figure(3); clf(3);
plot(newx,newy);
title('Path of the car')
xlabel(sprintf('%s', units))
ylabel(sprintf('%s', units))

% Velocity
% Preallocate
xvel = zeros(1,b-1);
yvel = zeros(1,b-1);
xacc = zeros(1,b-1);
yacc = zeros(1,b-1);
posmag = zeros(1,b-1);
velmag = zeros(1,b-1);
accmag = zeros(1,b-1);
time = zeros(1,b-1);
for i = 1:b-2
    time(i+1) = time(i) + timestep;
end
for i = 1:b-1
    posmag(i) = sqrt(newx(i).^2+newy(i).^2);
    xvel(i) = (newx(i+1)-newx(i))/timestep;
    yvel(i) = (newy(i+1)-newy(i))/timestep;
    velmag(i) = sqrt(xvel(i).^2+yvel(i).^2);
end
for i = 1:b-2
    xacc(i) = (xvel(i+1)-xvel(i))/timestep;
    yacc(i) = (yvel(i+1)-yvel(i))/timestep;
    accmag(i) = sqrt(xacc(i).^2+yacc(i).^2);
end
% Plot the velocity of the car
figure(4); clf(4);
subplot(3,1,1)
scatter(time,posmag,'.');
title('Position')
ylabel(sprintf('%s', units))
subplot(3,1,2)
scatter(time,velmag,'.');
title('Velocity')
ylabel(sprintf('%s per second', units))
subplot(3,1,3)
scatter(time,accmag,'.');
title('Acceleration')
xlabel('seconds')
ylabel(sprintf('%s per second^2', units))

