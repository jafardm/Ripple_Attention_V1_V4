function Eventstimes = getEventsTimes(cfg)
%
%  Return time of cue and stin_on in second

% SPK     = makeSPK_create(penInfo.NEVPath, penInfo.NLXTime, penInfo.CTXVersionSwitch, penInfo.CTXPath);

SPK = makeSPK_create(cfg);

% Times in SPK file are in milli-second

eventLabels = SPK.eventlabel;
events      = SPK.events; 
align       = SPK.align; 
     
StimEvents = {'NLX_CUE_ON';'NLX_STIM_ON'}; 
Eventstimes = zeros(size(events,2),length(StimEvents));

        for jj = 1:size(events,2)
             Ts    = events{strcmp(eventLabels,StimEvents(1)),jj} + align(jj);
             Tend  = events{strcmp(eventLabels,StimEvents(2)),jj} + align(jj);
             Eventstimes(jj,:) = [Ts(1) Tend(1)];   
        end

 Eventstimes = Eventstimes * 10^-3; % convert time to sec
 
