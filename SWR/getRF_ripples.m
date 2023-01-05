function sessions = getRF_ripples(ripple,channels)
% 

% X = cell(size(ripple));
% 
% for jj = 1:length(channels)
%     if ~isempty(ripple{channels(jj)})
%         temp = ripple{channels(jj)};
%         N = size(temp,1);
%         
%         tempripple = size(temp(all(temp,2),:),1);
% 
%         X{jj} = tempripple/(N*0.45);
%        
%    end
% end
% ripplerate = cell2mat(X);

duration = 0.45;
sessions = zeros(length(channels),6);

for jj = 1:length(channels)
    if ~isempty(ripple{channels(jj)})
        temp = ripple{channels(jj)};

        labels = temp(:,6:end);
        nconRF   = sum(labels(:,1)==1);
        nconaway = sum(labels(:,1)==2);
        nconNar  = sum(labels(:,2)==1);
        nconWd   = sum(labels(:,2)==2);
        nlarge  = sum(labels(:,3)==1);
        nsmall   = sum(labels(:,3)==2);

        rpls = temp(all(temp,2),:);
        RF = sum(rpls(:,6)==1);
        away = sum(rpls(:,6)==2);

        N = sum(rpls(:,7)==1);
        W = sum(rpls(:,7)==2);
        
        large = sum(rpls(:,8)==1);
        small = sum(rpls(:,8)==2);

        sessions(jj,1) = RF/(nconRF*duration);
        sessions(jj,2) = away/(nconaway*duration);
        sessions(jj,3) = N/(nconNar*duration);
        sessions(jj,4) = W/(nconWd*duration);
        sessions(jj,5) = large/(nlarge*duration);
        sessions(jj,6) = small/(nsmall*duration);
   end
end

