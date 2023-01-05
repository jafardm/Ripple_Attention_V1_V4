function [NCS,Samples,Times,fs]= ExtractSamples(NCSpath,NLXTime)

NCSParam.FieldOption='Full';
NCSParam.ExtractMode = 1;
[NCS] = NLX_LoadNCS(NCSpath,NCSParam.FieldOption,NCSParam.ExtractMode,[]);
[NCS,Samples,Times] = NLX_ExtractNCS(NCS,NLXTime,1);
Times=Times*10^-6;  % convert time to sec
fs=NCS.SF(1);

