function [time,frex,power] = waveletSpectrogram(cfg,x)

% define wavelet parameters
time = -cfg.win:1/cfg.Fs:cfg.win;

frex = logspace(log10(cfg.freqrange(1)),log10(cfg.freqrange(2)),cfg.numfrex);
s    = logspace(log10(3),log10(10),cfg.numfrex)./(2*pi*frex);

y = x- mean(x);

% definte convolution parameters
n_wavelet            = length(time);
n_data               = length(y);
n_convolution        = n_wavelet+n_data-1;
n_conv_pow2          = pow2(nextpow2(n_convolution));
half_of_wavelet_size = (n_wavelet-1)/2;

% FFT of the wavelet
wavelets = zeros(n_conv_pow2,cfg.numfrex);

for fi = 1:cfg.numfrex
   waveX = fft( exp(2*1i*pi*frex(fi).*time) .* exp(-time.^2./(2*(s(fi)^2))) , n_conv_pow2 );
    wavelets(:,fi)  = waveX./max(waveX);
end

% get FFT of signal

xfft = fft(y,n_conv_pow2);

power = zeros(cfg.numfrex,n_data);
% loop through frequencies and compute synchronization
for fi=1:cfg.numfrex
    
    % convolution
    xconv = ifft(wavelets(:,fi).*xfft);
    xconv = xconv(1:n_convolution);
    xconv = xconv(half_of_wavelet_size+1:end-half_of_wavelet_size);
    
    power(fi,:) = abs(xconv).^2;
end





