function [TrialTimes,CndIdx] = eventInfo(cfg)
%
%  
% SPK     = makeSPK_create(penInfo.NEVPath, penInfo.NLXTime, penInfo.CTXVersionSwitch, penInfo.CTXPath);

SPK = makeSPK_create(cfg);

% Times in SPK file are in milli-second

eventLabels = SPK.eventlabel;
events      = SPK.events; 
align       = SPK.align; 


 if cfg.CorrectOnlyFlag &&  strcmpi(cfg.TrialOption,'precue') %% precue
     
     disp('Loading Precue trial times.')
     
    StimEvents = {'NLX_CUE_ON';'NLX_STIM_ON'}; 
    Eventstimes = zeros(size(events,2),length(StimEvents));

            for jj = 1:size(events,2)
                 Ts    = events{strcmp(eventLabels,StimEvents(1)),jj} + align(jj);
                 Tend  = events{strcmp(eventLabels,StimEvents(2)),jj} + align(jj);
                 Eventstimes(jj,:) = [Ts(1) Tend(1)];   
            end

     Eventstimes = Eventstimes * 10^-3; % convert time to sec
     TrialTimes  = [Eventstimes(:,1)-0.2 Eventstimes(:,1)];  % 200 ms before cue to cue_On

 elseif cfg.CorrectOnlyFlag &&  strcmpi(cfg.TrialOption,'postcue')  %% post cue
     
     disp('Loading postcue trial times.')
     
     StimEvents = {'NLX_CUE_ON';'NLX_STIM_ON'}; 
     
     Eventstimes = zeros(size(events,2),length(StimEvents));
     
     for jj = 1:size(events,2)
         Ts    = events{strcmp(eventLabels,StimEvents(1)),jj} + align(jj);
         Tend  = events{strcmp(eventLabels,StimEvents(2)),jj} + align(jj);
         Eventstimes(jj,:) = [Ts(1) Tend(1)];   
     end

     Eventstimes = Eventstimes * 10^-3; % convert time to sec
     TrialTimes  = [Eventstimes(:,2)-0.8 Eventstimes(:,2)];          % 800 ms before Stim_On to Stim_On
         
     elseif cfg.CorrectOnlyFlag &&  strcmpi(cfg.TrialOption,'sustain')  %% sustain
         
        StimEvents = {'NLX_CUE_ON';'NLX_STIM_ON'};
        
         disp('Loading sustain trial times.')
         
        Eventstimes = zeros(size(events,2),length(StimEvents));

            for jj = 1:size(events,2)
                 Ts    = events{strcmp(eventLabels,StimEvents(1)),jj} + align(jj);
                 Tend  = events{strcmp(eventLabels,StimEvents(2)),jj} + align(jj);
                 Eventstimes(jj,:) = [Ts(1) Tend(1)];   
            end

         Eventstimes = Eventstimes * 10^-3; % convert time to sec
         TrialTimes  = [Eventstimes(:,2)+0.3  Eventstimes(:,2)+0.75];   % 300 ms after Stim_on to 750 ms after Stim_on
 
     elseif  strcmpi(cfg.TrialOption,'intt')   %% inter-trails
     
        disp('Loading error trial times.')
        
        StimEvents      = {'NLX_TRIAL_START';'NLX_TRIAL_END'};
        Eventstimes = zeros(size(events,2),length(StimEvents));

            for jj = 1:size(events,2)
                 Ts    = events{strcmp(eventLabels,StimEvents(1)),jj} + align(jj);
                 Tend  = events{strcmp(eventLabels,StimEvents(2)),jj} + align(jj);
                 Eventstimes(jj,:) = [Ts(1) Tend(1)];   
            end

         Eventstimes = Eventstimes * 10^-3; % convert time to sec
         TrialTimes  = [Eventstimes(1:end-1,2) Eventstimes(2:end,1)];
         
 elseif cfg.CorrectOnlyFlag &&  strcmpi(cfg.TrialOption,'NLX_STIM_ON')  %% stimulus onset
        
        disp('Loading stimulus on trial times.')
        
        StimEvents = {'NLX_STIM_ON'}; 
        Eventstimes = zeros(size(events,2),length(StimEvents));

            for jj = 1:size(events,2)
                 Ts    = events{strcmp(eventLabels,StimEvents),jj} + align(jj);
                 Eventstimes(jj,:) = Ts(1);   
            end
            TrialTimes = Eventstimes *10^-3; % convert time to sec
            
 elseif    cfg.CorrectOnlyFlag &&  strcmpi(cfg.TrialOption,'all')  %% precue-postcue-sustain(correct)
     
        disp('Loading all trial times.')
        
        StimEvents = {'NLX_CUE_ON';'NLX_STIM_ON'};
        
        Eventstimes = zeros(size(events,2),length(StimEvents));

            for jj = 1:size(events,2)
                 Ts    = events{strcmp(eventLabels,StimEvents(1)),jj} + align(jj);
                 Tend  = events{strcmp(eventLabels,StimEvents(2)),jj} + align(jj);
                 Eventstimes(jj,:) = [Ts(1) Tend(1)];   
            end
            
        Eventstimes = Eventstimes *10^-3; % convert time to sec
        TrialTimes = [Eventstimes(:,1)-0.2 Eventstimes(:,1) Eventstimes(:,2)-0.8 Eventstimes(:,2) Eventstimes(:,2)+0.3 Eventstimes(:,2)+0.75];
 else
     
     disp('Trial Option mode is not correct.')

 end
 
 TrialCodeLabel = SPK.trialcodelabel;
    
switch cfg.subjectName
    
    case  'Richard'
        
     % 38:currAtt, 40:currFoc, 39:currStim 
    attentionIDX = find(ismember(TrialCodeLabel,'currAtt'));
    FocIDX       = find(ismember(TrialCodeLabel,'currFoc'));
    SizeIDX      = find(ismember(TrialCodeLabel,'currStim'));
    trialcode    = SPK.trialcode;
    
    CndIdx.AttBlocks = trialcode(attentionIDX,:);
    CndIdx.FocBlocks = trialcode(FocIDX,:);
     
    IDXin        =  find(trialcode(attentionIDX,:) == 1);
    CndIdx.IDxin = IDXin;
    
    IDXout        = find(trialcode(attentionIDX,:)== 2);
    CndIdx.IDxout = IDXout;
    
     Narrow        = find(trialcode(FocIDX,:) == 1);
     CndIdx.Narrow = Narrow;
     
     Wide          = find(trialcode(FocIDX,:) == 2);
     CndIdx.Wide   = Wide;
     
     sizNum        = unique(trialcode(SizeIDX,:));
     Large         = find(trialcode(SizeIDX,:) == sizNum(1));
     CndIdx.Large = Large;
     
     Small         = find(trialcode(SizeIDX,:) == sizNum(2));
     CndIdx.Small  = Small;
     
    uniTskCnd = unique(trialcode(SizeIDX,:)' ,'rows');
    
     
    allTskCnd = trialcode([attentionIDX FocIDX SizeIDX],:)';                  
    CndIdx.IDInNLa = find( ismember(allTskCnd, [1 1 uniTskCnd(1)], 'rows') );                  
    CndIdx.IDInNSm = find( ismember(allTskCnd, [1 1 uniTskCnd(2)], 'rows') );

    CndIdx.IDInWLa = find( ismember(allTskCnd, [1 2 uniTskCnd(1)], 'rows') );
    CndIdx.IDInWSm = find( ismember(allTskCnd, [1 2 uniTskCnd(2)], 'rows') );

    CndIdx.IDOutNLa = find( ismember(allTskCnd, [2 1 uniTskCnd(1)], 'rows') );  
    CndIdx.IDOutNSm = find( ismember(allTskCnd, [2 1 uniTskCnd(2)], 'rows') );

    CndIdx.IDOutWLa = find( ismember(allTskCnd, [2 2 uniTskCnd(1)], 'rows') );
    CndIdx.IDOutWSm = find( ismember(allTskCnd, [2 2 uniTskCnd(2)], 'rows') );
%

    case   'Caesar'
        
       % 41:iAtt, 43:iFoc, 42:iSize    
     attentionIDX = find(ismember(TrialCodeLabel,'iAtt'));
     FocIDX       = find(ismember(TrialCodeLabel,'iFoc'));
     SizeIDX      = find(ismember(TrialCodeLabel,'iStim')); 
     
     trialcode    = SPK.trialcode;
     
     CndIdx.AttBlocks = trialcode(attentionIDX,:);
     CndIdx.FocBlocks = trialcode(FocIDX,:);
     
     IDXin        =  find(trialcode(attentionIDX,:) == 1);
     CndIdx.IDxin = IDXin;
    
     IDXout        = find(trialcode(attentionIDX,:)== 2);
     CndIdx.IDxout = IDXout;
     
     Narrow        = find(trialcode(FocIDX,:) == 1);
     CndIdx.Narrow = Narrow;
     
     Wide        = find(trialcode(FocIDX,:) == 2);
     CndIdx.Wide = Wide;
     
     sizNum        = unique(trialcode(SizeIDX,:));
     Large         = find(trialcode(SizeIDX,:) == sizNum(1));
     CndIdx.Large = Large;
     
     Small        = find(trialcode(SizeIDX,:) == sizNum(2));
     CndIdx.Small = Small;
     
     
     uniTskCnd = unique(trialcode(SizeIDX,:)' ,'rows');
     
     allTskCnd = trialcode([attentionIDX FocIDX SizeIDX],:)';                     
     CndIdx.IDInNLa = find( ismember(allTskCnd, [1 1 uniTskCnd(1)], 'rows') );                  
     CndIdx.IDInNSm = find( ismember(allTskCnd, [1 1 uniTskCnd(2)], 'rows') );

     CndIdx.IDInWLa = find( ismember(allTskCnd, [1 2 uniTskCnd(1)], 'rows') );
     CndIdx.IDInWSm = find( ismember(allTskCnd, [1 2 uniTskCnd(2)], 'rows') );

     CndIdx.IDOutNLa = find( ismember(allTskCnd, [2 1 uniTskCnd(1)], 'rows') );  
     CndIdx.IDOutNSm = find( ismember(allTskCnd, [2 1 uniTskCnd(2)], 'rows') );
 
     CndIdx.IDOutWLa = find( ismember(allTskCnd, [2 2 uniTskCnd(1)], 'rows') );
     CndIdx.IDOutWSm = find( ismember(allTskCnd, [2 2 uniTskCnd(2)], 'rows') );
    
end
% allTskCnd = trialcode([41 43 42],:)';
% allTskCnd = trialcode([38 40 39],:)';


% TS{1,1}  = 'All Trials';
% TS{2,1}  = 'IDxin';  
% TS{3,1}  = 'IDxout'; 
% TS{4,1}  = 'IDInNLa'; 
% TS{5,1}  = 'IDInNSm'; 
% TS{6,1}  = 'IDInWLa'; 
% TS{7,1}  = 'IDInWSm';
% TS{8,1}  = 'IDOutNLa';
% TS{9,1}  = 'IDOutNSm'; 
% TS{10,1} = 'IDOutWLa'; 
% TS{11,1} = 'IDOutWSm';
% %
% 
% TS{1,2}  = sum(length(IDXin) + length(IDXout));
% TS{2,2}  = length(IDXin); 
% TS{3,2}  = length(IDXout);
% TS{4,2}  = length(CndIdx.IDInNLa);  
% TS{5,2}  = length(CndIdx.IDInNSm); 
% TS{6,2}  = length(CndIdx.IDInWLa);   
% TS{7,2}  = length(CndIdx.IDInWSm); 
% TS{8,2}  = length(CndIdx.IDOutNLa); 
% TS{9,2}  = length(CndIdx.IDOutNSm); 
% TS{10,2} = length(CndIdx.IDOutWLa); 
% TS{11,2} = length(CndIdx.IDOutWSm);
% 
% CndIdx.TS = TS;
  
end

