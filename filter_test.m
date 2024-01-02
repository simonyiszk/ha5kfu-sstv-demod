clc;close all; clear sound;
[x,Fs] = audioread("record_cut.mp3");

flt = fir1(12,[500/Fs,3000/Fs],'bandpass');
x = filter(flt,1,x);
freqs(flt,1);
disp("Done filtering");
x = x(1:(2*Fs));
sound(x,Fs);