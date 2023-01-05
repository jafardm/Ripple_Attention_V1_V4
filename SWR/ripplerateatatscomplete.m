function M1Blocks = ripplerateatatscomplete(M1ripples,duration)

% Small stim, attend RF, narrow focus
% Small stim attend RF, wide focus
% Large stim, attend RF, narrow focus
% Large stim attend RF, wide focus
% 
% 
% Small stim, attend away, narrow focus
% Small stim attend away, wide focus
% Large stim, attend away, narrow focus
% Large stim attend away, wide focus


M1Blocks = zeros(size(M1ripples,2),8);

for ii = 1:size(M1ripples,2)
     session = nan(size(M1ripples,1),8);
    for jj = 1:size(M1ripples,1)
        if ~isempty(M1ripples{jj,ii})
            e1ripple = M1ripples{jj,ii};
            labels = e1ripple(:,6:end);
          
            SRFN = sum(labels(:,3) == 2 & labels(:,1)== 1 & labels(:,2)== 1); % small-RF-narrow
            SRFW = sum(labels(:,3) == 2 & labels(:,1)== 1 & labels(:,2)== 2); % small-RF-wide
            LRFN = sum(labels(:,3) == 1 & labels(:,1)== 1 & labels(:,2)== 1); % large-RF-narrow
            LRFW = sum(labels(:,3) == 1 & labels(:,1)== 1 & labels(:,2)== 2); % large-RF-wide

            SawN = sum(labels(:,3) == 2 & labels(:,1)== 2 & labels(:,2)== 1); % small-away-narrow
            SawW = sum(labels(:,3) == 2 & labels(:,1)== 2 & labels(:,2)== 2); % small-away-wide
            LawN = sum(labels(:,3) == 1 & labels(:,1)== 2 & labels(:,2)== 1); % large-away-narrow
            LawW = sum(labels(:,3) == 1 & labels(:,1)== 2 & labels(:,2)== 2); % large-away-wide

            temp = e1ripple(all(e1ripple,2),:);

            if isempty(temp), continue, end

            nblocks1 = sum(all(temp(:,[8 6 7])==[2 1 1],2));
            nblocks2 = sum(all(temp(:,[8 6 7])==[2 1 2],2));
            nblocks3 = sum(all(temp(:,[8 6 7])==[1 1 1],2));
            nblocks4 = sum(all(temp(:,[8 6 7])==[1 1 2],2));
            nblocks5 = sum(all(temp(:,[8 6 7])==[2 2 1],2));
            nblocks6 = sum(all(temp(:,[8 6 7])==[2 2 2],2));
            nblocks7 = sum(all(temp(:,[8 6 7])==[1 2 1],2));
            nblocks8 = sum(all(temp(:,[8 6 7])==[1 2 2],2));

            session(jj,1) = nblocks1/(SRFN*duration);
            session(jj,2) = nblocks2/(SRFW*duration);
            session(jj,3) = nblocks3/(LRFN*duration);
            session(jj,4) = nblocks4/(LRFW*duration);
            session(jj,5) = nblocks5/(SawN*duration);
            session(jj,6) = nblocks6/(SawW*duration);
            session(jj,7) = nblocks7/(LawN*duration);
            session(jj,8) = nblocks8/(LawW*duration);
        end
    end
    
  M1Blocks(ii,:) = nanmean(session,1);
end