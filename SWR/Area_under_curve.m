function [AUC,p] = Area_under_curve(t,XC)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


XC(:,all(XC==0,1)) = [];
XC(:,all(isnan(XC),1)) = [];

Num = size(XC,1);
midpoint = find(t==0);
AUC = zeros(Num,2);

for n = 1:Num
    temp = XC(:,n);
    AUC(n,1) = compute_AUC(t(1:midpoint),temp(1:midpoint));
    AUC(n,2) = compute_AUC(t(midpoint:end),temp(midpoint:end));
end

x = [-1 1];
figure
for ii = 1:Num
   plot([x(1) x(2)],[AUC(ii,1) AUC(ii,2)],'color',[0.6 0.6 0.6],'LineW',3), hold on
end

m =  max(AUC(:));
line([x(1) x(2)],mean(AUC,1),'color',[0 0 0],'LineW',5)
line([x(1) x(2)],[m+0.2*m  m+0.2*m],'color',[0 0 0],'LineW',2)

xlim([x(1)- 0.5 x(2) + 0.5]), ylim([min(AUC(:))-0.01 m+0.5*m])
set(gca,'XTick',[-1 1]);ax = gca; set(ax,'XTickLabel',{'t < 0','t > 0'},'fontsize',16,'FontWeight','bold')
set(ax,'YTick',[0 ax.YLim(2)/2 ax.YLim(2)]);set(ax,'YTickLabel',[]),ylabel('AUC','fontsize',16,'FontWeight','bold'),ax.LineWidth = 1.5;
hold off, set(gca,'box','off')

p = signrank(AUC(:,1),AUC(:,2));

end


function S = compute_AUC(x,y)
S = 0;
for n = 1:length(x)-1
    
        S = S + (y(n) + y(n+1))*(x(n+1)-x(n))/2;
end

end

