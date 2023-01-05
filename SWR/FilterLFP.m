function Filt_sig = FilterLFP(cfg,lfp)
% function Filt_sig = FilterLFP(cfg,lfp)
%
% INPUT:

% configuration parameters
% cfg.type = 'fdesign'; filter type: 'low', 'high' ...
% cfg.order = 4; filter order
% cfg.display_filter = 0; plot filter shape
% cfg.R = 0.5; % passband ripple (in dB) for Chebyshev filters only
% cfg.frange = [5 250];
% cfg.fs sampling frequency;

%  LFP data

% OUTPUT:
% Filt_sig with filtered LFP data




% construct the filter
Wn = cfg.frange ./ (cfg.fs/2); % convert to units of half sample rate
switch lower(cfg.type)
   
    case 'butter'
        
        %[z,p,k] = butter(cfg.order,Wn);
        [b,a] = butter(cfg.order,Wn);
        
    case 'cheby1'
        
        %[z,p,k] = cheby1(cfg.order,cfg.R,Wn);
        [b,a] = cheby1(cfg.order,cfg.R,Wn);
        
    case 'low' 
        
        [b,a] = butter(cfg.order,Wn,'low' );
        
         case 'high' 
        
        [b,a] = butter(cfg.order,Wn,'high' );
    
    case 'fdesign'
        
        d = fdesign.bandpass('N,F3dB1,F3dB2',cfg.order,cfg.frange(1),cfg.frange(2),cfg.fs);
        Hd = design(d,'butter');
        b = Hd.sosMatrix; a = Hd.scaleValues;
end



% display if requested
if cfg.display_filter
    
    %fvtool(h);
    if exist('Hd','var')
        fvtool(Hd);
    else
        fvtool(b,a);
    end
    fprintf('FilterLFP.m: paused, press key to continue...\n');
    pause;
end


    %Filt_sig = filtfilt
    Filt_sig = filtfilt(b,a,lfp);
    
   
end

