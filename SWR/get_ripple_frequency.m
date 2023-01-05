function [Raw_ripples,Spect,peakAmp,PeakFreq,freq] = get_ripple_frequency(cfg,LFP,TimeVec,MaxRipple_time)

if isempty(MaxRipple_time)
   Raw_ripples = []; Spect = []; freq = [];peakAmp = [];PeakFreq = [];
   return;
end


nBins = round(cfg.win*cfg.Fs);
nfft  = 512;     %  2.^[9:n] = [512 1024 2048 4096 ...]
dt    = 1/cfg.Fs;
T     = cfg.win;
    
Raw_ripples = zeros(2*nBins+1,length(MaxRipple_time)); 


  for ii = 1:size(Raw_ripples,2)
         [~,idx]  = min(abs(TimeVec - MaxRipple_time(ii)));
         Raw_ripples(:,ii)  = LFP(idx - nBins:idx + nBins);
  end


dMeanLFPs = LFP - mean(LFP); % dmean the LFPs

dRawLFPs  = diff(dMeanLFPs,1,1);             % take first derevative to remove 1/f effect

X = repmat(hann(size(dRawLFPs,1)),1,size(dRawLFPs,2)).*dRawLFPs;

xf    = fft(X,nfft,1);
% Spect = 2*dt^2/T*(xf.*conj(fft(dRawLFPs,nfft,1)));
Spect = (xf.*conj(fft(X,nfft,1))); %%%%%%%%%%%%

n2p1      = floor(size(Spect,1)/2);
Spect     = Spect(1:n2p1,:);
freq      = linspace(0,cfg.Fs/2,n2p1);

peakAmp  = zeros(size(Spect,2),1);
PeakFreq = zeros(size(Spect,2),1);

for ii =1:size(Spect,2)
   [val, idx]=  max(Spect(:,ii));
   peakAmp (ii) = val;
   PeakFreq(ii) = freq(idx);
end

Lowid  = find(PeakFreq < cfg.Freq_threshold(1));
Highid =  find(PeakFreq > cfg.Freq_threshold(2));

Spect(:,[Lowid' Highid'])       = [];
PeakFreq([Lowid' Highid'])      = [];
peakAmp([Lowid' Highid'])       = [];
Raw_ripples(:,[Lowid' Highid']) = [];
end


