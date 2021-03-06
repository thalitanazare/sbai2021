% Interval RLS Algorithm
% 25/02/2021
clear all;close all;clc
intvalinit('DisplayInfsup')

% Parameters
Ns = 1000; % number of iterations
A = 1; % Amplitude
f = 0.055; % frequency
M = 3; % filter order
mu = 0.055; % step-size
I = 500; % ensemble number

% Sinal
phi=infsup(0,0.4);
s=A*sin(2*pi*f*(0:Ns-1)+phi);  % signal
v = 0.28*randn(1,Ns); % noise - the same for all the cases
Num = fir1(M,0.4); % the same for all the cases
fnoise = filter(Num,1,v); % the same for all the cases
x = s+v; % signal with noise
d=s+fnoise; % desired signal 

% Start Algorithm
w = intval(0.1)*ones(M,1);
delay1 = (M-1)/2;% delay generated by the reference transformer
lambda = intval(1);
%laminv = 1/lambda; % inverse forgetting factor
delta = 1;
R = delta*eye(M); % Inverse correlation matrix
p = max(M); % Control loop 
U = x(M:-1:1)';

for i = 1:M-1
w(i+1)=(0.42 + 0.5*(2*pi/(M-1)) + 0.08*(4*pi/(M-1)));
y = intval(zeros(1,Ns));
JRLS = intval(zeros(Ns,1));
for m = 1:1
    %d(m) = d(m-1); % Desired output  - input delayed
    y(m) = w'*U;
    e(m) = d(m)-y(m); % Error    
    % Filter gain vector update
    Ri = inv(R)*U;
    g = Ri/(lambda+U'*Ri);
    % Inverse correlation matrix update
    R = inv(lambda)*(R-g*U'*R);
    % Filter coefficients adaption
    w(i+1) = w(i) + g(i)*e(m);
    U = [x(m); U(1:M-1)];  
    wr = w(1:M); % Coeficientes 
    yr(m) = wr'*U; % Equalizated output
    JRLS(m) = JRLS(m)+e(m)^2; % Learning curve
end
end
disp(w)