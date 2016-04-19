% Centroid Finder
%cvid=VideoReader(trackedObj);
%centroids=zeros(1,q);
%A=zeros(size(single(trackedObj)));
%B=zeros(size(A));
% s=zeros(1,q);
% x=zeros(1,q);
% y=zeros(1,q);
for i=1:q
    A(:,:,i)=single(trackedObj(:,:,i));
    %B(i)=single(A(i));
%     [x,y]=find(A);
%     centroids(1,i)=[mean(x),mean(y)];
    s=regionprops(A(:,:,i),'centroid');
    %centroids(i)=cat(1,s.Centroid);
    if isequal(s,0)==0
    i=i+1;
    else
    x(i)=s.Centroid(1);
    y(i)=s.Centroid(2);
    end
    %COM=s(:,:,i).Centroid;
    % stopped using cat() function
end

