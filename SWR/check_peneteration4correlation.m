function Flag = check_peneteration4correlation(cfg)

% Caesar's penetrations

if strcmp(cfg.Name,'pen027')
    Flag = true;

    % Richard's penetrations
elseif strcmp(cfg.Name,'pen129')
    Flag = true;
elseif strcmp(cfg.Name,'pen142')
    Flag = true;
elseif strcmp(cfg.Name,'pen143')
    Flag = true;  
elseif strcmp(cfg.Name,'pen144')
    Flag = true;
elseif strcmp(cfg.Name,'pen160')
    Flag = true;
elseif strcmp(cfg.Name,'pen162')
    Flag = true;    
elseif strcmp(cfg.Name,'pen163')
    Flag = true;
elseif strcmp(cfg.Name,'pen164')
    Flag = true;
        
else
    Flag = false;
end