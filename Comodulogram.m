% power correlaion at the ripple times in V1 and V4

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

cfg.ctxEyeFlag      = false;
cfg.ctxEPPFlag      = false;
cfg.CorrectOnlyFlag = true;            %fasle for error trials
cfg.FieldOption     = 'Full';
cfg.TrialOption     = 'sustain';       % sustain, precue or postcue,intt, all
cfg.area            = 'e1';            % V1: e1, V4: e2
cfg.trialcodelabel  = 'Att';           % Att, Foc, stim
cfg.ExtractMode     = 1;
cfg.nOfspot         = 60;              % Number of spots below/above the threshold(60 for caesar,60 for richard)
cfg.Freq_threshold  = [70 200];        % Threshold for discard ripple in spectrogram
cfg.filterOrder     = 20;
cfg.win             = 0.2;
cfg.StimEvents      = true;
cfg.subjectName     = subjectName;
cfg.frange          = [80 200];
cfg.Fs              = 1017;
cfg.freqrange       = [3 250];      % frequencies fo wavelet(in Hz)
cfg.numfrex         = 40;           % number of frequencies between lowest and highest
cfg.fpass           = [5 220];      % frequency range for plot spectrogram
cfg.Fs              = 1017;
cfg.fpass           = [5 250];
cfg.movingwin       = [0.196,0.005];
cfg.tEDF            = -cfg.win:1/1/cfg.Fs:cfg.win;
%%
nOffreq    = cfg.numfrex;
win        = [0.5 1];
timeVec    = -win(1):1/cfg.Fs:win(2)+1/cfg.Fs;
nBins      = round(cfg.win*cfg.Fs);
nOfChannel = 1:14;

ModulogramTotal     = zeros(nOffreq,nOffreq,length(nOfChannel),length(nOfChannel),length(pen));
ModulogramTotalStd  = zeros(nOffreq,nOffreq,length(nOfChannel),length(nOfChannel),length(pen));
ModulogramShuffle   = zeros(nOffreq,nOffreq,length(nOfChannel),length(nOfChannel),length(pen));
ModulogramTotalCell = cell(length(nOfChannel),length(pen));

dataPath = '...\LFP';

e1Channels = 1:14;

for peni = 1:length(pen)
    
    cfg.Name = pen(peni).Name;
    Flag = check_peneteration4correlation(cfg);
    if Flag, continue; end
    
    disp(['Loading penetration: ' num2str(pen(peni).Name)])
    LfpName1 = ['e1' num2str(pen(peni).Name)];
    load(fullfile(dataPath,LfpName1))
    
    e1LFP = LFPs;
    e1Ripples = ripples;
    
    LfpName2 = ['e2' num2str(pen(peni).Name)];
    load(fullfile(dataPath,LfpName2))
    e2LFP = LFPs;
    
    nTrials = 1:size(e2LFP,1);
    
    for ii = 1:length(e1Channels)
        
        ChannelsRipples = e1Ripples{ii,1};
        
        if isempty(ChannelsRipples), continue, end
            
        TrialWripple   = ChannelsRipples(:,end);
        trialWorippl   = nTrials(~ismember(nTrials,TrialWripple));
        randomidx      = trialWorippl(randperm(numel(trialWorippl),length(TrialWripple)));
%         randomidx      = randperm(nTrials(end),length(TrialWripple));
        
        for jj = 1:size(ChannelsRipples,1)
            
            [~,idx]   = min(abs(timeVec - ChannelsRipples(jj,2)));
            e1ChanLFP = e1LFP(ChannelsRipples(jj,end),idx-nBins:idx+nBins,ii); 
            [t,frex,e1Spect]   = waveletSpectrogram(cfg,e1ChanLFP'); 
            
            Modulogram         = zeros(nOffreq,nOffreq,size(ChannelsRipples,1),length(nOfChannel));
            shuffle_modulogram = zeros(nOffreq,nOffreq,size(ChannelsRipples,1),length(nOfChannel));
            
            for k = 1:length(e1Ripples)
                
                e2ChanLFP  = e2LFP(ChannelsRipples(jj,end),idx-nBins:idx+nBins,k);
                e2shauffle = e2LFP(randomidx(jj),idx-nBins:idx+nBins,k);
                 
                [t,frex,e2Spect]   = waveletSpectrogram(cfg,e2ChanLFP');
                [~,~,spectshuffle] = waveletSpectrogram(cfg,e2shauffle');
                
                R_raw = atanh(corr(e1Spect',e2Spect'));
                R_shuffle = atanh(corr(e1Spect',spectshuffle'));
                
                Modulogram(:,:,jj,k)         = R_raw;
                shuffle_modulogram(:,:,jj,k) = R_shuffle;
            end
            
        end
        
        ModulogramTotal(:,:,:,ii,peni)    = squeeze(nanmean(Modulogram,3));
        ModulogramTotalStd(:,:,:,ii,peni) = squeeze(nanstd(Modulogram,0,3));
        ModulogramShuffle(:,:,:,ii,peni)  = squeeze(nanmean(shuffle_modulogram,3));
        ModulogramTotalCell{ii,peni}      = Modulogram;
    end
    clear e1LFP e2LFP
end

