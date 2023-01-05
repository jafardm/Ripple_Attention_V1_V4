function [ripples,dfilt] = ripple_detction (cfg,Samples,Times)


% set FIR filter
srate         = cfg.Fs;
nyquist       = srate/2;
frange        = cfg.frange;
transw        = 0.1;
filter_order  = round(cfg.filterOrder*srate/frange(1));
shape         = [0 0 1 1 0 0];
frex          = [0 frange(1)-frange(1)*transw frange frange(2)+frange(2)*transw nyquist]/nyquist;
filterweights = firls(filter_order,frex,shape);

dfilt           =  filtfilt(filterweights,1,Samples);
ripples         = FindRipples([Times dfilt],'frequency',srate); % FindRipples function from FMA toolbox

end




