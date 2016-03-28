clc;clear all;clf;close all;
I=imread('Track Shape 2.jpg');
imshow('Track Shape 2.jpg');
 uiwait(msgbox('Click a point left of the track THEN click a point right of the track','','modal'));
     [x,y]=ginput(2);
a=x(1)
b=x(2) 
uiwait(msgbox('Click a point above the top of the track THEN click a point below the bottom of the track','','modal'));
     [x,y]=ginput(2);
        c=y(1)
        d=y(2)

 xmin=a
 ymin=c
 width=(b-a)
 height=(d-c)
I2=imcrop(I,[xmin ymin width height]);


red = I2(:,:,1); % Red channel
green = I2(:,:,2); % Green channel
blue = I2(:,:,3); % Blue channel
[m,n,p]=size(I2);

bluecolor=ones(m,n);
for i=1:m
    for j=1:n

if red(i,j) <=75 && green(i,j) <= 110 && blue(i,j) <=140
    bluecolor(i,j)=1;
else
    bluecolor(i,j)=0;
end
    end
end
x=[1:n];
for i=1:n
 a=bluecolor(:,i);
 index=find(a);
b=index(1);
 e=index(end);
 y(i)=((b+e)/2);

end
figure(1)
scatter(x,-y,'.')
axis([0,n,-m,0]);