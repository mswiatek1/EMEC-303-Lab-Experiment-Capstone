% EMEC 303 - Numerical Solutions for Car Traveling Down a Track
% setting up position vectors
x=zeros(1,N);
y=zeros(1,N);
t=zeros(1,N);
xprime=zeros(1,N);
x(1)=0; % initial x position
xo=0; % initial x position
xf=8; % final x position
y(1)=4; % initial y position
t(1)=0; % initial time
xprime(1)=0; % initial x direction velocity
N=100; % number of steps
stepsize=(xf-xo)/N; % step size
tstep=.1; % time step

for i=2:N
    x(i)=x(i-1)+stepsize;
    y(i)=sin(x(i))+4;
    t(i)=t(i-1)+tstep;
    xprime(i)=(x(i)-x(i-1))/tstep;
end

% Case 1: PE, KE, and gravity
g=32.2; % gravity (ft/s^2)
vo=0; % initial velocity (ft/s)
yo=4; % initial height (ft)
v1(i)=sqrt(vo^2-2*g*(y(i)-yo));

a1=zeros(1,N);
for i=1:N-1
    a1(i)=(v1(i)-v1(i+1))/tstep;
end

figure(1)
subplot(3,1,1)
plot(x,y)
subplot(3,1,2)
plot(t,v1)
subplot(3,1,3)
plot(t,a1)

% Case 2: PE, KE, gravity, and Friction
g=32.2; % gravity (ft/s^2)
vo=0; % initial velocity (ft/s)
yo=4; % initial height (ft)
xo=0; % initial horizontal distance (ft)
uk=.2; % coefficient of kinetic friction
v2(i)=sqrt(vo^2-2*g*(y(i)-yo)-2*g*uk*(x(i)-xo));

a2=zeros(1,N);
for i=1:N-1
    a2(i)=(v2(i)-v2(i+1))/tstep;
end

figure(2)
subplot(3,1,1)
plot(x,y)
subplot(3,1,2)
plot(t,v2)
subplot(3,1,3)
plot(t,a2)

% Case 3: PE, KE, gravity, friction, and track shape
g=32.2; % gravity (ft/s^2)
vo=0; % initial velocity (ft/s)
yo=4; % initial height (ft)
xo=0; % initial horizontal distance (ft)
uk=.2; % coefficient of kinetic friction
ro=0; % initial radius of curvature (ft)
xoprime=0; % initial velocity in x-direction (ft/s)
v3(i)=sqrt((vo^2*(1-(uk/ro)*(xprime(i)-xoprime))-2*g*(y(i)-yo)-2*g*uk*(x(i)-xo))/(1+(uk/r)*(xprime(i)-xoprime)));

a3=zeros(1,N);
for i=1:N-1
    a3(i)=(v3(i)-v3(i+1))/tstep;
end

figure(3)
subplot(3,1,1)
plot(x,y)
subplot(3,1,2)
plot(t,v3)
subplot(3,1,3)
plot(t,a3)

% Case 4: PE, KE, gravity, friction, track shape, and air resistance
g=32.2; % gravity (ft/s^2)
vo=0; % initial velocity (ft/s)
yo=4; % initial height (ft)
xo=0; % initial horizontal distance (ft)
uk=.2; % coefficient of kinetic friction
ro=0; % initial radius of curvature (ft)
xoprime=0; % initial velocity in x-direction (ft/s)
k=5; % drag coefficient
m=.15; % mass of car (lb)
v4(i)=sqrt((vo^2*(1-((uk/ro)+(k/m))*(xprime(i)-xoprime))-2*g*(y(i)-yo)-2*g*uk*(x(i)-xo))/(1+((uk/r)+(k/m))*(xprime(i)-xoprime)));

a4=zeros(1,N);
for i=1:N-1
    a4(i)=(v4(i)-v4(i+1))/tstep;
end

figure(4)
subplot(3,1,1)
plot(x,y)
subplot(3,1,2)
plot(t,v4)
subplot(3,1,3)
plot(t,a4)
