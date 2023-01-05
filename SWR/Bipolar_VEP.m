function [mEVP,LFP_Baseline,LfpTrialAvgCsd] = Bipolar_VEP(cfg,STIM_ON)

nBins        = round(cfg.win*cfg.Fs);
nTrials      = length(STIM_ON);
LFP_Baseline = zeros(length(cfg.nOfchannel),nBins,nTrials);
mEVP         = zeros(length(cfg.nOfchannel),nBins,nTrials);

 for iCh = cfg.nOfchannel

    [Samples,Times] = Bipolar_referencing(cfg,iCh);
   
        for iTrial = 1:length(STIM_ON)

           [~,idx]                      = min(abs(Times - STIM_ON(iTrial)));
           mEVP(iCh-1,:,iTrial)         = Samples(idx : idx + nBins-1);
           LFP_Baseline(iCh-1,:,iTrial) = Samples(idx - nBins :idx-1);

        end
     % baseline normalization   
    averageBaseLine = mean(LFP_Baseline,2);
    demeanEVP       = mEVP - repmat(averageBaseLine,1,nBins);
    stdBaseline     = std(demeanEVP,0,2);

    zscored2basline = mEVP ./repmat(stdBaseline+eps,1,nBins);
    LfpTrialAvgCsd = -(mean(zscored2basline,3));
 end
    
 
end


