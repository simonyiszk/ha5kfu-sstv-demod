function plotfft(x,Fs)
    y = fft(x);
    y = y / length(y);
    y = 20*log10(abs(y));
    freq = linspace(1,Fs,length(y));
    figure;
    scatter(freq,y,'.');
end