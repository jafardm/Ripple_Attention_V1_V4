% compute comodulogram of ripple in layers

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
cfg.area            = 'e2';
cfg.trigger         = 'infra';           % gran, sup, infra
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
cfg.freqrange       = [2 250];       % frequencies fo wavelet(in Hz)
cfg.numfrex         = 40;            % number of frequencies between lowest and highest
% cfg.fpass         = [20 220];      % frequency range for plot spectrogram
cfg.Fs              = 1017;
%%
nOffreq    = cfg.numfrex;
win        = [0.5 1];
timeVec    = -win(1):1/cfg.Fs:win(2)+1/cfg.Fs;
nBins      = round(0.2*cfg.Fs);
nOfChannel = 1:14;


dataPath = '...\LFP';
CsdPath  = '...\layers';

for peni = 1:length(pen)
    
    cfg.Name = pen(peni).Name;
    Flag = check_peneteration(cfg);
    if Flag, continue; end
    
    disp(['Loading penetration: ' num2str(pen(peni).Name)])
    LfpName1 = [cfg.area num2str(pen(peni).Name)];
    load(fullfile(dataPath,LfpName1))
    
    filename = [cfg.area num2str(pen(peni).Name)];
    load(fullfile(CsdPath,filename))
    sup = alignedContacts.SupraGranular;
    L1 = sup(sup>0);
    gran = alignedContacts.Granular;
%     L2 = L2(L2>0);
    L3 = alignedContacts.infraGranular;
    infra = L3(L3<15);
    
    e1LFP = LFPs;
    e1Ripples = ripples;
    
    nTrials = 1:size(e1LFP,1);
    
    if strcmp(cfg.trigger,'sup')
          trigger = sup;
    elseif strcmp(cfg.trigger,'gran')
          trigger = gran;
    elseif strcmp(cfg.trigger,'infra')
          trigger = infra;
    end
    
    if isempty(trigger), continue, end
   
    for ii =1:length(trigger)
        
        triger_ripples = e1Ripples{trigger(ii)};
        
        if isempty(triger_ripples), continue, end
        
        TrialWripple   = triger_ripples(:,end);
        trialWorippl   = nTrials(~ismember(nTrials,TrialWripple));
        randomidx      = trialWorippl(randperm(numel(trialWorippl),length(TrialWripple))); 
        
        for jj = 1:size(triger_ripples,1)
             [~,idx]   = min(abs(timeVec - triger_ripples(jj,2)));
             triggerLFP = e1LFP(triger_ripples(jj,end),idx-nBins:idx+nBins,ii); 
           
            [t,frex,spect1]   = waveletSpectrogram(cfg,triggerLFP'); 
            
            signalChans = gran; % define the signal
            Modulogram         = zeros(nOffreq,nOffreq,size(triger_ripples,1),length(signalChans));
            shuffle_modulogram = zeros(nOffreq,nOffreq,size(triger_ripples,1),length(signalChans));
            
            for k = 1:length(signalChans)
                ChanLFP     = e1LFP(triger_ripples(jj,end),idx-nBins:idx+nBins,signalChans(k));
                if all(ChanLFP==0), continue, end
                shauffleLFP = e1LFP(randomidx(jj),idx-nBins:idx+nBins,signalChans(k));
                 
                [~,~,spect2]   = waveletSpectrogram(cfg,ChanLFP'); 
                [~,~,spectS]   = waveletSpectrogram(cfg,shauffleLFP'); 
                
                 Modulogram(:,:,jj,k)         = atanh(corr(spect1',spect2'));
                shuffle_modulogram(:,:,jj,k) =  atanh(corr(spect1',spectS'));
            end
        end

        ModulogramTotalCell{ii,peni}      = nanmean(squeeze(nanmean(Modulogram,3)),3)-...
            nanmean(squeeze(nanmean(shuffle_modulogram,3)),3);
    end
end

%%
emptyidx = cellfun(@isempty,ModulogramTotalCell);
ModulogramTotalCell(all(emptyidx,2),:) = [];
emptyidx = cellfun(@isempty,ModulogramTotalCell);
ModulogramTotalCell(:,all(emptyidx,1)) = [];
total_modulgram = cat(3,ModulogramTotalCell{:});
total_modulgram(isinf(total_modulgram)) = 0;
total_modulgram(:,:,squeeze(any(~any(total_modulgram,1),2))) = [];
savePath = fullfile('D:\SWR-Results\27-02-2021\Modulogram\Layer',[cfg.subjectName(1) cfg.area cfg.trigger '-gran']);
save(savePath,'total_modulgram','frex')
%%

aveCorr  = nanmean(total_modulgram,3);

pval  = zeros(size(total_modulgram,1),size(total_modulgram,1));

for m = 1:size(total_modulgram,1)
    for n = 1:size(total_modulgram,2)
        [~,pval(m,n)] = ttest(squeeze(total_modulgram(m,n,:)));
    end
end

alpha = 0.05;
[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(pval,alpha,'pdep','yes');

%%
fig = figure('Units','normalized','Position',[0 0 0.3 1]);

subplot(311)
surf(frex,frex,aveCorr,'EdgeColor','none'), colormap('jet'), colorbar; view(0,90); axis tight;
set(gca,'fontsize',8,'Fontname','Arial','TickDir', 'out'),box off
subplot(312)
contourf(frex,frex,log10(1./pval),40,'linecolor','none'),colormap('jet'), colorbar
subplot(313)
contourf(frex,frex,h,40,'linecolor','none'),colormap('jet'), colorbar
set(gca,'fontsize',8,'Fontname','Arial','TickDir', 'out'),box off