function [y,t, Fs] = fmdemod_full(x,Fs,debug)
arguments
    x double;
    Fs(1,1) double;
    debug(1,1) logical = false;
end
%FMDEMOD_FULL Summary of this function goes here
%   Detailed explanation goes here

assert(Fs == 44100,"Wrong sampling rate!");
if size(x,1) > 1
    x = x';
end

if debug
    plotfft(x,Fs);
    title("Before mixing");
end

Fosc = 1900;
t = (1:length(x)) / Fs;
osc = exp(2j*pi*Fosc*t);

prod = osc .* x;

if debug
    plotfft(prod, Fs);
    title("After mixing");
    figure;
    scatter(real(prod),imag(prod),".");
    title("Constellation");
end

flt = fir1(50,2000/Fs);
f = filter(flt,1,prod);

if debug
    plotfft(f,Fs);
    title("AFter foéteromg");
end

m = fmdemod_iq(f);

if debug
    plotfft(m,Fs);
    title("After demod");
end

flt2 = fir1(50,2000/Fs);
m = filter(flt2, 1, m);

if debug
    plotfft(m,Fs);
    title("After filter");
end

% plotfft(m,Fs);

DECIMATION_FACTOR = 5;
y = m(1:DECIMATION_FACTOR:end);
t = t(1:DECIMATION_FACTOR:end);
Fs = Fs / DECIMATION_FACTOR;


if debug
    plotfft(y,Fs);
    title("After decimation");
end
%plotfft(y,Fs);


end

