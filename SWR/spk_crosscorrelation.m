function [crossCorr,lags]= spk_crosscorrelation(cfg,channel,rippleTime)

%
NSEname  = [cfg.area 'SE%u'];
Filename = [sprintf(NSEname,channel) '.nse'];
NSEpath  = fullfile(cfg.dataDir,Filename);
NSE      = NLX_LoadNSE(NSEpath,cfg.FieldOption,cfg.ExtractMode,cfg.nevTime);

nCluster  = length(unique(NSE.ClusterNr));
ClusterNr = unique(NSE.ClusterNr);
[NSE,i]   = NLX_Freq2Threshold_max2min(NSE,ClusterNr,cfg.FreqBound,cfg.nevTime,nCluster);
NSE       = NLX_ExtractCluster(NSE,0, false);

spk_timestamps   = NSE.TimeStamps * 10^-6;



edges         = -cfg.win:cfg.bins:cfg.win;
ripple_psth   = zeros(length(rippleTime),length(edges)-1);

for  k = 1:numel(rippleTime)

    idx   =  (spk_timestamps > rippleTime(k) - cfg.win) & (spk_timestamps < rippleTime(k)+ cfg.win);
    Signal = spk_timestamps(idx & NSE.ClusterNr);  
    N                   = Signal -  rippleTime(k);
    ripple_psth(k,:) = histcounts(N,edges);
end
    

  