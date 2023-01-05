function [Samples,Times]= Bipolar_referencing(cfg,channel)

% channel sould be a number including 2 to 15.
% for example channel 2 = 3-1.
% scale of samples is in micro volt
% scale of time is in second

LFPname = [cfg.area 'LFP%u'];
% Lfp of the second channel
Filename = [sprintf(LFPname,channel+1) '.ncs'];
NCSpath1 = fullfile(cfg.dataDir,Filename);
NCS      = NLX_LoadNCS(NCSpath1,cfg.FieldOption,cfg.ExtractMode,[]);
NC1      = NLX_convertNCS(NCS);

[~,Samples1,~] = NLX_ExtractNCS(NC1,cfg.nevTime ,1);

% Lfp of the first channel
Filename = [sprintf(LFPname,channel-1) '.ncs'];
NCSpath2 = fullfile(cfg.dataDir,Filename);
NCS      = NLX_LoadNCS(NCSpath2,cfg.FieldOption,cfg.ExtractMode,[]);
NC2      = NLX_convertNCS(NCS);

[~,Samples2,Times] = NLX_ExtractNCS(NC2,cfg.nevTime,1);

Samples = Samples1 - Samples2;
    
Times = Times*10^-6;

% NCS = NLX_LoadNCS(NCSpath,NCSParam.FieldOption,NCSParam.ExtractMode,[]);
% [NCS,Samples,Times] = NLX_ExtractNCS(NCS,NLXTime,1);
% Times = Times*10^-6;      % convert time to sec
    
