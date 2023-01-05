function y = Butter_filter(s,fRange,fs,n)

    ftype='bandpass';
    
    cutoff = fRange./(fs/2);
    
    [b,a] = butter(n,cutoff,ftype);
    
     y=cell(size(s));
    
    for Chi=1:length(s)
       
        for iT=1:size(s{Chi},1)
            Tri=s{1,Chi}(iT,:);
            Tri(isnan(Tri))=0;
            y{Chi}(iT,:) = filtfilt(b,a,Tri);
        end
    end

end