% grand average spectrogram of all ripple dected within an area

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
cfg.CorrectOnlyFlag = true;            %fasle for error trials
cfg.FieldOption     = 'Full';
cfg.TrialOption     = 'sustain';       % sustain, precue or postcue,intt, all
cfg.area            = 'e1';
cfg.trialcodelabel  = 'Att';           % Att, Foc, stim 
cfg.ExtractMode     = 1;
cfg.nOfspot         = 60;              % Number of spots below/above the threshold(60 for caesar,60 for richard)
cfg.Freq_threshold  = [70 200];        % Threshold for discard ripple in spectrogram 
cfg.filterOrder     = 20;
cfg.win             = 0.3;
cfg.StimEvents      = true;                   
cfg.subjectName     = subjectName;
cfg.frange          = [80 250];
cfg.Fs              = 1017;
cfg.fpass           = [20 250];
cfg.movingwin       = [0.196,0.005];

 %% Get correct ripples
 
Spect = zeros(length(pen),69,46,length(cfg.nOfchannel));
 
for peni = 1:length(pen)
    
    cfg.nevPath          = pen(peni).NEVPath;
    cfg.nevTime          = pen(peni).NLXTime;
    cfg.ctxVersionSwitch = pen(peni).CTXVersionSwitch;
    cfg.ctxPath          = pen(peni).CTXPath;
    cfg.dataDir          = pen(peni).dataDir;
    cfg.Name             = pen(peni).Name;
    cfg.Name             = pen(peni).Name;
    
   Flag = check_peneteration(cfg); 
   if Flag, continue; end
   
      [TrialTimes,Cond] = eventInfo(cfg);
      totalTime         = sum(TrialTimes(:,2) - TrialTimes(:,1));
      

%       Z = zeros(69,46,length(cfg.nOfchannel));
      
       for iChan = cfg.nOfchannel  
        
            [Samples,Times]          = Bipolar_referencing(cfg,iChan);
            [XR,~]                   = ripple_detction(cfg,Samples,Times);  
            [Allrpls,correctripples] = get_true_ripple(cfg,Samples,Times,TrialTimes,XR); 
            RplsTimes                = correctripples(all(correctripples,2),:);
    
            if isempty(RplsTimes), continue; end

       
            [t,freq,Spect(peni,:,:,iChan-1) ] = average_spectrogramc(cfg,Samples,Times,RplsTimes);     
       end  
      
end


 % plot ripples
 figure;
 
 for ii =1:size(Spect,4)
      
    subplot(2,7,ii)
    chan = (squeeze(mean(Spect(:,:,:,ii),1)));
    imagesc(t,freq,10*log10(chan)'), box off, 
    h = gca;
    set(h,'fontsize',8,'FontName','Arial'),set(gca, 'TickDir', 'out')
    colormap(jet)
    if ii == size(Spect,4)
        colorbar
    end
    caxis([35,50])
    axis xy, axis square
       
 end

 