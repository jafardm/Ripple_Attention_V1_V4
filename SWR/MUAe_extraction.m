
function [muasampls,Times]=  MUAe_extraction(cfg,channel)

switch cfg.area
    case 'e1'
        muaname = [cfg.CTXFilename '.MUA.AD' num2str(channel-1)];
    case 'e2'
        muaname = [cfg.CTXFilename '.MUA.AD' num2str(channel+15)];
end
%
Filename = [sprintf(muaname,channel) '.ncs'];
NCSpath = fullfile(cfg.Muae,Filename);
NCS      = NLX_LoadNCS(NCSpath,cfg.FieldOption,cfg.ExtractMode,[]);
NC       = NLX_convertNCS(NCS);

[NCS,muasampls,Times] = NLX_ExtractNCS(NC,cfg.nevTime,1);

