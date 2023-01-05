function ripplelabels = getripplelabels(cfg,ripples)

ripplelabels = cell(14,length(cfg.pen));

for peni = 1:length(cfg.pen)
    
    cfg.Name = cfg.pen(peni).Name;
    Flag = check_peneteration(cfg);
    if Flag, continue; end

     % load labels
     load(fullfile(cfg.labelpath,num2str(cfg.pen(peni).Name)))

    LfpName1 = [cfg.area num2str(cfg.pen(peni).Name)];
    load(fullfile(cfg.dataPath,LfpName1))

    for ii = 1:size(ripples,1)
        % go over channels
        chanrpls = ripples{ii,1};
        if isempty(chanrpls), continue, end
        % take trial with ripples and thier labels
        TrialWripple = chanrpls(:,end);
        rippleLabels = labels(TrialWripple,:);

        Trialid_witout_ripple = nan(length(TrialWripple),1);

        for jj = 1:size(rippleLabels,1)
           samecoditions = find(all(rippleLabels(jj,:)==labels,2));
           temp = samecoditions(~ismember(samecoditions,TrialWripple(jj)));
           trialWithoutriple = temp(randi(length(temp),1));
           Trialid_witout_ripple(jj) = trialWithoutriple;
        end   
        ripplelabels{ii,peni} = [TrialWripple Trialid_witout_ripple ];
    end
end  