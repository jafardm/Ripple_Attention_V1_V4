function Signal = Make_ripple_average(cfg,LFP,TimeVec,rippleTime)


nBins = round(cfg.win*cfg.Fs);
   
Signal = zeros(length(rippleTime),2*nBins+1); 


  for ii = 1:size(Signal,1)
         [~,idx]  = min(abs(TimeVec - rippleTime(ii)));
         Signal(ii,:)  = LFP(idx - nBins:idx + nBins);
  end

 Signal = mean(Signal,1);
