function M1Blocks = ripplerateStats(M1ripples,duration)

M1Blocks = nan(size(M1ripples,2),6);

for ii = 1:size(M1ripples,2)
    sessions = nan(size(M1ripples,1),6);
    for jj = 1:size(M1ripples,1)

        if ~isempty(M1ripples{jj,ii})
            e1ripple = M1ripples{jj,ii};
            labels = e1ripple(:,6:end);
            nconRF   = sum(labels(:,1)==1);
            nconaway = sum(labels(:,1)==2);
            nconNar  = sum(labels(:,2)==1);
            nconWd   = sum(labels(:,2)==2);
            nlarge  = sum(labels(:,3)==1);
            nsmall   = sum(labels(:,3)==2);

            temp = e1ripple(all(e1ripple,2),:);

            RF = sum(temp(:,6)==1);
            away = sum(temp(:,6)==2);

            N = sum(temp(:,7)==1);
            W = sum(temp(:,7)==2);
            
            large = sum(temp(:,8)==1);
            small = sum(temp(:,8)==2);

            sessions(jj,1) = RF/(nconRF*duration);
            sessions(jj,2) = away/(nconaway*duration);
            sessions(jj,3) = N/(nconNar*duration);
            sessions(jj,4) = W/(nconWd*duration);
            sessions(jj,5) = large/(nlarge*duration);
            sessions(jj,6) = small/(nsmall*duration);

        end
    end
    M1Blocks(ii,:) = nanmean(sessions);
end