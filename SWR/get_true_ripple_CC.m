function [ripples,pure_ripples] = get_true_ripple_CC(cfg,LFPs,TimeVec,epochsTime,AllRipples)

% First and second column of epochsTime is start and end time of desired interval respectively.
% for inter-trial TrialTimes is NLX_TRIAL_START and NLX_TRIAL_END

if strcmp(cfg.TrialOption,'all') && size(epochsTime,2)==6
    
    ripples     = CheckEpoch(AllRipples,epochsTime);
    X           = ripples;
    RplsTimes   = X(all(X,2),:);
else
    disp('Trial epochsTime is not correct!!!')
end

nBins       = round(cfg.win*cfg.Fs);

ripplesLFPs = zeros(2*nBins+1,size(RplsTimes,1));
LFPs        = diff(LFPs,1);
for jj = 1:size(RplsTimes,1)
    [~,idx]            = min(abs(TimeVec - RplsTimes(jj,2)));
    ripplesLFPs(:,jj)  = LFPs(idx - nBins:idx + nBins);
end

MaxRipple_time = RplsTimes(:,2);
nOfpeaks       = zeros(size(MaxRipple_time,1),2);

for ii = 1:length(MaxRipple_time)
    cfg.tEDF           = MaxRipple_time(ii) - cfg.win:1/cfg.Fs:MaxRipple_time(ii) + cfg.win;
    [t,freq,zSpec]      = hannspecgramc(cfg,ripplesLFPs(:,ii));
    nOfpeaks(ii,:)      = findRipplespots(zSpec,freq,cfg.Freq_threshold);
end

rpl2delete = RplsTimes(any(nOfpeaks>cfg.nOfspot,2),:);

if isempty(rpl2delete), pure_ripples = X;
    
else
    for spoti = 1:size(rpl2delete,1)
        X(rpl2delete(spoti,end),:) = 0;
    end
    pure_ripples = X;
end


end



function pure_ripples = CheckEpoch(ripplesTimes,epochsTime)

[~,cols]  = size(ripplesTimes);

pure_ripples = zeros(size(epochsTime,1),cols+1);
for k = 1:size(ripplesTimes,1)
    
    for iTrial = 1:size(epochsTime,1)
        
        if (ripplesTimes(k,2) >= epochsTime(iTrial,1) && ripplesTimes(k,2) < epochsTime(iTrial,2))...
                || (ripplesTimes(k,2) >= epochsTime(iTrial,3) && ripplesTimes(k,2) < epochsTime(iTrial,4))...
                || (ripplesTimes(k,2) >= epochsTime(iTrial,5) && ripplesTimes(k,2) < epochsTime(iTrial,6))
            
            pure_ripples(iTrial,1:4) =  ripplesTimes(k,:);
            pure_ripples(iTrial,5)   = iTrial;
        end
    end
end
end


function nOfFlags = findRipplespots(image,freq,Freq_threshold)

[~, sortedInds] = sort(image(:),'descend');
topPoints       = sortedInds(1:200);
[~, Spots]      = ind2sub(size(image), topPoints);

FlagL = [];
FlagH = [];

for iSpot = 1:length(Spots)
    FlagL = [FlagL;freq(Spots(iSpot)) < Freq_threshold(1)];
    FlagH = [FlagH;freq(Spots(iSpot)) > Freq_threshold(2)];
end
nOfFlags = [numel(find(FlagL)) numel(find(FlagH))];

end
