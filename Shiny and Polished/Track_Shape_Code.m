clc;clf;close all;
% Import video file of interest
filename= uigetfile({'*.*'},'Select the desired video file');
if isequal(filename,0)
    fprintf('No file was selected \n')
else
    fprintf('%s was selected \n',filename)
end


% Open Image, Collect info from the file
img = imread(filename);

size(img);
level = graythresh(img); % Threshold level for black/ white
I = im2bw(img,level); % Convert image to black and white (binary)

% Insert image into figure

[rows, columns] = size(I);
figure(1); clf(1);
imshow(I); % Shows frame grab converted to black and white
set(gcf, 'name','Spatial Calibration','numbertitle','off');

units = 'pixels';
Calibration = 1.0;
button = 1;
while button ~= 3
    % User input of required action
    button = menu('Pick One','Measure','Calibrate','Proceed');
    if button == 3 % EXIT
        break; % End because user clicked exit
    elseif button == 1 % Measure
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
    end
end
    RealDistance = dip*Calibration;
    caption = sprintf('Intensity Profile Along Line \nThe distance = %0.3f pixels = %0.2f %s', dip, RealDistance, units);
    title(caption);
 
figure(2); clf(2);
bpoint=imread(filename);
imshow(filename);
 uiwait(msgbox('Click a point at the top left corner of the track THEN click a point at the bottom right corner of the track','','modal'));
     [x,y]=ginput(2);
        a=x(1); 
        b=x(2);
        c=y(1);
        d=y(2);
        
 xmin=a;
 ymin=c;
 width=(b-a);
 height=(d-c);
I2=imcrop(bpoint,[xmin ymin width height]);

I3=imadjust(I2,[.2 .3 0; .6 .7 1],[]);
red = I3(:,:,1); % Red channel
green = I3(:,:,2); % Green channel
blue = I3(:,:,3); % Blue channel
[m,n,p]=size(I2);
bluecolor=zeros(m,n);
A = zeros(m,n);
x=1:n;

for i=1:m
    for j=1:n
        if  blue(i,j) >=60 && red(i,j) <=10 && green(i,j) <=10
            bluecolor(i,j)=1;
        else
            bluecolor(i,j)=0;
        end
    end
end

%
y=zeros(1,n);
neigh=10;
for i = 1:n
   
   s = regionprops(bluecolor(:,max(1,i-neigh):min(n,i+neigh)),'centroid');
    if max(bluecolor(:,i)) == 1 % if there is a centroid found store it in the following way
        y(i)=s.Centroid(2); % checks x component
    end
end

for i=1:n-1 % loop to find (0,0) centroids and readjust them through linear interpolation
    if y(i) == 0
       y(i) = NaN; % new y value
    end
end
% Convert from pixels to units with the calibration factor
newx = x*Calibration;
newy = -y*Calibration;
newm = -m*Calibration;
newn = n*Calibration;
figure(3); clf(3);
scatter(newx,newy,'.')
axis([0,newn,newm,0]);
title('Shape of the Track')
xlabel(sprintf('%s', units))
ylabel(sprintf('%s', units))
hold on
degree = inputdlg('Enter degree of polynomial',...
             'Line Fitting', [1 50]);
d=str2num(char(degree));
createfigure(newx,newy,d,newx(end))


