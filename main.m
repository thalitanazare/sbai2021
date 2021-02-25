%% SBAI 2021
close all
clear all
clc
intvalinit('displayinfsup')
%% PARAMETROS GERAIS
Ns = 1000; % number of iterations
A = 1; % Amplitude
f = 0.055; % frequency
M = 3; % filter order
mu = 0.055; % step-size
I = 500; % ensemble number
%% ========================== SEM INTERVALO ===============================
% Sinal
phi=0.4;
s=A*sin(2*pi*f*(0:Ns-1)+phi);  % signal
v = 0.28*randn(1,Ns); % noise - mesmo para todos os casos
Num = fir1(M,0.4); % - mesmo para todos os casos
fnoise = filter(Num,1,v); % - mesmo para todos os casos
d=s+fnoise; % desired signal 
x = s+v;

% ----------------------------- L M S -------------------------------------
wl = 0.27*ones(1,M); % tive q normalizar (para ru�do alto colocar 0.3)
% Blackmann Window
for i = 1:M-1
wl(i+1)=(0.42 + 0.5*(2*pi/(M-1)) + 0.08*(4*pi/(M-1)));
yl = zeros(1,Ns);
JLMS = zeros(1,Ns);% Prepares to accumulate MSE*I
for n=M:Ns
    x1=x(n:-1:n-M+1);
    yl(n)=wl*x1';
    el(n)=d(n)-yl(n);
    wl(i+1)=wl(i)+2*mu*el(n)*x1(i);
   % JLMS(1,n)=JLMS(1,n)+el(1,n).^2; %Learning curve
end
end
%JLMS=el^2;
% ----------------------------- R L S -------------------------------------
wr = 0.27*ones(M,1);
delay1 = (M-1)/2;% delay generated by the reference transformer
lambda = 1;
laminv = 1/lambda; % inverse forgetting factor
delta = 1.0;
P = delta*eye(M); % Inverse correlation matrix
p = max(M); % Control loop 
U = x(M:-1:1)';

for i = 1:M-1
wr(i+1)=(0.42 + 0.5*(2*pi/(M-1)) + 0.08*(4*pi/(M-1)));
yr =zeros(1,Ns);
JRLS = zeros(Ns,1);
for m = p:Ns   
    dr(m) = d(m-delay1);   % Desired output  - input delayed
    yr(m) = wr'*U;
    er(m) = dr(m)-yr(m);               % Error    
    % Parameters for efficiencyThis is some text
    Pi = P*U;
    % Filter gain vector update
    k = Pi/(lambda+U'*Pi);
    % Inverse correlation matrix update
    P = (P - k*U'*P)*laminv;
    % Filter coefficients adaption
    wr(i+1) = wr(i) + k(i)*er(m);
    U = [x(m); U(1:M-1)];  
    w1 = wr(1:M);                    % Coeficientes 
    y1(m) = w1'*U;                    % Equalizated output
    JRLS(m) = JRLS(m)+er(m)^2;        % Learning curve
end
end
% JRLS = (JRLS/I)'; 

%% ========================== COM INTERVALO ===============================
%Sinal
phi_int = infsup(0,0.4);
s_int = A*sin(2*pi*f*(0:Ns-1)+phi_int);  % signal
d_int = s_int+fnoise;                   % desired signal
x_int = s_int+v;
% ----------------------------- L M S -------------------------------------
wl_int = infsup(0.2,0.27)*(ones(1,M));   
%wl_int = 0.37*intval(ones(1,M)); 
% Blackmann Window
for i = 1:M-1
wl_int(i+1)=(0.42 + 0.5*(2*pi/(M-1)) + 0.08*(4*pi/(M-1)));
yl_int = intval(zeros(1,Ns));
JLMS_int = intval(zeros(1,Ns)); % Prepares to accumulate MSE*I
for n=M:Ns
    x1=x_int(n:-1:n-M+1);
    yl_int(n)=wl_int*x1';
    el_int(n)=d_int(n)-yl_int(n);
    wl_int(i+1)=wl_int(i)+2*mu*el_int(n)*x1(i);
%     JLMS_int(1,n)=JLMS_int(1,n)+el_int(1,n).^2; %Learning curve
end
end


% ----------------------------- R L S -------------------------------------
% Sinal
% phi � o mesmo sem intervalo
% s continua sendo o mesmo
% logo todo sinal gerado sem intervalo entra aqui no RLS
%wr_int = 0.37*intval(ones(M,1)); 
wr_int = infsup(0.19,0.27)*(ones(M,1));
for i = 1:M-1
wr_int(i+1)=(0.42 + 0.5*(2*pi/(M-1)) + 0.08*(4*pi/(M-1)));
yr_int = intval(zeros(1,Ns));
JRLS_int = intval(zeros(Ns,1));
for m = p:Ns   
    dr_int(m) = d(m-delay1);   % Desired output  - input delayed
    %yr_int(m) = wr_int'*U;
    er_int(m) = dr_int(m)-yr_int(m);               % Error    
    % Parameters for efficiencyThis is some text
    Pi = P*U;
    % Filter gain vector update
    k = Pi/(lambda+U'*Pi);
    % Inverse correlation matrix update
    P = (P - k*U'*P)*laminv;
    % Filter coefficients adaption
    wr_int(i+1) = wr_int(i) + k(i)*er_int(m);
    U = [x(m); U(1:M-1)];  
    w1_int = wr_int(1:M);                    % Coeficientes 
    y1_int(m) = w1_int'*U;                    % Equalizated output
    JRLS_int(m) = JRLS_int(m)+er_int(m)^2;        % Learning curve
end
end


%% ============================ FIGURAS ==================================
% figure (1) % s e lms
% plot(d(200:300),'-*','LineWidth',2)
% hold on
% plot(d_int(200:300))
% title('Sinal Desejado')
% figura igual do artigo

% 
figure (2)
plot(s_int(100:250))
hold on
plot(x_int(100:250))
grid on

% figure (2) % Compara��o entre desejado intervalar e normal
% plot(yl(100:500),'LineWidth',2)
% hold on
% plot(s_int(100:500),'LineWidth',2)
% legend('Sinal Desejado','Sinal Filtrado','Sinal+Ru�do')
% title('LMS')

% figure (3) % Compara��o entre desejado intervalar e normal
% plot(yr(100:500),'LineWidth',2)
% hold on
% plot(s_int(100:500),'LineWidth',2)
% legend('Sinal Desejado','Sinal Filtrado','Sinal+Ru�do')
% title('RLS Sem Intervalo')

figure (4) % Compara��o entre desejado intervalar e normal
plot(d_int(100:250),'b')
hold on
plot(yl_int(100:250),'k')
title('LMS Intervalar')
grid on

figure (5) % Compara��o entre desejado intervalar e normal
plot(d_int(100:250),'b')
hold on
plot(y1_int(100:250),'k')
title('RLS Intervalar')
grid on

% Estimation espectrum
% Ym1=abs(fft(u1(4*p+1:4*p+Nppc)))/Nppc; %fft u1
% Ym2=abs(fft(d_int.mid)); %fft u2
% Ye=abs(fft(y1_int.mid));  %fft equalizated output 


% figure
% stem(Ym2,'*')
% hold on
% stem(Ye,'o'), title('Estimation espectrum')
% legend('desejada','out')



%% Learning Curve
% JLMS = el_int.^2;      % Learning curve LMS
% JRLS = (JRLS_int.mid/I)'; 
% JLMS = (JLMS.mid);
% figure;
% nn=0:Ns-1;
% plot(nn,10*log10(JLMS))
% hold on
% plot(nn,10*log10(JRLS)),legend('LMS','RLS'),title('Learning curve')
% ylabel('MSE (Escala Logar�tmica)'), xlabel('Iteration Number')
