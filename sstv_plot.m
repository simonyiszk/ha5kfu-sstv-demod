clc;clear;clear all;close all;

% [x,Fs] = audioread("pd90_test1.wav");
[x,Fs] = audioread("record_audacity_filtered.mp3");
% [x,Fs] = audioread("record.mp3");
% noise = (rand(1,length(x)) - 0.5) * 0.5;

% x = x + noise';
% [x,Fs] = audioread("20231001_004856.wav");
% [x,Fs] = audioread("PD120 SSTV Test Recording.mp3");
x = sum(x,2);

MODE = "PD90";
SHOW_COMPONENTS = false;


if MODE=="PD90"
IMAGE_WIDTH = 320; % px
PIXEL_TIME = 532; % us
end
if MODE=="PD120"
IMAGE_WIDTH = 640; % px
PIXEL_TIME = 190; % us
end

% [x,Fs] = audioread("record_cut.mp3");
% x = sum(x,2);

% sstv_flt = fir1(500,[1100/Fs,2500/Fs]);
% x = filter(sstv_flt,1,x);

% [x,Fs] = audioread("record_cut.mp3");

% flt = fir1(500,[1000/Fs,2500/Fs]);
% x = filter(flt,1,x);

[y,t,Fs] = fmdemod_full(x,Fs,false);


t_start = 0;
t_stop = 200;
y = y((t<t_stop) & (t>t_start));
t = t((t<t_stop) & (t>t_start));

PIXEL_TIME = PIXEL_TIME / 1000000; % us -> s

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

plot([t(1),t(end)],[SYNC,SYNC]);
plot([t(1),t(end)],[WHITE,WHITE]);
plot([t(1),t(end)],[BLACK,BLACK]);


in_sync_raw = (y>2*SYNC)&(y<0);
hsync_pulses = zeros(length(in_sync_raw),1);

sync_len_cntr = 0;
sync_sep_cntr = 0;
SYNC_MIN_CNT = floor(0.01*Fs); % 0.01s minimum sync time
SYNC_MIN_SEP = floor(0.15 * Fs);

for i=1:length(t)
    sync_len_cntr = sync_len_cntr + 1;
    if ~in_sync_raw(i)
        if sync_len_cntr >= SYNC_MIN_CNT
            hsync_pulses(i) = 1;
        end
        sync_len_cntr = 0;
    end
end
plot(t,hsync_pulses,'LineWidth',2);


% stop;



limit = PIXEL_TIME * Fs;

Ts = 1/Fs;
cntr = zeros(1,length(y));
for i=1:(length(cntr))
    if hsync_pulses(i)
        cntr(i) =0;
    else
        if i>1
            cntr(i) = cntr(i-1) + Ts;
        end
    end
end
line_cntr = mod(cntr / (PIXEL_TIME),IMAGE_WIDTH); % mod tuened off
take_sample = floor(line_cntr) < floor([line_cntr(2:end),IMAGE_WIDTH]);
samples = y(take_sample);


img = zeros(IMAGE_WIDTH*4,130)';
line = 0;
pos = 1;
for i=1:length(y)
    if hsync_pulses(i)
        line = line+1;
        pos = 0; % for the 0.01s of delay between detection and start of image
    end
    if take_sample(i) & line >0
        pos = pos + 1;
        sample = y(i);
        if pos>0
            img(line,pos) = sample;
        end
    end
end


y1 = img(:,(1:IMAGE_WIDTH)+IMAGE_WIDTH*0);
cr = img(:,(1:IMAGE_WIDTH)+IMAGE_WIDTH*1);
cb = img(:,(1:IMAGE_WIDTH)+IMAGE_WIDTH*2);
y2 = img(:,(1:IMAGE_WIDTH)+IMAGE_WIDTH*3);



if SHOW_COMPONENTS
    % toDO: 
    figure;
    imshow(y1);
    title('Y1');
    figure;
    imshow(y2);
    title('Y2');
    figure;
    imshow(cr);
    title('cr');
    figure;
    imshow(cb);
    title('cb');
end



img2 = zeros(size(img,1)*2,IMAGE_WIDTH,3);
for i=1:size(img,1)
    % https://github.com/rimio/libsstv/blob/01127ce30ee17bdb97fa18342e3f7da95e4dc309/src/sstv.c#L16-L22
    % no idea how it changed from ycrcb, but it seems like this is the
    % correct matrix
    img2(2*i,:,1) = y1(i,:) + 1.4*cr(i,:) - 179/256;
    img2(2*i+1,:,1) = y2(i,:) + 1.4*cr(i,:) - 179/256;
    img2(2*i,:,3) = y1(i,:) + 1.772*cb(i,:) - 226/256;
    img2(2*i+1,:,3) = y2(i,:) + 1.772*cb(i,:) - 226/256;
    img2(2*i,:,2) = 1.0*y1(i,:) - 0.7141* cr(i,:) - 0.344*cb(i,:) + 135/256;
    img2(2*i+1,:,2) = 1.0*y2(i,:) - 0.714* cr(i,:) - 0.344*cb(i,:) + 135/256;
end

imshow(img2);

if SHOW_COMPONENTS
    figure;
    imshow(img2(:,:,1));
    title('R');
    
    figure;
    imshow(img2(:,:,2));
    title('G');
    
    figure;
    imshow(img2(:,:,3));
    title('B');
end