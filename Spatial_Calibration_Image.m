% Code for calibrating camera from pixles to distance. This is adapted from
% http://www.mathworks.com/matlabcentral/answers/56087-how-can-i-find-the-spatial-calibration-factor
% This calibrates for a picture of the track, not a video
% Clear workspace and command window
clear all
clc

% Import video file of interest
filename= uigetfile({'*.*'},'Select the desired image file');
if isequal(filename,0)
    fprintf('No file was selected \n')
else
    fprintf('%s was selected \n',filename)
end

% Open Video, Collect info from the file
img = imread(filename);
%i= readFrame(img);
% end
%imshow(mid)
size(img);
level = graythresh(img); % Threshold level for black/ white
I = im2bw(img,level); % Convert image to black and white (binary)

% Insert image into figure

[rows, columns] = size(I);
subplot(2,1,1);
imshow(I); % Shows frame grab converted to black and white
set(gcf, 'name','Spatial Calibration','numbertitle','off');

units = 'pixels';
Calibration = 1.0;
button = 1;
while button ~= 4
    % User input of required action
    button = menu('Pick One','Measure','Calibrate','Automatic A in Dr. Owkes Class','Finish');
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
        defaultVals = {'5','Feet'};
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
    
    
    
    