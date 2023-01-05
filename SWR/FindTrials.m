function trials = FindTrials(cfg,Signal,TimeVec,eventsTimes,win)

% extract the samples for a desired window interval.

if isempty(eventsTimes)
    trials = [];
    return;
end

nBinsBefore = floor(win(1)*cfg.Fs);
nBinsAfter  = floor(win(2)*cfg.Fs);
nBinsT = nBinsBefore+nBinsAfter+1;
trials = zeros(nBinsT,size(eventsTimes,1));

for jj = 1:length(eventsTimes)
    [~,idx]       = min(abs(TimeVec - eventsTimes(jj)));
    trials(:,jj)  = Signal(idx - nBinsBefore:idx + nBinsAfter);
end