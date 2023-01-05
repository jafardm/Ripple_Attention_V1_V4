function TrialTimes = eventTimes(penInfo,evets2select)
%
%  
  
SPK     = makeSPK_create(penInfo.NEVPath, penInfo.NLXTime, penInfo.CTXVersionSwitch, penInfo.CTXPath);

% Times in SPK file are in milli-second
eventLabels = SPK.eventlabel;
events    = SPK.events; 
TrialTimes    = cell2mat(events(strcmp(eventLabels,evets2select),:)) + SPK.align;


TrialTimes = TrialTimes* 10^-3; % convert time to sec


  
