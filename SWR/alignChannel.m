function alignedChannels = alignChannel(cfg,contactPositions,Latidx)
 
% contactPositions in milimeter.
% latidx: electrode number(1:16) for alignment
NumOfChs = cfg.nOfchannel;
referenceChan = contactPositions - contactPositions(Latidx);
 

switch cfg.area
    
    case 'e1'
        
       alignedChannels.PenNumber      = [cfg.area(1:2) cfg.Name];
       alignedChannels.TooSuperficial = NumOfChs(referenceChan < -1);
       alignedChannels.SupraGranular  = NumOfChs(referenceChan >= -1    & referenceChan <= -0.25); 
       alignedChannels.Granular       = NumOfChs(referenceChan >= -0.25 & referenceChan <= 0.25); 
       alignedChannels.infraGranular  = NumOfChs(referenceChan >= 0.25  & referenceChan <= 0.75);
       alignedChannels.TooDeep        = NumOfChs(referenceChan > 0.75);
       
    case 'e2'
       alignedChannels.PenNumber      = [cfg.area(1:2) cfg.Name];
       alignedChannels.TooSuperficial = NumOfChs(referenceChan < -1);
       alignedChannels.SupraGranular  = NumOfChs(referenceChan >= -1   & referenceChan <= -0.1); 
       alignedChannels.Granular       = NumOfChs(referenceChan >= -0.1 & referenceChan <= 0.1); 
       alignedChannels.infraGranular  = NumOfChs(referenceChan >= 0.1  & referenceChan <= 1);
       alignedChannels.TooDeep        = NumOfChs(referenceChan > 1);
end