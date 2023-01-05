% example of ripple detection on 16 chanells LFP(< 300 Hz)data

addpath('...\NeuralynxFunctions\');
addpath('...\NeuralynxFunctions\');
addpath('...\NLXMatlabTools-master\');
addpath('...\FMAToolbox\Helpers\');
addpath('...\trialextraction-master\');
addpath('...\cortex-matlabtoolbox-master\');
addpath('...\SWR\')

%% Load data
clear

dataset = '...:\DataSet\';

subjectName = 'monkey1'; 
switch subjectName 
    case 'monkey1'
        pen  = CaesarDataInfo(dataset);
    case   'monkey2'
        pen  = RichardDataInfo(dataset);
end

cfg.nOfchannel      = 2:15;
cfg.ctxEyeFlag      = false;
cfg.ctxEPPFlag      = false;
cfg.CorrectOnlyFlag = true;          %fasle for error trials
cfg.FieldOption     = 'Full';
cfg.TrialOption     = 'sustain';      % sustain, precue or postcue,intt, all
cfg.area            = 'e1';
cfg.trialcodelabel  = 'Att';           % Att, Foc, stim
cfg.ExtractMode     = 1;
cfg.nOfspot         = 60;              % Number of spots below/above the threshold(60 spots)
cfg.Freq_threshold  = [70 200];        % Threshold for discard ripple in spectrogram
cfg.filterOrder     = 20;
cfg.win             = 0.3;
cfg.StimEvents      = true;
cfg.subjectName     = subjectName;
cfg.frange          = [80 250];
cfg.Fs              = 1017;
cfg.fpass           = [5 250];
cfg.movingwin       = [0.196,0.005];
%% Get correct ripples


for peni = 1:length(pen)
    
    cfg.nevPath          = pen(peni).NEVPath;
    cfg.nevTime          = pen(peni).NLXTime;
    cfg.ctxVersionSwitch = pen(peni).CTXVersionSwitch;
    cfg.ctxPath          = pen(peni).CTXPath;
    cfg.dataDir          = pen(peni).dataDir;
    cfg.Name             = pen(peni).Name;
    
    Flag = check_peneteration(cfg);
    
    if Flag, continue; end
    
    Labels = gettrial_label(cfg);
    
    idxin  = sum(Labels(:,2)==1); % change based on attention(:,1), focus(:,2) and size(:,3)
    idxO   = sum(Labels(:,2)==2);
    
    [TrialTimes,Cond] = eventInfo(cfg);
    
    duration = unique(TrialTimes(:,2)-TrialTimes(:,1));
    
    Stim_ON           = TrialTimes(:,1) - 0.3;
    
    for iChan = cfg.nOfchannel
        
        [Samples,Times]          = Bipolar_referencing(cfg,iChan);
        [XR,~]                   = ripple_detction(cfg,Samples,Times);
        [Allrpls,correctripples] = get_true_ripple(cfg,Samples,Times,TrialTimes,XR);
        RplsTimes                = correctripples(all(correctripples,2),:);
        
        if isempty(RplsTimes), continue; end
        
        RipplesTime =  [RplsTimes(:,1:3) - Stim_ON(RplsTimes(:,end)) RplsTimes(:,end)];
        TrialNumber = RplsTimes(:,end);
        [N1,N2]     = get_ripple_block(cfg,Cond,TrialNumber);
        
        Cond1(ii,iChan-1,peni)           = N1/(duration(1)*idxin);
        Cond2(ii,iChan-1,peni)           = N2/(duration(1)*idxO);
        ripples{ii,iChan-1,peni}         = RipplesTime;
    end
end

