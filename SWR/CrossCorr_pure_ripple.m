function [PreStimRipples,SustainRipples] = CrossCorr_pure_ripple(ripples,TrialTimes)


PreStim        = [TrialTimes(:,2) - 1.2  TrialTimes(:,2)];         % 1200 ms before Stim_On to Stim_On
SuatainedTimes = [TrialTimes(:,2) + 0.3  TrialTimes(:,2) + 0.8];   % 900 ms after Stim_on to 750 ms after Stim_on


PreStimRipples    = CheckEpoch(ripples,PreStim);
SustainRipples  = CheckEpoch(ripples,SuatainedTimes);
% combibe trial with ripples


end

function pure_ripples = CheckEpoch(ripplesTimes,epochsTime)
    
    [~,cols]  = size(ripplesTimes);
    
    pure_ripples = zeros(size(epochsTime,1),cols+1);
   for k = 1:size(ripplesTimes,1)

        for iTrial = 1:size(epochsTime,1)

            if (ripplesTimes(k,2) >= epochsTime(iTrial,1) && ripplesTimes(k,2) < epochsTime(iTrial,2)) 
                pure_ripples(iTrial,1:4) =  ripplesTimes(k,:);
                pure_ripples(iTrial,5)   = iTrial;
            end
        end
    end
end



             