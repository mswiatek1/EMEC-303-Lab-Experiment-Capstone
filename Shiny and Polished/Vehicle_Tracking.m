% This is for tracking a color in a video, finding the centroid of the
% tracked color, and analyzing the centroids vs time to find the position
% of the car as a function of time

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
% % % figure(1); clf(1);
% % % imshow(I); % Shows frame grab converted to black and white
% % % set(gcf, 'name','Spatial Calibration','numbertitle','off');
units = 'pixels';
Calibration = 1.0;
button = 1;
while button ~= 6
    % User input of required action
    button = menu('Select a Function','Measure','Calibrate','Select Color','Analysis','Automatic A in Dr. Owkes Class','Finish');
    
    if button == 6 % EXIT
        break; % End because user clicked exit
    
    elseif button == 1 % Measure
        figure(1); clf(1);
        imshow(I); % Shows frame grab converted to black and white
        set(gcf, 'name','Spatial Calibration','numbertitle','off');
        title('Left Click First Point; Right Click Last Point.');
        [x,y,profile]=improfile();
        % Calculate Distance of line
        dip = sqrt((x(1)-x(end))^2 + (y(1)-y(end))^2);
    
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
        figure(1);
        RealDistance = dip*Calibration;
        caption = sprintf('The distance = %0.3f pixels = %0.2f %s', dip, RealDistance, units);
        title(caption);
    
    elseif button == 3
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
    
    elseif button == 4
        Prompt2 = {'Enter Range Factor'};
        defaultVals2 = {'0.25'};
        UserInput2 = inputdlg(Prompt2,'Enter a color range factor (0.25 is recommended to start with)',1,defaultVals2);        
        p = str2double(UserInput2{1});
        rdiff = p*red; % Red
        gdiff = p*green; % Green
        bdiff = p*blue; % Blue
        vid.CurrentTime = 0; % Rewind
        FirstFrame = readFrame(vid); % First Frame as a background
        trackedObj = zeros(vidHeight,vidWidth,LastFrame);
        newrgb = zeros(vidHeight,vidWidth,LastFrame);
        [m, n, q] = size(trackedObj);
        timestep = vid.Duration/LastFrame;

        A=zeros(size(single(trackedObj))); % initializes flattened video
        x=zeros(1,q-1); % initializes x component storage
        y=zeros(1,q-1); % initializes y component storage
        qstart = NaN;
        h = waitbar(0,'Initializing waitbar...');
        set(h,'Name','Progress Bar');
        for i = 1:q-1
            waitbar(i/(q-1),h,sprintf('%0.2f%% along...',i/(q-1)*100))

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

            % This loop finds the centroid of the white pixels
            % Centroid Finder
            % This component of the code takes the black and white series of matrices
            % titled trackedObj and condenses the white pixels to a single point.
            % This centroid can then be utilized with the frame rate to determine
            % velocity, acceleration, drag coefficient, friction coefficient, etc.

            A(:,:,i)=single(trackedObj(:,:,i)); % this flattens the ith matrix
            s=regionprops(A(:,:,i),'centroid'); % this calculates the centroid
            if length(s)>0 % if there is a centroid found store it in the following way
                x(i)=s.Centroid(1); % checks x component
                y(i)=s.Centroid(2); % checks y component
            end
            % This loop cancels out any points that are (0,0)
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

        % Velocity
        % Preallocate
        xvel = zeros(1,b-1);
        yvel = zeros(1,b-1);
        posmag = zeros(1,b-1);
        velmag = zeros(1,b-1);
        time = zeros(1,b-1);
        for i = 1:b-2
            time(i+1) = time(i) + timestep;
        end
        for i = 1:b-1
            posmag(i) = sqrt((newx(i+1)-newx(i)).^2+(newy(i+1)-newy(i)).^2);
        end

        % Plot the path and position of the car
        figure(4); clf(4);
        subplot(2,1,1)
        plot(newx,newy);
        title('Path of the car')
        xlabel(sprintf('%s', units))
        ylabel(sprintf('%s', units))
        subplot(2,1,2)
        scatter(time,posmag,'.');
        title('Position vs. Time')
        ylabel(sprintf('%s', units))
        xlabel('seconds')
    elseif button == 5
        errordlg('Sorry, the portion of code you are trying to access is no longer valid.  You will have to earn an A the hard way.','It was worth a shot!');
    end
    
end




