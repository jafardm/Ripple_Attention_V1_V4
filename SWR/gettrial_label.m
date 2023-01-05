function Labels = gettrial_label(cfg)

SPK = makeSPK_create(cfg);
 
TrialCodeLabel = SPK.trialcodelabel;
trialcode      = SPK.trialcode;

switch cfg.subjectName
    
    case  'monkey2'
        
        % 38:currAtt, 40:currFoc, 39:currStim
        attentionIDX = trialcode(ismember(TrialCodeLabel,'currAtt'),:);
        FocIDX       = trialcode(ismember(TrialCodeLabel,'currFoc'),:);
        SizeIDX      = trialcode(ismember(TrialCodeLabel,'currStim'),:);
        Labels = [attentionIDX' FocIDX' SizeIDX'];
        
    case   'monkey1'
        
        % 41:iAtt, 43:iFoc, 42:iSize
        attentionIDX = trialcode(ismember(TrialCodeLabel,'iAtt'),:);
        FocIDX       = trialcode(ismember(TrialCodeLabel,'iFoc'),:);
        SizeIDX      = trialcode(ismember(TrialCodeLabel,'iStim'),:);
        stnSize = unique(SizeIDX);
        
        SizeIDX(SizeIDX == min(stnSize)) = 1; 
        SizeIDX(SizeIDX == max(stnSize)) = 2; 
        Labels = [attentionIDX' FocIDX' SizeIDX'];
end