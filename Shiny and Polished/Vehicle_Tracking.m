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

level = graythresh(mid); % Threshold level for black/ white
I = im2bw(mid,level); % Convert image to black and white (binary)

[rows, columns] = size(I);

units = 'pixels';
Calibration = 1.0;
NewFirstFrame = 1;
NewLastFrame = LastFrame;
button = 1;
while button ~= 6
    % User input of required action
    button = menu('Select a Function','Trim Video','Measure','Calibrate','Select Color','Analysis','Finish');
    
    if button == 6 % EXIT
        break; % End because user clicked exit
        
    elseif button == 1 % Trim Video
        uiwait(msgbox({'Play through the video and find the first and last frame'...
            'that correspond with where the car enters and leaves the field of view.'...
            'Then, close the video, return to the command window and press enter.'...
            'Enter the values of first and last frame into the dialog box.'...
            'OR, if the video has already been trimmed, leave both cells blank.'},'','modal'));
        implay(filename)
        pause
        Prompt0 = {'Enter First Frame Number','Enter Last Frame Number'};
        
        UserInput0 = inputdlg(Prompt0,'Enter the first and last frame number',2);
            NewFirstFrame = str2double(UserInput0{1});
            NewLastFrame = str2double(UserInput0{2});
        if isnan(NewFirstFrame) == 1
            NewFirstFrame = 1;
            NewLastFrame = LastFrame;
        end
                
    elseif button == 2 % Measure
        figure(1); clf(1);
        imshow(I); % Shows frame grab converted to black and white
        set(gcf, 'name','Spatial Calibration','numbertitle','off');
        uiwait(msgbox('Left Click the First Point then Right Click the Last Point','','modal'));
        [x,y,profile]=improfile();
        % Calculate Distance of line
        dip = sqrt((x(1)-x(end))^2 + (y(1)-y(end))^2);
    
    elseif button == 3 % Calibration
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
    
    elseif button == 4 % Select Color
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
    
    elseif button == 5 % Analysis
        Prompt2 = {'Enter Range Factor'};
        defaultVals2 = {'0.25'};
        UserInput2 = inputdlg(Prompt2,'Enter a color range factor (0.25 is recommended to start with)',1,defaultVals2);        
        p = str2double(UserInput2{1});
        rdiff = p*red; % Red
        gdiff = p*green; % Green
        bdiff = p*blue; % Blue
        vid.CurrentTime = (NewFirstFrame-1)/vid.FrameRate; % Rewind
        FirstFrame = readFrame(vid); % First Frame as a background
        trackedObj = zeros(vidHeight,vidWidth,NewLastFrame);
        newrgb = zeros(vidHeight,vidWidth,NewLastFrame);
        [m, n, q] = size(trackedObj);
        timestep = vid.Duration/LastFrame;

        A=zeros(size(single(trackedObj))); % initializes flattened video
        x=zeros(1,NewLastFrame-1); % initializes x component storage
        y=zeros(1,NewLastFrame-1); % initializes y component storage
        qstart = NaN;
        h = waitbar(0,'Initializing waitbar...');
        set(h,'Name','Progress Bar');
        
        for i = NewFirstFrame:NewLastFrame-1
            waitbar(i/(NewLastFrame-1),h,sprintf('%0.2f%% along...',i/(NewLastFrame-1)*100))

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

        % Reposition newx and newy so the beginning of the track/ car is
        % located at (0,0)
        newx2 = zeros(1,b-1);
        newy2 = zeros(1,b-1);
        
        for i = NewFirstFrame:b-1
           newx2(i) = newx(i) - newx(NewFirstFrame);
           newy2(i) = newy(i) - newy(NewFirstFrame);
        end 
        
        % Preallocate
        posmag = zeros(1,b-1);
        time = zeros(1,b-1);
        for i = NewFirstFrame:b-2
            time(i+1) = time(i) + timestep;
        end
        for i = NewFirstFrame:b-1
            posmag(i) = sqrt((newx2(i)).^2+(newy2(i)).^2);
        end

        % Plot the path and position of the car
        figure(4); clf(4);
        subplot(2,1,1)
        plot(newx2,newy2);
        title('Path of the car')
        xlabel(sprintf('%s', units))
        ylabel(sprintf('%s', units))
        subplot(2,1,2)
        scatter(time,posmag,'.');
        title('Position vs. Time')
        ylabel(sprintf('%s', units))
        xlabel('Seconds')
    end
end




