I=imread('Blue Drawn Line.jpg');

red = I(:,:,1); % Red channel
green = I(:,:,2); % Green channel
blue = I(:,:,3); % Blue channel


BW = im2bw(blue, .5);

spy(BW)