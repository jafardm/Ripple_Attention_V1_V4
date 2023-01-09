function pure_ripples = get_true_ripple(cfg,LFPs,TimeVec,AllRipples)

% Excludes false ripples detected by FindRipples function


    LFPs = diff(LFPs,1); 

    X           = AllRipples; 
    RplsTimes   = X(all(X,2),:);
    nBins       = round(cfg.win*cfg.Fs);
    
    ripplesLFPs = zeros(2*nBins+1,size(RplsTimes,1)); 
    
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

    idxr = find(~any(nOfpeaks>cfg.nOfspot,2));
    
    if isempty(idxr)
        pure_ripples = X; 
           
    else
        
        pure_ripples = X(idxr,:); % ripple times
 
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