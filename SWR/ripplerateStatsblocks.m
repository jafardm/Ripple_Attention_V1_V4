  
function M1Blocks = ripplerateStatsblocks(M1ripples,duration)

% [narrow-RF Narrow-away wide-RF wide-away]

M1Blocks = zeros(size(M1ripples,2),4);

for ii = 1:size(M1ripples,2)
     session = zeros(size(M1ripples,1),4);
    for jj = 1:size(M1ripples,1)
        if ~isempty(M1ripples{jj,ii})
            e1ripple = M1ripples{jj,ii};
            labels = e1ripple(:,6:end);
          
            NRF   = sum(labels(:,1) == 1 & labels(:,2)== 1); % narrow RF
            Naway = sum(labels(:,1) == 2 & labels(:,2)== 1); % Narrow away
            
            wideRF  = sum(labels(:,1) == 1 & labels(:,2)== 2); % wide RF
            wideAW  = sum(labels(:,1) == 2 & labels(:,2)== 2); % wide away
       

            temp = e1ripple(all(e1ripple,2),:);

            if isempty(temp), continue, end

            nblocks1 = sum(all(temp(:,[6 7])==[1 1],2));
            nblocks2 = sum(all(temp(:,[6 7])==[2 1],2));
            nblocks3 = sum(all(temp(:,[6 7])==[1 2],2));
            nblocks4 = sum(all(temp(:,[6 7])==[2 2],2));

            session(jj,1) = nblocks1/(NRF*duration);
            session(jj,2) = nblocks2/(Naway*duration);
            session(jj,3) = nblocks3/(wideRF*duration);
            session(jj,4) = nblocks4/(wideAW*duration);
        end
    end
  M1Blocks(ii,:) = mean(session);
end

