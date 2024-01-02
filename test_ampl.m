clc;close;clear;clear sound;close all;

% 
Fcarr = 2300;
ampls = linspace(-5,5,100);
resp = ampls;
for i=1:100
    
    Fs = 44100;
    t = (1:(300)) / Fs;
    x = cos(2*pi*Fcarr.*t)*ampls(i);


    [m,t,Fs] = fmdemod_full(x,Fs);

    resp(i) = m(end);
end

figure;
hold on;
plot(ampls, resp);
% plot(1900,0,'.');
% plot([freqs(1),freqs(end)],[resp(1),resp(end)]);
% m = (resp(end)-resp(1))/(freqs(end)-freqs(1));

% plot(freqs, (freqs-1900)/44100*pi*2, '.');