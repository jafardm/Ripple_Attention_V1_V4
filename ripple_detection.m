% example of ripple detection on 16 channels LFP(< 300 Hz)data
addpath('...\SWR\')
addpath('...\FMAToolbox\')
%% Load data
clear

dataset = 'C:\Users\jdoost1\Desktop\dataOnline\Monkey1\';

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
cfg.ExtractMode     = 1;
cfg.nOfspot         = 80;              % Number of spots below/above the threshold(80 spots)
cfg.Freq_threshold  = [70 200];        % Threshold for discard ripple in spectrogram
cfg.filterOrder     = 20;
cfg.win             = 0.3;
cfg.StimEvents      = true;
cfg.subjectName     = subjectName;
cfg.frange          = [80 250];
cfg.Fs              = 1017;
cfg.fpass           = [5 250];
cfg.movingwin       = [0.196,0.005];
cfg.datasetdir      = dataset;
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
    
    for iChan = cfg.nOfchannel
        
        [Samples,Times]          = Bipolar_referencing(cfg,iChan);
        [XR,~]                   = ripple_detction(cfg,Samples,Times);
       correctripples = get_true_ripple(cfg,Samples,Times,XR);
     
        if isempty(correctripples), continue; end
         
    end
end

