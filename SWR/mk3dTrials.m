function Trials = mk3dTrials(Trials,Times,rippls)

for ii = 1:size(rippls,1)
    if ~isempty(rippls{ii,1})
        chRippls = rippls{ii,1};
        for jj =1:size(chRippls,1)
            [~,idx1] = min(abs(Times-chRippls(jj,1)));
            [~,idx2] = min(abs(Times-chRippls(jj,3)));
            Trials(chRippls(jj,end),idx1:idx2,ii) = 1;
        end
    end
end