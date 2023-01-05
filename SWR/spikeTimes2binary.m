function spks = spikeTimes2binary(spktimes,win)

fs = 32552;  % sampling frequency of spikes



times = -win(1):1/fs:win(2);
spks = nan(length(spktimes),size(times,2));

for ii = 1:length(spktimes)
    index_event = ismembertol(times,spktimes{ii},1/2/fs/max(abs([times(:);spktimes{ii}])));
    spks(ii,:) = index_event;
end

