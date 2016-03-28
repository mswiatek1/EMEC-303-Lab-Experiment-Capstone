I=imread('Blue Drawn Line.jpg');

red = I(:,:,1); % Red channel
green = I(:,:,2); % Green channel
blue = I(:,:,3); % Blue channel
[m,n,p]=size(I);

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
figure(2)
spy(bluecolor)
