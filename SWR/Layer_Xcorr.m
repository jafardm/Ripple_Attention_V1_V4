function [XC,SC,lags] = Layer_Xcorr(RipplesFilePath,CSDPath,Area,penInfo,maxlags)

fs = 1017;
XC = zeros(1,2*maxlags+1,3);
SC = zeros(1,2*maxlags+1,3);

PenNum = [Area penInfo.Name];

[SG,G,IG] =  SWR_Layer_Channels(CSDPath,PenNum);

  
    SPK      = makeSPK_create(penInfo.NEVPath, penInfo.NLXTime, penInfo.CTXVersionSwitch, penInfo.CTXPath);
    % Times in SPK file are in milli-second
    events   = SPK.events;
    TrialST  = SPK.align;                         
    STIM_ON  = TrialST + cell2mat(events(3,:)); 
    STIM_OFF = TrialST + cell2mat(events(4,:))+ 100;      % shift stimulus offset 100 ms
    TrialEnd = STIM_OFF + 600;

    TrialTimes = [TrialST' STIM_ON' STIM_OFF' TrialEnd']*1e-3; % convert time to second
    Times = TrialTimes(1,1):1/fs:TrialTimes(end,end);
    Times = Times-Times(1);
    
    % Load ripples results

    sprintf(['Loading ripples file: ' Area penInfo.Name '.mat'])
    load([RipplesFilePath Area penInfo.Name '.mat'])
    
    % seperate supra-gran ripples
    supraGran = ismember(vertcat(ripplesInfo.Channel), SG);
    S_ripples   = vertcat(ripplesInfo(supraGran).ripples);
    
    S_ripples = (S_ripples -  TrialTimes(1,1));
    
   % binerize supra-gran ripples
     S_binned = zeros(1,length(Times));
     
    for ii = 1:size(S_ripples,1)
        
        [~,start]     = min(abs(Times-S_ripples(ii,1)));
        [~,endd]      = min(abs(Times-S_ripples(ii,3)));
         S_binned(start:endd)= 1;
    end
    
    % shuffle supra ripples
    S_shuffled = S_binned(randperm(length(S_binned)));

     % seperate Gran ripples
    Gran = ismember(vertcat(ripplesInfo.Channel), G);
    G_ripples = vertcat(ripplesInfo(Gran).ripples);
    
    G_ripples = (G_ripples -  TrialTimes(1,1));
    
   % binerize granular ripples
     G_binned = zeros(1,length(Times));
     
    for ii = 1:size(G_ripples,1)
        
        [~,start]     = min(abs(Times - G_ripples(ii,1)));
        [~,endd]      = min(abs(Times - G_ripples(ii,3)));
         G_binned(start:endd)= 1;
    end
    
    
    % seperate Gran ripples
    Infra = ismember(vertcat(ripplesInfo.Channel), IG);
    Inf_ripples = vertcat(ripplesInfo(Infra).ripples);
    
    Inf_ripples = (Inf_ripples -  TrialTimes(1,1));
    
   % binerize granular ripples
     Inf_binned = zeros(1,length(Times));
     
    for ii = 1:size(Inf_ripples,1)
        
        [~,start]     = min(abs(Times - Inf_ripples(ii,1)));
        [~,endd]      = min(abs(Times - Inf_ripples(ii,3)));
         Inf_binned(start:endd)= 1;
    end
    
    % shuffle infra-ripples
    Inf_shuffled = Inf_binned(randperm(length(Inf_binned)));
    
    % compute correlation 
   [GS, ~] = xcorr(G_binned,S_binned,maxlags,'coeff');  
   [GSS, ~]= xcorr(G_binned,S_shuffled,maxlags,'coeff');
   
   XC(:,:,1) = GS - GSS; % Gran Vs supra
   SC(:,:,1) =  GSS;
   
   [GI, ~]   = xcorr(G_binned,Inf_binned,maxlags,'coeff');
   [GIS, ~]  = xcorr(G_binned,Inf_shuffled,maxlags,'coeff');
   
   XC(:,:,2) = GI - GIS; % Gran Vs Infra
   SC(:,:,2) = GIS;
   
   [IS, ~]     = xcorr(Inf_binned,S_binned,maxlags,'coeff');
   [ISS, lags] = xcorr(Inf_binned,S_shuffled,maxlags,'coeff');
   
    XC(:,:,3)  = IS - ISS;  % Infra Vs Supra
    SC(:,:,3)  = ISS;
    
     
end