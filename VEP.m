% Compute VEP for the CSD analysis

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
cfg.CorrectOnlyFlag = true;           % fasle for error trials
cfg.FieldOption     = 'Full';
cfg.TrialOption     = 'NLX_STIM_ON';  % sustain, precue or postcue
cfg.area            = 'e2';
cfg.ExtractMode     = 1;
cfg.StimEvents      = true;
cfg.subjectName     = subjectName;
cfg.Fs              = 1017;
cfg.win             = 2;
cfg.nOfchannel      = 2:15;
%%
FolderName   = '...\VEP';

NOfChan = 1:16;
win     = [0.1 0.2];
nBins   = length(-win(1):1/cfg.Fs:win(2));


for peni = 1:length(pen)
    
    cfg.nevPath          = pen(peni).NEVPath;
    cfg.nevTime          = pen(peni).NLXTime;
    cfg.ctxVersionSwitch = pen(peni).CTXVersionSwitch;
    cfg.ctxPath          = pen(peni).CTXPath;
    cfg.dataDir          = pen(peni).dataDir;
    cfg.Name             = pen(peni).Name;
    
%     Flag = check_peneteration(cfg);
%     if Flag, continue; end
    
    [TrialTimes,Cond] = eventInfo(cfg);
    STIM_ON      = TrialTimes;
    
    
    LFPname = [cfg.area 'LFP%u'];
    LFPs    = zeros(length(NOfChan),nBins,length(STIM_ON));
    % Lfp of the second channel
    for iChan = 1:length(NOfChan)
        
        Filename = [sprintf(LFPname,iChan) '.ncs'];
        NCSpath1 = fullfile(cfg.dataDir,Filename);
        NCS      = NLX_LoadNCS(NCSpath1,cfg.FieldOption,cfg.ExtractMode,[]);
        NC1      = NLX_convertNCS(NCS);
        
        [~,Samples,Times] = NLX_ExtractNCS(NC1,cfg.nevTime ,1);
        Times = Times*10^-6;
        LFPs(iChan,:,:) = FindTrials(cfg,Samples,Times,STIM_ON,win);
        win     = [0.1 0.2];
        SBins   = -win(1):1/cfg.Fs:win(2);

        baseidx = SBins<0;
        residx  = SBins>0;

        LFP_Baseline = LFPs(:,baseidx,:);
        Baselin_Ave  = mean(LFP_Baseline,2);
        demeanEVP    = LFPs - Baselin_Ave;
        stdBaseline  = std(demeanEVP,0,2)+eps;
        NolrmalizedEVP = demeanEVP./ stdBaseline;
        
        SaveName = fullfile(FolderName,[cfg.area pen(peni).Name]);
        save(SaveName,'NolrmalizedEVP','-v7.3');
    end
 
end

%%

fs = 1017;
cmp = jet(length(cfg.nOfchannel));
spm = 1/fs;

xAxis = (0:spm:(size(LfpTrialAvgCsd,2)/fs)-1/fs)*1000;

figure(1)
for chf = 1: size(LfpTrialAvgCsd,1), plot(xAxis,LfpTrialAvgCsd(chf,:),'Color',cmp(chf,:),'LineW',2), hold on, end
h=gca;
yy = get(gca,'YLim');
plot([0.3 0.3],[yy(1) yy(2)],'LineStyle','--','Color','k','LineW',2)
plot([0.75 0.75],[yy(1) yy(2)],'LineStyle','--','Color','k','LineW',2)
xlabel('Time(sec)'),ylabel('Amplitude')
set(h,'fontsize',8),box off
%% Plot Epochs
t = -cfg.win:1/cfg.Fs:cfg.win-1/cfg.Fs;
signal = [mean(LFP_Baseline,3) mean(mEVP,3)];
cmp = jet(length(NOfChan));

figure
for chf = 1: size(signal,1), plot(t,signal(chf,:),'Color',cmp(chf,:),'LineW',2), hold on, end
set(gca, 'TickDir', 'out')
box off
legend(arrayfun(@(x) num2str(x,'ch %.0f'),1:length(NOfChan),'unif',0))
h=gca;
yy = get(gca,'YLim');
plot([0.3 0.3],[yy(1) yy(2)],'LineStyle','--','Color','k','LineW',2)
plot([0.75 0.75],[yy(1) yy(2)],'LineStyle','--','Color','k','LineW',2)
plot([-0.8 -0.8],[yy(1) yy(2)],'LineStyle','--','Color','k','LineW',2)
plot([-1 -1],[yy(1) yy(2)],'LineStyle','--','Color','k','LineW',2)
plot([0 0],[yy(1) yy(2)],'LineStyle','-','Color','k','LineW',2)
set(gca,'xlim',[t(1) t(end)],'fontsize',12,'FontWeight','bold'), title('Wide-Band signal')
set(gca,'XTick',[-1.2 -1 -0.8 0 0.3 0.75 1],'XTickLabel',{'','QUE ON','QUE OFF','STIM ON','STIM OFF',''}),
set(gca,'YTick',[-200 0 200],'YTickLabel',[-200 0 200]),
xlabel('Time(sec)'),ylabel('Amplitude(\mu V)')
box off, grid on, grid minor

