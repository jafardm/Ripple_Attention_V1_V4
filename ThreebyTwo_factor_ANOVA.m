% Three factor ANOVA analysis
clear
close all hidden

cd \\campus\rdw\ion04\04\thielelab\Users\nat22\texte\publ\in_Preparation\ripples_V1_V4\PNAS\version5\3by2ANOVA\rippledata
load('v4data.mat')

 fig =  figure('Color',[1,1,1],'Units', 'Normalized', 'Position',[0.0, 0.0, 0.9, 0.9]);
    set(fig, 'NumberTitle', 'off', 'Name', 'fig1');
    set(fig, 'PaperUnits', 'centimeters', 'PaperType', 'A4', 'PaperOrientation', 'portrait', 'PaperPosition', [0.63452 0.63452 26.65 20.305]);
    clf;
pooleddata = table2array(Rippletable);



X=zeros(1,5);
jk_ind=[1 1 1;1 1 2;2 1 1; 2 1 2;1 2 1; 1 2 2;2 2 1;2 2 2];
counter=1;
for kl=1:size(pooleddata,1)
    for jk=1:8
        X(counter,1)=pooleddata(kl,jk);
        X(counter,2)=jk_ind(jk,1);
        X(counter,3)=jk_ind(jk,2);
        X(counter,4)=jk_ind(jk,3);
        X(counter,5)=kl;
        counter=counter+1;
        X(counter,1)=pooleddata(kl,jk);
        X(counter,2)=jk_ind(jk,1);
        X(counter,3)=jk_ind(jk,2);
        X(counter,4)=jk_ind(jk,3);
        X(counter,5)=kl;
        counter=counter+1;
    end
end
RMAOV33(X,0.05) 
% Each column of M1Blocks or M1Blocks represents a ripple rate on a condition

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



small_attRF=pooleddata(:,[1 2]);
small_attaway=pooleddata(:,[5 6]);
large_attRF=pooleddata(:,[3 4]);
large_attaway=pooleddata(:,[7 8]);



smallstim=pooleddata(:,[1 2 5 6]);
largestim=pooleddata(:,[3 4 7 8]);

attRF=pooleddata(:,[1 2 3 4]);
attaway=pooleddata(:,[5 6 7 8]);

FocusN=pooleddata(:,[1 3 5 7]);
FocusW=pooleddata(:,[2 4 6 8]);

test=subplot(2,4,1);
for jk=1:4
    loglog(smallstim(:,jk),largestim(:,jk),'ok');
    axis square
    hold on
end
loglog([0.01 0.4],[0.01 0.4],':k');
xlabel('small stimuli [Hz]');
ylabel('large stimuli [Hz]');
title ('effect of stimulus size');
set(test,'XLim',[0.01 0.4],'YLim',[0.01 0.4],'XTick',[0.01 0.1 0.3],'XTickLabel',[0.01 0.1 0.3],'YTick',[0.01 0.1 0.3],'YTickLabel',[0.01 0.1 0.3]);

test=subplot(2,4,2);
for jk=1:4
    loglog(attRF(:,jk),attaway(:,jk),'ok');
    axis square
    hold on
end
loglog([0.01 0.4],[0.01 0.4],':k');
xlabel('attend RF [Hz]');
ylabel('attend away [Hz]');
title ('effect of attention');
set(test,'XLim',[0.01 0.4],'YLim',[0.01 0.4],'XTick',[0.01 0.1 0.3],'XTickLabel',[0.01 0.1 0.3],'YTick',[0.01 0.1 0.3],'YTickLabel',[0.01 0.1 0.3]);

test=subplot(2,4,3);
for jk=1:4
    loglog(FocusN(:,jk),FocusW(:,jk),'ok');
    axis square
    hold on
end
loglog([0.01 0.4],[0.01 0.4],':k');
xlabel('narrow focus [Hz]');
ylabel('wide focus [Hz]');
title ('effect of attentional focus');
set(test,'XLim',[0.01 0.4],'YLim',[0.01 0.4],'XTick',[0.01 0.1 0.3],'XTickLabel',[0.01 0.1 0.3],'YTick',[0.01 0.1 0.3],'YTickLabel',[0.01 0.1 0.3]);



test=subplot(2,4,5);
for jk=1:2
    loglog(small_attRF(:,jk),small_attaway(:,jk),'or');
    hold on
    loglog(large_attRF(:,jk),large_attaway(:,jk),'ob');
    axis square
    hold on
end
loglog([0.01 0.4],[0.01 0.4],':k');
xlabel('attend RF [Hz]');
ylabel('attend away [Hz]');


diff_small=[small_attRF(:,1)' small_attRF(:,2)']-[small_attaway(:,1)' small_attaway(:,2)'];
diff_large=[large_attRF(:,1)' large_attRF(:,2)']- [large_attaway(:,1)' large_attaway(:,2)'];
mdiff1=nanmean(diff_small);
SEMdiff1=nanstd(diff_small)/sqrt(length(diff_small)-1);
mdiff2=nanmean(diff_large);
SEMdiff2=nanstd(diff_large)/sqrt(length(diff_large)-1);

[ps1,h,STATS_W]=signrank([small_attRF(:,1)' small_attRF(:,2)'], [small_attaway(:,1)' small_attaway(:,2)'],'method','approximate');

if ps1>=0.001
    outtext=sprintf('small stimuli diff: %4.3f+/-%4.3f  p=%4.3f',mdiff1,SEMdiff1, ps1);
else
    outtext=sprintf('small stimuli diff: %4.3f+/-%4.3f  p<0.001',mdiff1,SEMdiff1);
end

text('Position',[0.01 0.35],'Fontsize',[8],'String',outtext,'color','r');
[ps2,h,STATS_W]=signrank([large_attRF(:,1)' large_attRF(:,2)'], [large_attaway(:,1)' large_attaway(:,2)'],'method','approximate');
if ps2>=0.001
    outtext=sprintf('large stimuli diff: %4.3f+/-%4.3f  p=%4.3f',mdiff2,SEMdiff2, ps2);
else
    outtext=sprintf('large stimuli diff: %4.3f+/-%4.3f  p<0.001',mdiff2,SEMdiff2);
end
text('Position',[0.01 0.30],'Fontsize',[8],'String',outtext,'color','b');

[ps3,h,STATS_W]=signrank(diff_small, diff_large);

if ps3>=0.001
outtext=sprintf('effect of stimulus on attention difference p=%4.3f',ps3);
else
   outtext=sprintf('effect of stimulus on attention difference <0.001'); 
end
text('Position',[0.01 0.25],'Fontsize',[8],'String',outtext,'color','k');
title ('stimulus* attention interaction');
set(test,'XLim',[0.01 0.4],'YLim',[0.01 0.4],'XTick',[0.01 0.1 0.3],'XTickLabel',[0.01 0.1 0.3],'YTick',[0.01 0.1 0.3],'YTickLabel',[0.01 0.1 0.3]);

%%%%%%% stimulus focus interaction
small_focusN=pooleddata(:,[1 5]);
small_focusW=pooleddata(:,[2 6]);
large_focusN=pooleddata(:,[3 7]);
large_focusW=pooleddata(:,[4 8]);
test=subplot(2,4,6);
for jk=1:2
    loglog(small_focusN(:,jk),small_focusW(:,jk),'or');
    hold on
    loglog(large_focusN(:,jk),large_focusW(:,jk),'ob');
    axis square
    hold on
end
loglog([0.01 0.4],[0.01 0.4],':k');
xlabel('small focus [Hz]');
ylabel('wide focus [Hz]');


diff_small=[small_focusN(:,1)' small_focusN(:,2)']-[small_focusW(:,1)' small_focusW(:,2)'];
diff_large=[large_focusN(:,1)' large_focusN(:,2)']- [large_focusW(:,1)' large_focusW(:,2)'];
mdiff1=nanmean(diff_small);
SEMdiff1=nanstd(diff_small)/sqrt(length(diff_small)-1);
mdiff2=nanmean(diff_large);
SEMdiff2=nanstd(diff_large)/sqrt(length(diff_large)-1);

[ps1,h,STATS_W]=signrank([small_focusN(:,1)' small_focusN(:,2)'], [small_focusW(:,1)' small_focusW(:,2)'],'method','approximate');

if ps1>=0.001
    outtext=sprintf('small stimuli diff: %4.3f+/-%4.3f  p=%4.3f',mdiff1,SEMdiff1, ps1);
else
    outtext=sprintf('small stimuli diff: %4.3f+/-%4.3f  p<0.001',mdiff1,SEMdiff1);
end

text('Position',[0.01 0.35],'Fontsize',[8],'String',outtext,'color','r');
[ps2,h,STATS_W]=signrank([large_focusN(:,1)' large_focusN(:,2)'], [large_focusW(:,1)' large_focusW(:,2)'],'method','approximate');
if ps2>=0.001
    outtext=sprintf('large stimuli diff: %4.3f+/-%4.3f  p=%4.3f',mdiff2,SEMdiff2, ps2);
else
    outtext=sprintf('large stimuli diff: %4.3f+/-%4.3f  p<0.001',mdiff2,SEMdiff2);
end
text('Position',[0.01 0.30],'Fontsize',[8],'String',outtext,'color','b');

[ps3,h,STATS_W]=signrank(diff_small, diff_large);

if ps3>=0.001
outtext=sprintf('effect of stimulus on focus difference p=%4.3f',ps3);
else
   outtext=sprintf('effect of stimulus on focus difference <0.001'); 
end
text('Position',[0.01 0.25],'Fontsize',[8],'String',outtext,'color','k');
title ('stimulus* focus interaction');
set(test,'XLim',[0.01 0.4],'YLim',[0.01 0.4],'XTick',[0.01 0.1 0.3],'XTickLabel',[0.01 0.1 0.3],'YTick',[0.01 0.1 0.3],'YTickLabel',[0.01 0.1 0.3]);

%%%%%%%%%%%%%%%
%%% attention focus interaction
attRF_focusN=pooleddata(:,[1 3]);
attRF_focusW=pooleddata(:,[2 4]);
attaway_focusN=pooleddata(:,[5 7]);
attaway_focusW=pooleddata(:,[6 8]);

test=subplot(2,4,7);
for jk=1:2
    loglog(attRF_focusN(:,jk),attRF_focusW(:,jk),'or');
    hold on
    loglog(attaway_focusN(:,jk),attaway_focusW(:,jk),'ob');
    axis square
    hold on
end
loglog([0.01 0.4],[0.01 0.4],':k');
xlabel('small focus [Hz]');
ylabel('wide focus [Hz]');


diff_small=[attRF_focusN(:,1)' attRF_focusN(:,2)']-[attRF_focusW(:,1)' attRF_focusW(:,2)'];
diff_large=[attaway_focusN(:,1)' attaway_focusN(:,2)']- [attaway_focusW(:,1)' attaway_focusW(:,2)'];
mdiff1=nanmean(diff_small);
SEMdiff1=nanstd(diff_small)/sqrt(length(diff_small)-1);
mdiff2=nanmean(diff_large);
SEMdiff2=nanstd(diff_large)/sqrt(length(diff_large)-1);

[ps1,h,STATS_W]=signrank([attRF_focusN(:,1)' attRF_focusN(:,2)'], [attRF_focusW(:,1)' attRF_focusW(:,2)'],'method','approximate');

if ps1>=0.001
    outtext=sprintf('attRF diff: %4.3f+/-%4.3f  p=%4.3f',mdiff1,SEMdiff1, ps1);
else
    outtext=sprintf('attRF diff: %4.3f+/-%4.3f  p<0.001',mdiff1,SEMdiff1);
end

text('Position',[0.01 0.35],'Fontsize',[8],'String',outtext,'color','r');
[ps2,h,STATS_W]=signrank([attaway_focusN(:,1)' attaway_focusN(:,2)'], [attaway_focusW(:,1)' attaway_focusW(:,2)'],'method','approximate');
if ps2>=0.001
    outtext=sprintf('att away diff: %4.3f+/-%4.3f  p=%4.3f',mdiff2,SEMdiff2, ps2);
else
    outtext=sprintf('att away diff: %4.3f+/-%4.3f  p<0.001',mdiff2,SEMdiff2);
end
text('Position',[0.01 0.30],'Fontsize',[8],'String',outtext,'color','b');

[ps3,h,STATS_W]=signrank(diff_small, diff_large);

if ps3>=0.001
outtext=sprintf('effect of attention on focus difference p=%4.3f',ps3);
else
   outtext=sprintf('effect of attention on focus difference <0.001'); 
end
text('Position',[0.01 0.25],'Fontsize',[8],'String',outtext,'color','k');
title ('attention* focus interaction');
set(test,'XLim',[0.01 0.4],'YLim',[0.01 0.4],'XTick',[0.01 0.1 0.3],'XTickLabel',[0.01 0.1 0.3],'YTick',[0.01 0.1 0.3],'YTickLabel',[0.01 0.1 0.3]);

%%%%%%%%%%%%%%%
