function [mnS,freq,times] = RPspectrogram(TrueRipples,Times,Samples,win,Fs)

mnS=0;

if isempty(TrueRipples)
    mnS=[];freq=[];times=[];
    return
end

     
for n = 1:size(TrueRipples,1)

igood = find(Times > TrueRipples(n,4)-win & Times < TrueRipples(n,4)+win);
tEDF = Times(igood);
dspec = Samples(igood);
movingwin    = [0.100,0.005];  % Window size, Step size [s]  
flo  = 30;                      % visualize frequency    
fhi  = 250;
iStart = 1;
iWin   = round(movingwin(1)*Fs/2)*2;
iStep  = round(movingwin(2)*Fs/2)*2;
T      = iWin/Fs;
df     = 1/T;
fNQ    = Fs/2;
freq   = (0:iWin/2)*df;

% fft baseline
ibase = find(Times > TrueRipples(n,2)-0.5 & Times < TrueRipples(n,2)-0.2);
ispec = Samples(ibase)-mean(Samples(ibase));
bfft = fft(ispec).*conj(fft(ispec));
bfft = bfft(1:iWin/2+1);

counter=1;
S      = zeros(ceil(length(tEDF)/iStep), iWin/2+1);
times  = zeros(ceil(length(tEDF)/iStep), 1);
while iStart+iWin < length(tEDF)

  dnow    = dspec(iStart:iStart+iWin-1);
  dnow    = dnow - mean(dnow);
  dnow    = hann(length(dnow)).*dnow;
  spectrum= fft(dnow).*conj(fft(dnow));
  S(counter,:)   = spectrum(1:iWin/2+1)./bfft;
  times(counter) = tEDF(iStart+iWin/2);
    
  counter=counter+1;
  iStart = iStart + iStep;
end
S = S(1:counter-1,:);
% BS = repmat(bfft,1,size(S,1))';
% S  = S./BS;
times = times(1:counter-1)- TrueRipples(n,4);
fgood = find(freq >= flo & freq <= fhi);
S = S(:,fgood);
freq = freq(fgood);
mnS = mnS+S/n;
end

end

