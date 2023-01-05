function [Spect_t,freq,AveSpect ]= average_spectrogramc(cfg,LFPs,TimeVec,ripples)

    ripples = ripples(all(ripples,2),:);
    
    if isempty(ripples)
       AveSpect=[]; Spect_t = []; freq = [];
       return;
    end

    
    nBins       = round(cfg.win*cfg.Fs);
    ripplesLFPs = zeros(2*nBins+1,size(ripples,1)); 
    
    for jj = 1:size(ripples,1)
             [~,idx]            = min(abs(TimeVec - ripples(jj,2)));
             ripplesLFPs(:,jj)  = LFPs(idx - nBins:idx + nBins);       
    end
    
    ripplesLFPs = diff(ripplesLFPs,1); 
   
   MaxRipple_time = ripples(:,2);
   AveSpect = 0;
   
    for ii = 1:length(MaxRipple_time)
        cfg.tEDF                 = MaxRipple_time(ii) - cfg.win:1/cfg.Fs:MaxRipple_time(ii) + cfg.win;
       [Spect_t,freq,zSpec]      = hannspecgramc(cfg,ripplesLFPs(:,ii));  
       AveSpect = AveSpect + zSpec;
    end
  Spect_t = Spect_t -  MaxRipple_time(ii); 
  AveSpect = AveSpect/ii;  
end   
  


