% Get the layers and depth profile of cortex

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

cfg.nOfchannel      = 1:16;
cfg.ctxEyeFlag      = false;
cfg.ctxEPPFlag      = false;
cfg.CorrectOnlyFlag = true;            %fasle for error trials
cfg.FieldOption     = 'Full';
cfg.TrialOption     = 'sustain';       % sustain, precue or postcue,intt, all
cfg.area            = 'e1';
cfg.trialcodelabel  = 'Att';          % Att, Foc, stim
cfg.ExtractMode     = 1;
cfg.nOfspot         = 60;              % Number of spots below/above the threshold(60 for caesar,60 for richard)
cfg.Freq_threshold  = [70 200];        % Threshold for discard ripple in spectrogram
cfg.filterOrder     = 20;
cfg.win             = 0.2;
cfg.Fs              = 1017;
cfg.StimEvents      = true;
cfg.subjectName     = subjectName;

win       = [0 0.2];
timeVec   = -0.5:1/cfg.Fs:1;
[~,idx1]  = min(abs(timeVec-win(1)));
[~,idx2]  = min(abs(timeVec-win(2)));

dt        = 1e3/cfg.Fs;
MuaeTimes = (win(1):1/cfg.Fs:win(2)+1/cfg.Fs)*1e3;
contactSpacing     = 1.5e-4; % distance in meter
contactPositions   = (1:length(cfg.nOfchannel )).*contactSpacing;

muae           = 'D:\SWR-Results\27-02-2021\Muea';

%
for peni = 1:length(pen)
    
    cfg.Name = pen(peni).Name;
    
   if strcmp([cfg.area cfg.Name],'e1pen027'), continue; end
    
    filename = [cfg.area num2str(pen(peni).Name)];
    disp(['Loadin penetraion no. ' filename])
     
    load(fullfile(muae,filename))
    
    MuaeData = mean(NormalizedMuae(:,idx1:idx2,:),3);
    
    [latTimes,lsqCurveTimes,lsqFittedCurve,lsqFittedParam,lsqCurveFitErr] = getLatencies(MuaeData,MuaeTimes,dt);
    %
    aligntimes = latTimes;
    aligntimes([1 2 3 14 15 16])  = 100;
    [val,chanidx]    = min(aligntimes);
    elecpositions    = contactPositions*1000;
    
    alignedContacts  = alignChannel(cfg,elecpositions,chanidx);
    
  
    clear  NormalizedMuae 
end




