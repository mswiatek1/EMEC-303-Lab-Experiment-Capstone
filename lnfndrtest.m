
clc;clf;close all;
% Import video file of interest
filename= uigetfile({'*.*'},'Select the desired video file');
if isequal(filename,0)
    fprintf('No file was selected \n')
else
    fprintf('%s was selected \n',filename)
end

bpoint=imread(filename);
imshow(filename);
 uiwait(msgbox('Click a point left of the track THEN click a point right of the track','','modal'));
     [x,~]=ginput(2);
a=x(1); 
b=x(2) ;
uiwait(msgbox('Click a point above the top of the track THEN click a point below the bottom of the track','','modal'));
     [~,y]=ginput(2);
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

% figure(1); clf(1);
% imshow(I2);
%      uiwait(msgbox('Click the "lightest" suction cup for color analysis and then press enter','','modal'));
% readpix = impixel(I2);
% blackr = readpix(1); % Red value of black pixel
% blackg = readpix(2); % Green Value of plack pixel
% blackb = readpix(3); % Blue value of black pixel

bluecolor=zeros(m,n);





for i=1:m
    for j=1:n
        if  blue(i,j) >=60 && red(i,j) <=10 && green(i,j) <=10
            bluecolor(i,j)=1;
else
    bluecolor(i,j)=0;
        end
    end
end


x=1:n;
for i=1:n
 a=bluecolor(:,i);
 bpoint=find(a);
top=bpoint(1);
bottom=bpoint(end);
 y(i)=((top+bottom)/2);
end
spy(bluecolor)
 
%  [Ix,Iy]=find(bluecolor)

figure(1)
scatter(x,-y,'.')
axis([0,n,-m,0]);