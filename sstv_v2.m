clc;clear;clear all;close all;

[x,Fs] = audioread("pd90_test1.wav");
[x,Fs] = audioread("20231001_004856.wav");


T_START = 0;
T_STOP = 2;

noise = (rand(1,length(x)) - 0.5) * 0.5;
% x = x + noise';

% [x,Fs] = audioread("record_cut.mp3");
% x = sum(x,2);

% sstv_flt = fir1(500,[1100/Fs,2500/Fs]);
% x = filter(sstv_flt,1,x);

% [x,Fs] = audioread("record_cut.mp3");

% flt = fir1(500,[1000/Fs,2500/Fs]);
% x = filter(flt,1,x);

[y,t,Fs] = fmdemod_full(x,Fs,false);


y = y((t<T_STOP) & (t>T_START));
t = t((t<T_STOP) & (t>T_START));

PIXEL_TIME = 0.000532; % PD-90: 532 us


transform_freq = @(f) sin((f-1900) / 44100 * 2*pi);

SYNC = transform_freq(1200);
BLACK = transform_freq(1500);
WHITE = transform_freq(2300);

translate_val = @(v) v / WHITE * 0.5 + 0.5;
y = translate_val(y);
SYNC = translate_val(SYNC);
BLACK = translate_val(BLACK);
WHITE = translate_val(WHITE);

plot(t,y);
hold on;
disp("Im workding")

plot([t(1),t(end)],[SYNC,SYNC]);
plot([t(1),t(end)],[WHITE,WHITE]);
plot([t(1),t(end)],[BLACK,BLACK]);
