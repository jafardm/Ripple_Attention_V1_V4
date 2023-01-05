function [Spect,PeakFreq,freq] = get_spectrum(cfg,LFP)

nfft  = 512;     %  2.^[9:n] = [512 1024 2048 4096 ...]
dt    = 1/cfg.Fs;
T     = length(LFP)/cfg.Fs;

dMeanLFPs = LFP - mean(LFP); % dmean the LFPs

dRawLFPs  = diff(dMeanLFPs,1);             % take first derevative to remove 1/f effect

X = hann(size(dRawLFPs,2)).*dRawLFPs';

xf    = fft(X,nfft);
% Spect = 2*dt^2/T*(xf.*conj(fft(X,nfft)));
Spect = xf.*conj(fft(X,nfft,1)); %%%%%%%%%%%%

n2p1      = floor(size(Spect,1)/2);
Spect     = Spect(1:n2p1,:);
freq      = linspace(0,cfg.Fs/2,n2p1);

% peakAmp  = zeros(size(Spect,2),1);
PeakFreq = zeros(size(Spect,2),1);

for ii =1:size(Spect,2)
   [val, idx]=  max(Spect(:,ii));
%    peakAmp (ii) = val;
   PeakFreq(ii) = freq(idx);
end


end


