% spiking activity at the ripple time

addpath('...\NeuralynxFunctions\');
addpath('...\NeuralynxFunctions\');
addpath('...\NLXMatlabTools-master\');
addpath('...\FMAToolbox\Helpers\');
addpath('...\trialextraction-master\');
addpath('...\cortex-matlabtoolbox-master\');
addpath('...\SWR\')


%%
clear
datasetpath  = '...\DataSet\';
spkPath      = '...\Spike-data-sorted\';
labelpath    = '...\Labels\';

cfg.area  = 'e1';

subjectName = 'Monkey1';
switch subjectName
    case 'Monkey1'
        pen  = CaesarDataInfo(datasetpath);
    case   'Monkey2'
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






