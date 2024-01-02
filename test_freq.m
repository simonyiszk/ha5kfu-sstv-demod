clc;close;clear;clear sound;close all;

% 
N= 200;
freqs = linspace(1200,2300,N);
resp = freqs;
for i=1:N
    
    Fs = 44100;
    t = (1:(300)) / Fs;
    Fcarr = freqs(i)
    x = cos(2*pi*Fcarr.*t);


    [m,t,Fs] = fmdemod_full(x,Fs);

    resp(i) = m(end);
end

figure;
hold on;
plot(freqs, resp,'.');
plot(1900,0,'.');
% plot([freqs(1),freqs(end)],[resp(1),resp(end)]);
m = (resp(end)-resp(1))/(freqs(end)-freqs(1));

plot(freqs, ((freqs-1900)/44100*pi*2), '.');