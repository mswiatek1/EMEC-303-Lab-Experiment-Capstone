filename= uigetfile({'*.*'},'Select the desired image file');
if isequal(filename,0)
    fprintf('No file was selected \n')
else
    fprintf('%s was selected \n',filename)
end

a=imread(filename);
[x1,y1,z1]=size(a);
level=graythresh(a);
BW=im2bw(a,level);
background = imdilate(BW, ones(x1,y1,z1));
diff = imabsdiff(BW, background);
s=regionprops(diff,'centroid');
centroids=cat(1, s.Centroid);

figure(1)
imshow(a)
hold on
plot(centroids(:,1),centroids(:,2),'r*')
hold off

figure(2)
imshow(diff)
hold on
plot(centroids(:,1),centroids(:,2),'r*')
hold off

