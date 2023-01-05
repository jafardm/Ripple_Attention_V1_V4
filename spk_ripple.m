% spiking activity at the ripple time

cd D:\SWR-Code
addpath('D:\SWR-Code\NeuralynxFunctions\')
addpath('D:\SWR-Code\NeuralynxFunctions\');
addpath('D:\SWR-Code\NLXMatlabTools-master\');
addpath('D:\SWR-Code\FMAToolbox\Helpers\');
addpath('D:\SWR-Code\trialextraction-master\');
addpath('D:\SWR-Code\cortex-matlabtoolbox-master\');
addpath('D:\SWR-Code\SWR\')

%%
clear
datasetpath  = '...\DataSet\';
spkPath      = '...\Spike-data-sorted\';
labelpath    = '...\Labels\';

cfg.area  = 'e1';

subjectName = 'Richard';
switch subjectName
    case 'Caesar'
        pen  = CaesarDataInfo(datasetpath);
    case   'Richard'
        pen  = RichardDataInfo(datasetpath);
end

spkSF  = 32552;
win         = [0.5 1];
timeBins = 0.1;
nBins       = round(timeBins*spkSF);
timeVec     = -win(1):1/spkSF:win(2);
basline_idx = 1:2*nBins+1;
 
grand_ripple_rate_RF   = struct([]);
grand_ripple_rate_away = struct([]);

trialsIDs  = struct([]);

 for peni = 1:length(pen)
    
      cfg.Name = pen(peni).Name;
      Flag = check_peneteration(cfg);
      if Flag, continue; end

      % load trials labels
      load(fullfile(labelpath,subjectName(1)))
      % load spike data & ripples
      filenamespk = [cfg.area num2str(pen(peni).Name)];
      load(fullfile(spkPath,filenamespk))

     disp(filenamespk)

     bin = 10e-3;
     k        = round(bin*spkSF);
     mmSpks   = movmean(spks,k,2)*spkSF;

    sessionLabel = TrialcodeLabels{peni};

  for ii = 1:size(ripples,1)

      tempspk =  mmSpks(:,:,ii);

      if isempty(ripples{ii,1}), continue, end

      ripplChannel = ripples{ii,1};  

      RFNum  = ripplChannel(sessionLabel(ripplChannel(:,end),1) == 1,:);
      AwayNum =ripplChannel(sessionLabel(ripplChannel(:,end),1) == 2,:);

%% pick up random indices for RF 
      conds = sessionLabel(RFNum(:,end),:);
      remainlabels = sessionLabel;
      remainlabels(RFNum(:,end),:) = 5;

        randIDX1 = zeros(size(RFNum,1),1);
       for jj = 1:size(conds,1) 
           indices = find(all(conds(jj,:) == remainlabels,2));
           randIDX1(jj) = indices(randperm(length(indices),1));
       end
%% Clssify ripplee to RF & away
    
% Rf ripples
    if ~isempty(RFNum)
      tempripple1 = nan(length(randIDX1),length(basline_idx));  
      temprandom1 = nan(length(randIDX1),length(basline_idx));

        for k = 1:size(RFNum,1)
             [~,idx]  = min(abs(timeVec - RFNum(k,2)));
             tempripple1(k,:) = tempspk(RFNum(k,end),idx-nBins:idx+nBins);
             temprandom1(k,:) = tempspk(randIDX1(k),idx-nBins:idx+nBins);   
        end
        grand_ripple_rate_RF(peni).ripple{ii,1}  = tempripple1;
        grand_ripple_rate_RF(peni).without{ii,1}  = temprandom1; 
    end

  %% pick up random indices for away 
      conds = sessionLabel(AwayNum(:,end),:);
      remainlabels = sessionLabel;
      remainlabels(AwayNum(:,end),:) = 5;

        randIDXaway = zeros(size(AwayNum,1),1);
       for jj = 1:size(conds,1) 
           indices = find(all(conds(jj,:) == remainlabels,2));
           randIDXaway(jj) = indices(randperm(length(indices),1));
       end  

% away ripples

    if ~isempty(AwayNum)
      tempripple2 = nan(length(randIDXaway),length(basline_idx));  
      temprandom2 = nan(length(randIDXaway),length(basline_idx));

        for k = 1:size(AwayNum,1)
             [~,idx]  = min(abs(timeVec - AwayNum(k,2)));
             tempripple2(k,:) = tempspk(AwayNum(k,end),idx-nBins:idx+nBins);
             temprandom2(k,:) = tempspk(randIDXaway(k),idx-nBins:idx+nBins);   
        end

        grand_ripple_rate_away(peni).ripple{ii,1} = tempripple2;
        grand_ripple_rate_away(peni).without{ii,1} = temprandom2;
    end
 
     trialsIDs(peni).ripple{ii,1}  =  sessionLabel(randIDX1,:);
     trialsIDs(peni).without{ii,1}  =  sessionLabel(randIDXaway,:);
     trialsIDs(peni).session{ii,1}  =  ones(size(ripplChannel,1),1)*peni;
   end
   clear spks mmSpks ripples     
 end

Ripple_RF = cell2mat(vertcat(grand_ripple_rate_RF.ripple));
Without_RF = cell2mat(vertcat(grand_ripple_rate_RF.without));

Ripple_away  = cell2mat(vertcat(grand_ripple_rate_away.ripple)); 
without_Away = cell2mat(vertcat(grand_ripple_rate_away.without));

TrialsLabels = [cell2mat(vertcat(trialsIDs.ripple)); cell2mat(vertcat(trialsIDs.without))];
TrialsLabels(TrialsLabels(:,3)==3,end) = 1;

sessions     = cell2mat(vertcat(trialsIDs.session));

Pooled_Rate.rippleRF   =  Ripple_RF;
Pooled_Rate.WithoutRF  =  Without_RF;
Pooled_Rate.rippleAway =  Ripple_away;
Pooled_Rate.WithoutAway = without_Away;
Pooled_Rate.TrialIDs   = TrialsLabels;
Pooled_Rate.session    = sessions;

savename = fullfile('D:\SWR-Results\spikes-ripples-sorted',[subjectName(1) cfg.area]);
save(savename,'Pooled_Rate')


%% plot firing rate at ripple time
clear
load('D:\SWR-Results\spikes-ripples-sorted\Re1.mat')
% average ripple in RF
RippleRF = Pooled_Rate.rippleRF;
% average ripple in without
randomRF = Pooled_Rate.WithoutRF;
% average ripple in away
Rippleaway = Pooled_Rate.rippleAway; 
% average ripple in away random
randomaway = Pooled_Rate.WithoutAway;

spkSF = 32552;
t = (-0.1:1/spkSF:0.1)*1000;

fig = figure; hold on
mnRippleRF = nanmean(RippleRF,1);
sd1 = std(RippleRF,0,1)/(sqrt(size(RippleRF,1))-1);
boundedline(t,mnRippleRF,sd1,'cmap',[161 10 15]/255,'alpha')

mnrandomRF = nanmean(randomRF,1);
sd1 = std(randomRF,0,1)/(sqrt(size(randomRF,1))-1);
boundedline(t,mnrandomRF,sd1,'cmap',[255 48 155]/255,'alpha')


mnRipplAway = nanmean(Rippleaway,1);
sd2 = std(Rippleaway,0,1)/(sqrt(size(Rippleaway,1))-1);
boundedline(t,mnRipplAway,sd2,'cmap',[18 108 161]/255,'alpha')

mnrandaway = nanmean(randomaway,1);
sd2 = std(randomaway,0,1)/(sqrt(size(randomaway,1))-1);
boundedline(t,mnrandaway,sd2,'cmap',[160 255 242]/255,'alpha')

legend('Ripple RF','Ripple away','without ripple RF','without ripple away')
box off 
xlabel('Time(ms)')
ylabel('Firing rate(Hz)')
 ylim([10 35])
set(gca,'fontsize',8,'Fontname','Arial','TickDir', 'out'),box off
fig.Renderer = 'painters';

%%
clear
load('D:\SWR-Results\spikes-ripples-sorted\Ce2.mat')
% average ripple in RF
RippleM1   = mean(Pooled_Rate.rippleRF,2);
RippleAwayM1 = mean(Pooled_Rate.rippleAway,2);

WithotRFM1   = mean(Pooled_Rate.WithoutRF,2);
WithotAwayM1 = mean(Pooled_Rate.WithoutAway,2);

M1Rate      = [RippleM1;RippleAwayM1;WithotRFM1;WithotAwayM1];
trialIdM1   = [Pooled_Rate.TrialIDs;Pooled_Rate.TrialIDs];
sessionM1   = [Pooled_Rate.session; Pooled_Rate.session];

 rippleLabels1 = [ones(length(RippleM1),1);ones(length(RippleAwayM1),1);...
     zeros(length(WithotRFM1),1);zeros(length(WithotAwayM1),1)];

clear Pooled_Rate

load('D:\SWR-Results\spikes-ripples-sorted\Re2.mat')

% average ripple in RF
RippleM2   = nanmean(Pooled_Rate.rippleRF,2);
RippleAwayM2 = nanmean(Pooled_Rate.rippleAway,2);

WithotRFM2   = nanmean(Pooled_Rate.WithoutRF,2);
WithotAwayM2 = nanmean(Pooled_Rate.WithoutAway,2);

M2Rate      = [RippleM2;RippleAwayM2;WithotRFM2;WithotAwayM2];
trialIdM2   = [Pooled_Rate.TrialIDs;Pooled_Rate.TrialIDs];
sessionM2   = [Pooled_Rate.session; Pooled_Rate.session];

 rippleLabels2 = [ones(length(RippleM2),1);ones(length(RippleAwayM2),1);...
     zeros(length(WithotRFM2),1);zeros(length(WithotAwayM2),1)];

% pool data of both monkeys
mnFR = [M1Rate;M2Rate];
idR = mnFR==0;
mnFR(idR) = [];

TrialsLabels = [trialIdM1;trialIdM2];
TrialsLabels(idR,:) = [];

ripplelabels = [rippleLabels1;rippleLabels2];
ripplelabels(idR) = [];
sessions  = [sessionM1;sessionM2+26];
sessions(idR) = [];

tb = table(mnFR,ripplelabels,TrialsLabels(:,1),TrialsLabels(:,2),TrialsLabels(:,3),sessions,...
    'VariableNames', {'rate','ripple','attention','Focus','size','session'});

tb.ripple = categorical(tb.ripple);
tb.attention = categorical(tb.attention);
tb.Focus = categorical(tb.Focus);
tb.size = categorical(tb.size);
tb.session = categorical(tb.session);


 fit_lm = fitlme(tb,'rate ~ 1 + ripple*attention*Focus*size + (1|ripple)','DummyVarCoding','effects');


anova(fit_lm)

disp(grpstats(tb,{'ripple','attention'},{'mean','sem'},'DataVars','rate'));




