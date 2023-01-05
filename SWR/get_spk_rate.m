function spks= get_spk_rate(cfg,channel,EventsTimes,win)

%
% SF      =  32552;  % sampling frequency

NSEname  = [cfg.area 'SE%u'];
Filename = [sprintf(NSEname,channel) '.nse'];
NSEpath  = fullfile(cfg.dataDir,Filename);
NSE      = NLX_LoadNSE(NSEpath,cfg.FieldOption,cfg.ExtractMode,cfg.nevTime);

switch cfg.config

    case 'Thresholded'
        nCluster  = length(unique(NSE.ClusterNr));
        ClusterNr = unique(NSE.ClusterNr);
        [NSE,i]   = NLX_Freq2Threshold_max2min(NSE,ClusterNr,cfg.FreqBound,cfg.nevTime,nCluster);
        NSE       = NLX_ExtractCluster(NSE,0, false);


      spk_timestamps   = NSE.TimeStamps * 10^-6;
      spks             = cell(length(EventsTimes),1);

       for  k = 1:numel(EventsTimes)
           spikes =  spk_timestamps( spk_timestamps >= EventsTimes(k) - win(1) &...
           spk_timestamps <= EventsTimes(k) + win(2));
           spks{k,1} =  spikes -  EventsTimes(k);
       end

    case 'sorted'

         spk_timestamps = NSE.TimeStamps * 10^-6;
         spikeidx = NSE.ClusterNr == 1 | NSE.ClusterNr == 2;
         sortedspks = spk_timestamps(spikeidx);

         spks  = cell(length(EventsTimes),1);

       for  k = 1:numel(EventsTimes)
           spikes =  sortedspks( sortedspks >= EventsTimes(k) - win(1) &...
           sortedspks <= EventsTimes(k) + win(2));
           spks{k,1} =  spikes -  EventsTimes(k);
       end
end
       