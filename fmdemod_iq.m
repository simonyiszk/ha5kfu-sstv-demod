function [y] = fmdemod_iq(x)
y = zeros(length(x),1);
ip = 0; qp=0;
for k = 1:length(x)
    i = real(x(k));
    q = imag(x(k));
    
    di = i - ip;
    dq = q - qp;

    y(k) = (di * q - dq*i) / (i*i+q*q);
    if i==0 && q==0
        y(k)=0;
    end
    ip = i;
    qp = q;
end
end

