 %% inverse CSD estimation

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
cfg.area            = 'e2';
cfg.trialcodelabel  = 'Att';          % Att, Foc, stim
cfg.ExtractMode     = 1;
cfg.nOfspot         = 60;              % Number of spots below/above the threshold(60 for caesar,60 for richard)
cfg.Freq_threshold  = [70 200];        % Threshold for discard ripple in spectrogram
cfg.filterOrder     = 20;
cfg.win             = 0.2;
cfg.Fs              = 1017;
cfg.StimEvents      = true;
cfg.subjectName     = subjectName;

%% CSD parameters 
contactSpacing     = 1.5e-4; % distance in meter
contactPositions   = (1:length(cfg.nOfchannel )).*contactSpacing;
conductance        = 0.4;    % Taken from Logothetis NK, Kayser C, Oeltermann A. In vivo measurement of cortical impedance spectrum in monkeys: implications for signal propagation. Neuron 55: 809?823, 2007.
diameter           = 10e-4;  % Taken from Mountcastle 1957
filterRange        = 5e-4;   % Taken from Petterson et al Journal of Neurosci Methods 2006
gaussSigma         = 1e-4;   % Taken from Petterson et al Journal of Neurosci Methods 2006
CSDNumSpaceSamples = 2e2;

win       = [0 0.2];
timeVec   = -0.5:1/cfg.Fs:1;
[~,idx1]  = min(abs(timeVec-win(1)));
[~,idx2]  = min(abs(timeVec-win(2)));

dt        = 1e3/cfg.Fs;
MuaeTimes = (win(1):1/cfg.Fs:win(2)+1/cfg.Fs)*1e3;

muae           = '...\Muea';
VEPpath        = '...\VEP';

%
for peni = 1:length(pen)
    
    cfg.Name = pen(peni).Name;
    
    if strcmp([cfg.area cfg.Name],'e1pen027'), continue; end
    
    filename = [cfg.area num2str(pen(peni).Name)];
    disp(['Loadin penetraion no. ' filename])
     
    load(fullfile(muae,filename))
    load(fullfile(VEPpath,filename))
   
    
    LFPwin = [0.1 0.15];
    lfptimes =  -LFPwin(1):1/cfg.Fs:LFPwin(2);
    wind = [0 0.2];
    [~,id1]  = min(abs(lfptimes-wind(1)));
    [~,id2]  = min(abs(lfptimes-wind(2)));
    
    ErPs     = mean(NolrmalizedEVP(:,id1:id2,:),3);
    MuaeData = mean(NormalizedMuae(:,idx1:idx2,:),3);
    
    contactPositions   = (1:length(cfg.nOfchannel )).*contactSpacing;

    [iCSDSamples,iCSDPositions] = computeiCSDCubicSplines(ErPs,contactPositions,conductance,diameter,CSDNumSpaceSamples);
      
    
    [latTimes,lsqCurveTimes,lsqFittedCurve,lsqFittedParam,lsqCurveFitErr] = getLatencies(MuaeData,MuaeTimes,dt);
    %
    aligntimes = latTimes;
    aligntimes([1 2 3 15 16])  = 100;
    [val,chanidx]    = min(aligntimes);
    elecpositions = contactPositions*1000;
    alignedContacts  = alignChannel(cfg,elecpositions,chanidx);
    
    xAxis = (0:1/cfg.Fs:LFPwin(2))*1e3;
    % plot ERPs
    ch_col = zeros(length(cfg.nOfchannel),1,3);
    cmp    = summer(length(cfg.nOfchannel));
%     ch_col(:,1,:) = cmp;
%     
%     imshow(ch_col)
    h=figure('visible','on');
    set(h, 'Position', [0 0 1000 750]);
    subplot(221); for chf = 1: size(ErPs,1), plot(xAxis,ErPs(chf,:),'Color',cmp(chf,:),'LineW',2), hold on, end
    box off, h = gca; xlim([0 150])
    set(h,'fontsize',8,'FontName','Arial'), xlabel('Time(ms)'),ylabel('Amplitude')
    

    % plot CSDs
    subplot(2,2,2)
    imagesc(xAxis,iCSDPositions*1e3,iCSDSamples/max(max(iCSDSamples))),colormap(jet)
    xlim([0 150]) ;colorbar
    h = gca;set(h,'fontsize',8,'FontName','Arial'), xlabel('Time(ms)'),ylabel('Depth(mm)')
    yyaxis left; h.YTickLabel = arrayfun(@(x) num2str(x,'%0.2f'),contactPositions*1e3,'Unif',0);
    h.YTick = elecpositions;
    h = gca; yyaxis right; h.YColor='k'; h.YLim=[iCSDPositions(1) iCSDPositions(end)]*1e3; h.YTick = contactPositions*1e3;

    subplot(223); 
    xAxis = (0:1/cfg.Fs:LFPwin(2)+1/cfg.Fs)*1e3;
    for chf = 1:size(MuaeData,1), plot(xAxis,MuaeData(chf,:),'Color',cmp(chf,:),'LineW',2), hold on, end
    xlim([0 150]);box off, h = gca;
    set(h,'fontsize',8,'FontName','Arial','TickDir', 'out'), xlabel('Time(ms)'),ylabel('Firing rate(Hz)')
    
    
    subplot(224); hold on; plot(latTimes,elecpositions,'-o')
    xlim([30 max(latTimes)+5])
    box off, h = gca;set(gca, 'YDir','reverse')
    set(h,'fontsize',8,'FontName','Arial','TickDir', 'out'), xlabel('Latency (ms)'),ylabel('Depth (mm)')
    
    savename = fullfile('D:\SWR-Results\27-02-2021\layers',[cfg.area pen(peni).Name]);
    save(savename,'alignedContacts')
    
    figname = [savename '.png'];
    saveas(h,figname);
    
    close all
    clear iCSDSamples NormalizedMuae NolrmalizedEVP
end




