clc;close;clear;clear sound;close all;
[x,Fs] = audioread("pd90_test1.wav");
% x = x';
% [x,Fs] = audioread("PD120 SSTV Test Recording.mp3");
% x = cos(2*pi*1200 * (1:length(x))/Fs)';

t = (1:(2*Fs)) / Fs;

Fcarr = linspace(1000,2500,2*Fs);
% Fcarr = 1200;
x = cos(2*pi*Fcarr.*t);

plotfft(x,Fs);
title("Before decimation");
% decimate

DECIMATION_FACTOR = 5;

x = x(1:DECIMATION_FACTOR:end);
Fs = Fs / DECIMATION_FACTOR;
plotfft(x, Fs);
title("After decimation");

Fosc = 1900;
t = (1:length(x)) / Fs;
osc = exp(2j*pi*Fosc*t);

prod = osc .* x;

plotfft(prod,Fs);
title("After mix");

flt = fir1(10,2000/Fs);
f = filter(flt,1,prod);

plotfft(f,Fs);
title("After filtering");

figure;
scatter(real(f),imag(f));
title("Consteallation after IQ mixing");

m = fmdemod_iq(f);

figure;
plot(t,m);
title("After demod");


flt2 = fir1(30,0.1);
m = filter(flt2, 1, m);

m = m(1:10:end);
t = t(1:10:end);



figure;
plot(t,m);
title("After demod flt");
