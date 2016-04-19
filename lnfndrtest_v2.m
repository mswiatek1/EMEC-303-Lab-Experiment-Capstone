clc;clear all;clf;close all;

% Import video file of interest
filename= uigetfile({'*.*'},'Select the desired video file');
if isequal(filename,0)
    fprintf('No file was selected \n')
else
    fprintf('%s was selected \n',filename)
end


I=imread(filename);
figure(1); clf(1);
imshow(filename);
 uiwait(msgbox('Click a point left of the track THEN click a point right of the track','','modal'));
     [x,y]=ginput(2);
a=x(1);
b=x(2); 
uiwait(msgbox('Click a point above the top of the track THEN click a point below the bottom of the track','','modal'));
     [x,y]=ginput(2);
        c=y(1);
        d=y(2);

 xmin=a;
 ymin=c;
 width=(b-a);
 height=(d-c);
I2=imcrop(I,[xmin ymin width height]);

I3 = imadjust(I2,[.2 .3 0; .6 .7 1],[]);
red = I3(:,:,1); % Red channel
green = I3(:,:,2); % Green channel
blue = I3(:,:,3); % Blue channel
[m,n,p]=size(I3);

bluecolor=zeros(m,n);
for i=1:m
    for j=1:n

if red(i,j) == 0 && green(i,j) == 0 && blue(i,j) >= 60 % && blue(i,j) >=60 % && red(i,j) >=60 % && green(i,j) >= 60 
    bluecolor(i,j)=1;
else
    bluecolor(i,j)=0;
end
    end
end
x=[1:n];

% for i=1:n
%  a=bluecolor(:,i);
%  index=find(a);
% q=index(1);
%  e=index(end);
%  y(i)=((q+e)/2);
% 
% end

for i = 1:n
   A(:,i) = single(bluecolor(:,i));
   s = regionprops(A(:,i),'centroid');
    if max(bluecolor(:,i)) == 1 % if there is a centroid found store it in the following way
        y(i)=s.Centroid(2); % checks x component
    end
end

for i=1:n-1 % loop to find (0,0) centroids and readjust them through linear interpolation
    if y(i) == 0
       y(i) = NaN; % new y value
    end
end


figure(2); clf(2);
scatter(x,-y,'.')
axis([0,n,-m,0]);



