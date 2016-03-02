R=[1 2 ;3 4];
G=[1 2 ; 7 5];
B=[1 3; 6 9];
n=2;
bluecolor=ones(2,2);
for i=1:n
    for j=1:n

if R(i,j) >=0 && G(i,j) <= 10 && B(i,j) >=5
    bluecolor(i,j)=1;
else
    bluecolor(i,j)=0;
end
    end
end
bluecolor