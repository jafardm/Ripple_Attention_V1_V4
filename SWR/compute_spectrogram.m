function [times,freq,zSpec] = compute_spectrogram(LFP,TimeVec,ripple_time,win,fs,movingwin,params)

nBins = round(win*fs);


[~,idx1]        = min(abs(TimeVec - ripple_time));
raw_ripple     = LFP(idx1 - nBins:idx1 + nBins);

rng(0,'twister')
nRandEvents = 300; 
idx         = randi([nBins length(LFP)-nBins],1,nRandEvents);
randTrials  = zeros(2*nBins+1,nRandEvents); 

    for ii = 1:numel(idx)
         randTrials(:,ii) =  LFP(idx(ii) - nBins : idx(ii)+ nBins);
    end

 BslSpect = [];
 params.tEDF =  0:1/fs:2*win;
 
    for n = 1:size(randTrials,2)  
        BslSpect(:,:,n) = hannspecgramc(randTrials(:,ii),movingwin,params);      
    end

mnBsl  =  mean(BslSpect,3);                        % mean of random spwctrogram
stdBsl =  std(BslSpect,1,3)+eps;                   % starndard deviation of random spwctrogram
  

params.tEDF           = ripple_time  - win:1/fs:ripple_time  + win;
[rSpect,S_times,freq] = hannspecgramc(raw_ripple ,movingwin,params);

times =  S_times - ripple_time;
zSpec =  (rSpect - mnBsl);%./stdBsl;

