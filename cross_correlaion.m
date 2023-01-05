% temporal correlation of ripples in V1 and V4

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
cfg.CorrectOnlyFlag = true;           % fasle for error trials
cfg.FieldOption     = 'Full';
cfg.TrialOption     = 'sustain';          % sustain, precue or postcue,intt, all
cfg.area            = 'e1';
cfg.trialcodelabel  = 'Att';          % Att, Foc, stim
cfg.ExtractMode     = 1;
cfg.nOfspot         = 60;              % Number of spots below/above the threshold(60 for caesar,60 for riiard)
cfg.Freq_threshold  = [70 200];        % Threshold for discard ripple in spectrogram
cfg.win             = 0.3;
cfg.StimEvents      = true;
cfg.subjectName     = subjectName;
cfg.frange          = [80 250];
cfg.Fs              = 1017;
cfg.filterOrder     = 20;
cfg.fpass           = [20 250];
cfg.movingwin       = [0.196,0.005];
cfg.sigma           = 50;
cfg.maxlag          = 150;
%%
XC      = nan(2*cfg.maxlag+1,length(pen));
SC      = nan(2*cfg.maxlag+1,length(pen));
% XC_cell = cell(length(cfg.nOfchannel),length(pen));

dataPath = 'D:\SWR-Results\27-02-2021\LFP';
wint    = [0.5 1];
TimeVec = -wint(1):1/cfg.Fs:wint(2)+1/cfg.Fs;
idx = find(TimeVec>0.3);

for peni = 1:length(pen)
    
    cfg.Name = pen(peni).Name;
   Flag = check_peneteration4correlation(cfg);
    if Flag, continue; end
    
    disp(['Loading penetration: ' num2str(pen(peni).Name)])
    LfpName1 = ['e1' num2str(pen(peni).Name)];
    load(fullfile(dataPath,LfpName1))
    e1LFP = LFPs(:,idx:end,:);
    e1LFP = e1LFP - mean(e1LFP,1);
    clear LFPs

    LfpName2 = ['e2' num2str(pen(peni).Name)];
    load(fullfile(dataPath,LfpName2))
    e2LFP = LFPs(:,idx:end,:);
    e2LFP = e2LFP - mean(e2LFP,1);
    clear LFPs
    
    e1Trials = zeros(size(e1LFP));
    e2Trials = zeros(size(e2LFP));

    for chan = 1:size(e1LFP,3)
        data1 = abs(filter_data(e1LFP(:,:,chan)', cfg.Fs, 100, 200));
        up1 = envelope(data1,50,'rms');
        e1Trials(:,:,chan) = filter_data(up1, cfg.Fs, 1, 20)';
    
        data2 = abs(filter_data(e2LFP(:,:,chan)', cfg.Fs, 100, 200));
        up2 = envelope(data2,50,'rms');
        e2Trials(:,:,chan) = filter_data(up2, cfg.Fs, 1, 20)';
    end

    shuftrls  = e2Trials(randperm(size(e2Trials,1)),:,:);
 
    XCorr    = nan(size(e2Trials,1),2*cfg.maxlag+1,size(e2Trials,3),size(e2Trials,3));
    shuffled = nan(size(e2Trials,1),2*cfg.maxlag+1,size(e2Trials,3),size(e2Trials,3));
    
    for ii = 1:size(e1Trials,3)
        for jj = 1:size(e2Trials,3)
            for k = 1:size(e2Trials,1)
                [XCorr(k,:,jj,ii),Lags] = xcorr(squeeze(e2Trials(k,:,ii)),squeeze(e1Trials(k,:,jj)),cfg.maxlag,'coeff');
                [shuffled(k,:,jj,ii),~] = xcorr(squeeze(shuftrls(k,:,jj)),squeeze(e1Trials(k,:,ii)),cfg.maxlag,'coeff');
            end
        end
    end 
   XC(:,peni) =  nanmean(nanmean(nanmean(XCorr,4),3));
   SC(:,peni) =  nanmean(nanmean(nanmean(shuffled,4),3));
end

