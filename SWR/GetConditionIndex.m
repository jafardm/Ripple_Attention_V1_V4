function [CndIdx,allTskCnd] = GetConditionIndex(trialcode,TrialCodeLabel,subjectName)



switch subjectName
    
    case  'Richard'
        
     % 38:currAtt, 40:currFoc, 39:currStim 
    attentionIDX = find(ismember(TrialCodeLabel,'currAtt'));
    FocIDX       = find(ismember(TrialCodeLabel,'currFoc'));
    SizeIDX      = find(ismember(TrialCodeLabel,'currStim'));  
    
    IDXin =  find(trialcode(attentionIDX,:) == 1);
    CndIdx.IDxin = IDXin;
    
    IDXout = find(trialcode(attentionIDX,:)== 2);
    CndIdx.IDxout = IDXout;
    
    uniTskCnd = unique( trialcode(SizeIDX,:)' ,'rows');
    
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
     
     IDXin =  find(trialcode(attentionIDX,:) == 1);
     CndIdx.IDxin = IDXin;
    
     IDXout = find(trialcode(attentionIDX,:)== 2);
     CndIdx.IDxout = IDXout;
     
     uniTskCnd = unique( trialcode(SizeIDX,:)' ,'rows');
     
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


TS{1,1}  = 'All Trials';
TS{2,1}  = 'IDxin';  
TS{3,1}  = 'IDxout'; 
TS{4,1}  = 'IDInNLa'; 
TS{5,1}  = 'IDInNSm'; 
TS{6,1}  = 'IDInWLa'; 
TS{7,1}  = 'IDInWSm';
TS{8,1}  = 'IDOutNLa';
TS{9,1}  = 'IDOutNSm'; 
TS{10,1} = 'IDOutWLa'; 
TS{11,1} = 'IDOutWSm';
%

TS{1,2}  = sum(length(IDXin) + length(IDXout));
TS{2,2}  = length(IDXin); 
TS{3,2}  = length(IDXout);
TS{4,2}  = length(CndIdx.IDInNLa);  
TS{5,2}  = length(CndIdx.IDInNSm); 
TS{6,2}  = length(CndIdx.IDInWLa);   
TS{7,2}  = length(CndIdx.IDInWSm); 
TS{8,2}  = length(CndIdx.IDOutNLa); 
TS{9,2}  = length(CndIdx.IDOutNSm); 
TS{10,2} = length(CndIdx.IDOutWLa); 
TS{11,2} = length(CndIdx.IDOutWSm);

CndIdx.TS = TS;