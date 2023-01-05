function Blocked_ripples = ripple_per_block(TrialTimes,RplsTimes,Bclock_change_idx,win)


Blocked_ripples = zeros(size(RplsTimes,1),2);

for n = 1:length(Bclock_change_idx)
    
    beforTime = [TrialTimes(Bclock_change_idx(n),1)- win  TrialTimes(Bclock_change_idx(n),1)];
    aftertime = [TrialTimes(Bclock_change_idx(n),1)   TrialTimes(Bclock_change_idx(n),1) + win];
    
    BeforBlock = 0;
    AfterBlock = 0;
    for r = 1:size(RplsTimes,1)
        
        if  RplsTimes(r,2) >= beforTime(1) &&  RplsTimes(r,2) <= beforTime(2)
            BeforBlock = BeforBlock +1;
        end
        if RplsTimes(r,2) >= aftertime(1) &&  RplsTimes(r,2) <= aftertime(2)
            AfterBlock = AfterBlock+1;
        end
    end
    Blocked_ripples (n,:) = [BeforBlock/win AfterBlock/win];
    
end

Blocked_ripples = mean(Blocked_ripples,1);
