function [N1,N2]= get_ripple_block(cfg,Cond,TrialNumber)


if strcmpi(cfg.trialcodelabel,'Att') && cfg.CorrectOnlyFlag 
        N1 = numel(find(ismember(TrialNumber,Cond.IDxin)));
        N2 = numel(find(ismember(TrialNumber,Cond.IDxout)));
    
elseif  strcmpi(cfg.trialcodelabel,'foc')&& cfg.CorrectOnlyFlag 
    
        N1 = numel(find(ismember(TrialNumber,Cond.Narrow)));
        N2 = numel(find(ismember(TrialNumber,Cond.Wide)));
        
elseif  strcmpi(cfg.trialcodelabel,'stim')&& cfg.CorrectOnlyFlag 
    
        N1 = numel(find(ismember(TrialNumber,Cond.Large)));
        N2 = numel(find(ismember(TrialNumber,Cond.Small)));
        
elseif  strcmpi(cfg.TrialOption,'intt') && ~ cfg.CorrectOnlyFlag && strcmpi(cfg.trialcodelabel,'Att')
    
       N1 = numel(find(ismember(TrialNumber,Cond.IDxin)));
       N2 = numel(find(ismember(TrialNumber,Cond.IDxout)));
       
elseif strcmpi(cfg.TrialOption,'intt') && ~ cfg.CorrectOnlyFlag && strcmpi(cfg.trialcodelabel,'Foc')
    
        N1 = numel(find(ismember(TrialNumber,Cond.Narrow)));
        N2 = numel(find(ismember(TrialNumber,Cond.Wide)));
        
elseif  strcmpi(cfg.TrialOption,'intt') && ~ cfg.CorrectOnlyFlag && strcmpi(cfg.trialcodelabel,'stim') 
    
        N1 = numel(find(ismember(TrialNumber,Cond.Large)));
        N2 = numel(find(ismember(TrialNumber,Cond.Small)));
else
    error('Block does not exist!!!')
end