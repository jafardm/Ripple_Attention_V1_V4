function Flag = check_peneteration(cfg)

% Caesar's penetrations

if strcmp(cfg.Name,'pen027') && strcmp(cfg.area ,'e1')
    Flag = true;
    elseif strcmp(cfg.Name,'pen038') && strcmp(cfg.area ,'e1')
    Flag = true;

    % Richard's penetrations
elseif strcmp(cfg.Name,'pen129') && strcmp(cfg.area ,'e1')
    Flag = true;
elseif strcmp(cfg.Name,'pen143') && strcmp(cfg.area ,'e1')
    Flag = true;
elseif strcmp(cfg.Name,'pen144') && strcmp(cfg.area ,'e1')
    Flag = true;
elseif strcmp(cfg.Name,'pen160') && strcmp(cfg.area ,'e1')
    Flag = true;
elseif strcmp(cfg.Name,'pen162') && strcmp(cfg.area ,'e1')
    Flag = true;
elseif strcmp(cfg.Name,'pen164') && strcmp(cfg.area ,'e1')
    Flag = true;
elseif strcmp(cfg.Name,'pen142') && strcmp(cfg.area ,'e2')
    Flag = true;
elseif strcmp(cfg.Name,'pen143') && strcmp(cfg.area ,'e2')
    Flag = true;
elseif strcmp(cfg.Name,'pen144') && strcmp(cfg.area ,'e2')
    Flag = true;
elseif strcmp(cfg.Name,'pen163') && strcmp(cfg.area ,'e2')
    Flag = true;
    
else
    Flag = false;
end