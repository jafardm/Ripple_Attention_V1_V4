function [x,T] = getAnalog (s,i)
 % s is struct of current SPK,
 % i is channel number
nChan=length(i);   
bwidth = zeros(1,nChan);
blength = cell(1,nChan);

nTr = length(s.currenttrials);
nBins = cellfun('size',s.analog(s.currentanalog),2);
nBins = unique(nBins);
bWin = repmat([1 nBins],[nTr 1 1]);

for iCh = 1:nChan % 1:16
    cChNr = s.currentanalog(iCh);
    bwidth(iCh) = (1/s.analogfreq(cChNr))/(10^s.timeorder);
    blength{iCh} = diff(bWin(:,:,iCh),[],2)+1;
    
    x{iCh} = ones(nTr,max(blength{iCh})).*NaN;
    T{iCh} = ones(nTr,max(blength{iCh})).*NaN;
  %%  
    ChNr = s.currentanalog(iCh);
    SF = s.analogfreq(ChNr);% sample frequency
    aB = s.analogalignbin(ChNr);% align bin
    nB = size(s.analog{ChNr},2);% number of sample bins
    t{1} = zeros(1,nB);% time vector
    t{1}(aB:-1:1) = [0 : ((-1)*(1000/SF)) : ((aB-1)*(-1)*(1000/SF))];
    t{1}(aB:1:nB) = [0 : (1000/SF) : ((nB-aB)*(1000/SF))];
    t = t{1};

    %% get data
    for iTr = 1:nTr
        x{iCh}(iTr,1:blength{iCh}(iTr)) = s.analog{cChNr}(s.currenttrials(iTr),bWin(iTr,1,iCh):bWin(iTr,2,iCh));
        T{iCh}(iTr,1:blength{iCh}(iTr)) = t(1,bWin(iTr,1,iCh):bWin(iTr,2,iCh));% take time window of first trial!!
    end
    x=x{1};
    T=T{1};
end