function Chans =  Layer_Channels(cfg,CSDfilename)

% selectedChans:   channels in the cortex based on CSD profile
% LaminaeRipples:  Ripples number in individual layer 

load(CSDfilename)
    
if strcmpi(cfg.area,'e1') && strcmpi(cfg.CSDmode,'supra')
   Chans =  e1AreaInfos.SupraGranular; 
elseif strcmpi(cfg.area,'e1') && strcmpi(cfg.CSDmode,'gran')
   Chans  =  e1AreaInfos.Granular; 
elseif strcmpi(cfg.area,'e1') && strcmpi(cfg.CSDmode,'infra')
   Chans =  e1AreaInfos.infraGranular; 
   
elseif strcmpi(cfg.area,'e2') && strcmpi(cfg.CSDmode,'supra')
   Chans =  e2AreaInfos.SupraGranular; 
elseif strcmpi(cfg.area,'e2') && strcmpi(cfg.CSDmode,'gran') 
  Chans  =  e2AreaInfos.Granular;  
elseif strcmpi(cfg.area,'e2') && strcmpi(cfg.CSDmode,'infra')  
   Chans =  e2AreaInfos.infraGranular;
else
    error('CSD mode does not exist!!!')
end

