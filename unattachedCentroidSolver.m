% Centroid Finder
% This component of the code takes the black and white series of matrices
% titled trackedObj and condenses the white pixels to a single point.
% This centroid can then be utilized with the frame rate to determine
% velocity, acceleration, drag coefficient, friction coefficient, etc.

% initialize loop
A=zeros(size(single(trackedObj))); % initializes flattened video
x=zeros(q); % initializes x component storage
y=zeros(q); % initializes y component storage

% loop that finds the centroid of the white pixels
for i=1:q % runs for every matrix in the set
    A(:,:,i)=single(trackedObj(:,:,i)); % this flattens the ith matrix
    s=regionprops(A(:,:,i),'centroid'); % this calculates the centroid
    if length(s)>0 % if there is a centroid found store it in the following way
    x(i)=s.Centroid(1); % stores x component
    y(i)=s.Centroid(2); % stores y component
    end
end
