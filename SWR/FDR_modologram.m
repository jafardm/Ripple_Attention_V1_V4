function FDR_modologram(total_modulgram,frex,alpha)
aveCorr         = nanmean(total_modulgram,3);

pval  = zeros(size(total_modulgram,1),size(total_modulgram,1));

for m = 1:size(total_modulgram,1)
    for n = 1:size(total_modulgram,2)
        [~,pval(m,n)] = ttest(squeeze(total_modulgram(m,n,:)));
    end
end


[h, crit_p, adj_ci_cvrg, adj_p] = fdr_bh(pval,alpha,'pdep','yes');

%%
fig = figure('Units','normalized','Position',[0 0 0.3 1]);

subplot(311)
surf(frex,frex,aveCorr,'EdgeColor','none'), colormap('jet'), colorbar; view(0,90); axis tight;
set(gca,'fontsize',8,'Fontname','Arial','TickDir', 'out'),box off, axis square
subplot(312)
contourf(frex,frex,log10(1./pval),40,'linecolor','none'),axis square,colormap('jet'),colorbar
subplot(313)
contourf(frex,frex,h,40,'linecolor','none'),colormap('jet'), colorbar
set(gca,'fontsize',8,'Fontname','Arial','TickDir', 'out'),box off,axis square