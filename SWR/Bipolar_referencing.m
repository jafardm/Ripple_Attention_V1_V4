function [Samples,time]= Bipolar_referencing(cfg,channel)

% channel sould be a number including 2 to 15.
% for example channel 2 = 3-1.
% scale of samples is in micro volt
% scale of time is in second



LFPname = [cfg.area 'LFP%u'];
% Lfp of the second channel
Filename = fullfile([cfg.datasetdir cfg.Name], sprintf(LFPname,channel+1));
load(Filename)

disp(['loading Channel  number: ' num2str(channel)])

Samples1 = LFps;

% Lfp of the first channel
Filename = fullfile([cfg.datasetdir cfg.Name], sprintf(LFPname,channel-1));
load(Filename)

Samples2 = LFps;
Samples = Samples1 - Samples2;
    
time = (1/cfg.Fs:1/cfg.Fs:length(Samples)/cfg.Fs)';

