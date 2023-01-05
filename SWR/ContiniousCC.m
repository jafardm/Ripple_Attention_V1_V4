function [XC,SC,Lags] = ContiniousCC(RipplesFilePath,penInfo,subjectName,maxlags)

% FIR filter
SF              = 1017;
% nyquist       = SF/2;
% frange        = [80 250];
% transw        = 0.1;
% filter_order  = round(8*SF/frange(1));
% shape         = [0 0 1 1 0 0];
% frex          = [0 frange(1)-frange(1)*transw frange frange(2)+frange(2)*transw nyquist]/nyquist;
% filterweights = firls(filter_order,frex,shape);
cfg.type           = 'low'; 
cfg.order          = 4;
cfg.display_filter = 0;
cfg.R              = 0.5; 
cfg.frange         = 20;
cfg.fs             = SF;

% Take trial times
[StimTime,~,~] = eventInfo(penInfo,subjectName);
TrialStart     = StimTime(:,1) - 0.3;
TrialEnd       = StimTime(:,2) + 0.9;
nBins          = length(TrialStart(1):1/SF:TrialEnd(1));

TrialTimes     = zeros(length(TrialStart),nBins);

for triali = 1:length(TrialStart)
       temp                 = TrialStart(triali):1/SF:TrialEnd(triali);
       TrialTimes(triali,:) = temp(1:nBins);
end

                                   
% load e1 ripples
sprintf(['Loading ripples file: ' 'e1' penInfo.Name '.mat'])
load([RipplesFilePath 'e1' penInfo.Name '.mat'])

 xcor = zeros(length(ripplesInfo),2*maxlags+1,length(ripplesInfo));
 Scor = zeros(length(ripplesInfo),2*maxlags+1,length(ripplesInfo));

for iChan = 1:length(ripplesInfo)
    
    chanNum         = find(ismember([ripplesInfo.Channel],iChan+1));
    e1ripplesTimes  = [ripplesInfo(chanNum).PreStim; ripplesInfo(chanNum).Sustain];
    TrialWithRipple = sort(e1ripplesTimes(all(e1ripplesTimes,2),end));
    
    if isempty(TrialWithRipple),continue;end
    
    [samples,TimeVec]   = Bipolar_referencing(penInfo,'e1',iChan+1); 
    TimeVec             = TimeVec*10^-6; 
    e1RectifiedLFPs     = FilterLFP(cfg,samples);
    e1LFPs              = getLFPs(e1RectifiedLFPs,TimeVec,TrialTimes);
    
    disp(['   Trials of channel ' num2str(iChan) ' of e1 loaded.'])
     
   for signalChan = 1:length(ripplesInfo)
         
        [samples,TimeVec]   = Bipolar_referencing(penInfo,'e2',signalChan+1); 
        TimeVec             = TimeVec*10^-6; 
        e2RectifiedLFPs     = FilterLFP(cfg,samples);
        e2LFPs              = getLFPs(e2RectifiedLFPs,TimeVec,TrialTimes);
        disp(['   Trials of channel ' num2str(signalChan) ' of e2 loaded.'])
        
        signal_CC  = zeros(length(TrialWithRipple),2*maxlags+1);
        Shuffle_CC = zeros(length(TrialWithRipple),2*maxlags+1);
        
        shuffle_idx   = randperm(size(TrialTimes,1));
        e2LFPsShuffle = e2LFPs(shuffle_idx,:); 
        
            for ii = 1:length(TrialWithRipple)
                 x        = e1ripplesTimes(ismember(e1ripplesTimes(:,end),TrialWithRipple(ii)),:);
                [~,idx1]  = min(abs(TrialTimes(TrialWithRipple(ii),:) - x(1,1)));
                [~,idx2]  = min(abs(TrialTimes(TrialWithRipple(ii),:) - x(1,3)));
                e1        = e1LFPs{TrialWithRipple(ii)}(idx1:idx2,1);
                e2        = e2LFPs{TrialWithRipple(ii)}(idx1:idx2,1);
                e2shuffle = e2LFPsShuffle{TrialWithRipple(ii)}(idx1:idx2,1);
                
               [signal_CC(ii,:),Lags] = xcorr(e1,e2,maxlags,'coeff');
               [Shuffle_CC(ii,:),~]   = xcorr(e1,e2shuffle,maxlags,'coeff');
            end
            
     xcor(iChan,:,signalChan) = nanmean(signal_CC,1);
     Scor(iChan,:,signalChan) = nanmean(Shuffle_CC,1);        
   end 
   
end
XC = nanmean(xcor,3);
SC = nanmean(Scor,3);
end



function X = getLFPs(LFP,TimeVec,TrialTimes)

          X = cell(size(TrialTimes,1),1); 
          for ii = 1:size(X,1)
              [~,idx1] = min(abs(TimeVec - TrialTimes(ii,1)));
              [~,idx2] = min(abs(TimeVec - TrialTimes(ii,end)));
              X{ii,1}  = LFP(idx1:idx2);
          end
end
