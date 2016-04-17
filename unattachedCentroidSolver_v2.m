% Centroid Finder
% This component of the code takes the black and white series of matrices
% titled trackedObj and condenses the white pixels to a single point.
% This centroid can then be utilized with the frame rate to determine
% velocity, acceleration, drag coefficient, friction coefficient, etc.

% initialize loop
A=zeros(size(single(trackedObj))); % initializes flattened video
x=zeros(1,q-1); % initializes x component storage
y=zeros(1,q-1); % initializes y component storage

% loop that finds the centroid of the white pixels
for i=1:q-1 % runs for every matrix in the set
    A(:,:,i)=single(trackedObj(:,:,i)); % this flattens the ith matrix
    s=regionprops(A(:,:,i),'centroid'); % this calculates the centroid
    if length(s)>0 % if there is a centroid found store it in the following way
        x(i)=s.Centroid(1); % checks x component
        y(i)=s.Centroid(2); % checks y component
    end
end
for i=2:q-2 % loop to find (0,0) centroids and readjust them through linear interpolation
    if x(i)==0 && y(i)==0
        x(i)=abs((x(i-1)-x(i+1))/2); % new x value 
        y(i)=abs((y(i-1)-y(i+1))/2); % new y value
    end
end
j=10; % adjust value to negate 0 values at begining/end of clip
xc=x(4*j:q-j); % adjusted x values
yc=y(4*j:q-j); % adjusted y values