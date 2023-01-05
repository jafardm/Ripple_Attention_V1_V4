function [spk_Rpl_RF,spk_NRpl_RF,spk_Rpl_away,spk_NRpl_away,trialsIdRF,trialsIdaway] = spiking_V1_V4_ripple(spks_signal,ripples,sessionLabel)

spkSF  = 32552;
win         = [0.5 1];
timeBins = 0.1;
nBins       = round(timeBins*spkSF);
timeVec     = -win(1):1/spkSF:win(2);
N = 1:2*nBins+1;

ripple_RF   = cell(14,1);
no_ripple_RF = cell(14,1);

ripple_away   = cell(14,1);
no_ripple_away = cell(14,1);
trialsIdsession  = cell(14,1);

for ii = 1:size(ripples,1) % loop over channels

    tempspk = spks_signal(:,:,ii); 

    if isempty(ripples{ii,1}), continue, end
    ripplChannel = ripples{ii,1}; % ripple at channel

    trialsIdsession{ii} = sessionLabel(ripplChannel(:,end),:); % trial code labes for ripples

    RFNum   = ripplChannel(sessionLabel(ripplChannel(:,end),1) == 1,:);
    AwayNum = ripplChannel(sessionLabel(ripplChannel(:,end),1) == 2,:);

    % Rf ripples
    if ~isempty(RFNum)
      tempripple1 = nan(size(RFNum,1),length(N));  
        for k = 1:size(RFNum,1)
             [~,idx]  = min(abs(timeVec - RFNum(k,2)));
             tempripple1(k,:) = tempspk(RFNum(k,end),idx-nBins:idx+nBins); 
        end
        ripple_RF{ii,1}  = tempripple1; % ripple RF
        

        temp_rand_RF = nan(size(RFNum,1),length(N),5);  
        for it = 1:5
            randomIdx = get_random_index(RFNum,sessionLabel);
            for k = 1:length(randomIdx)
                 [~,idx]  = min(abs(timeVec - RFNum(k,2)));
                 temp_rand_RF(k,:,it) = tempspk(randomIdx(k),idx-nBins:idx+nBins); 
            end
            
        end
        no_ripple_RF{ii,1} = nanmean(temp_rand_RF,3);
    end
    
    if ~isempty(AwayNum)

      tempripple2 = nan(size(AwayNum,1),length(N));  
        for k = 1:size(AwayNum,1)
             [~,idx]  = min(abs(timeVec - AwayNum(k,2)));
             tempripple2(k,:) = tempspk(AwayNum(k,end),idx-nBins:idx+nBins);  
        end

        ripple_away{ii,1} = tempripple2;

        temp_rand_away = nan(size(AwayNum,1),length(N),5);  
        for it = 1:5
            randomIdx = get_random_index(AwayNum,sessionLabel);
            for k = 1:length(randomIdx)
                 [~,idx]  = min(abs(timeVec - AwayNum(k,2)));
                 temp_rand_away(k,:,it) = tempspk(randomIdx(k),idx-nBins:idx+nBins); 
            end
        end
        no_ripple_away{ii,1} = nanmean(temp_rand_away,3);
    end

end
spk_Rpl_RF    = cell2mat(ripple_RF);
spk_NRpl_RF   = cell2mat(no_ripple_RF);
spk_Rpl_away  = cell2mat(ripple_away);
spk_NRpl_away = cell2mat(no_ripple_away);

traiallabsels = cell2mat(trialsIdsession);
trialsIdRF   = traiallabsels(traiallabsels(:,1)==1,:);
trialsIdaway = traiallabsels(traiallabsels(:,1)==2,:);
end



function randomIdx = get_random_index(rippleNum,sessionLabel)

    conds = sessionLabel(rippleNum(:,end),:);
    remainlabels = sessionLabel;
    remainlabels(rippleNum(:,end),:) = 5;
    
    randomIdx = zeros(size(rippleNum,1),1);
    for jj = 1:size(conds,1) 
        indices = find(all(conds(jj,:) == remainlabels,2));
        randomIdx(jj) = indices(randperm(length(indices),1));
    end 

end