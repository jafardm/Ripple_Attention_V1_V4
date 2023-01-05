function [rippleCount,randCount,ripBase,randBase] = ripple_spks(cfg,mmspks,ripples,timeBins)

win         = [0.5 1];
nBins       = round(timeBins*cfg.spkSF);
timeVec     = -win(1):1/cfg.spkSF:win(2);
basline_idx = 1:2*nBins+1;

rippleCount = zeros(length(ripples),2*nBins+1);
randCount   = zeros(length(ripples),2*nBins+1);

ripBase  = zeros(length(ripples),2*nBins+1);
randBase = zeros(length(ripples),2*nBins+1);


for ii =1:length(ripples)
    temp           =  mmspks(:,:,ii);
    nTrials        = 1:1:size(temp,1);
    channripples   = ripples{ii};
    
    if ~isempty(channripples)
        TrialWripple   = ripples{ii,1}(:,end);
        NorippleTrials = nTrials(~ismember(nTrials,TrialWripple));
        randomidx      = NorippleTrials(randperm(length(NorippleTrials),length(TrialWripple)));
        
        riCount = zeros(size(channripples,1),2*nBins+1);
        raCount = zeros(size(channripples,1),2*nBins+1);
        
        baselineRipple = zeros(size(channripples,1),length(basline_idx));
        baselinerandm  = zeros(size(channripples,1),length(basline_idx));
        
        for jj = 1:size(channripples,1)
            [~,idx]       = min(abs(timeVec - channripples(jj,2)));
            riCount(jj,:) = temp(channripples(jj,end),idx-nBins:idx+nBins);
            raCount(jj,:) = temp(randomidx(jj),idx-nBins:idx+nBins);
            
            baselineRipple(jj,:) = temp(channripples(jj,end),basline_idx);
            baselinerandm(jj,:)  = temp(randomidx(jj),basline_idx);
        end
        rippleCount(ii,:) = nanmean(riCount,1);
        randCount(ii,:)   = nanmean(raCount,1);
        
        ripBase(ii,:)  = nanmean(baselineRipple,1);
        randBase(ii,:) = nanmean(baselinerandm,1);
    end
end

rippleCount(all(~rippleCount,2),:) = [];
randCount(all(~randCount,2),:)     = [];
ripBase(all(~ripBase,2),:)         = [];
randBase(all(~randBase,2),:)       = [];


