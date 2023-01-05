function plot_ripple_spectrogram(cfg,LFPs,TimeVec,dfilt,TrialTimes,AllRipples)


    epochsTime  = [TrialTimes(1:end-1,2) TrialTimes(2:end,1)];
   
    ripples     = CheckEpoch(AllRipples,epochsTime); 
    X           = ripples; 
    RplsTimes   = X(all(X,2),:);
    nBins       = round(cfg.win*cfg.Fs);
    t           = -cfg.win:1/cfg.Fs:cfg.win;
    
    ripplesLFPs = zeros(2*nBins+1,size(RplsTimes,1)); 
    filtered    = zeros(2*nBins+1,size(RplsTimes,1)); 
    
    for jj = 1:size(RplsTimes,1)
             [~,idx]            = min(abs(TimeVec - RplsTimes(jj,2)));
             ripplesLFPs(:,jj)  = LFPs(idx - nBins:idx + nBins);
             filtered(:,jj)     = dfilt(idx - nBins:idx + nBins);
    end
          
   MaxRipple_time = RplsTimes(:,2);


    for ii = 1:length(MaxRipple_time)
         cfg.tEDF                 = MaxRipple_time(ii) - cfg.win:1/cfg.Fs:MaxRipple_time(ii) + cfg.win;
        [Spect_t,freq,zSpec]      = hannspecgramc(cfg,ripplesLFPs(:,ii));
         plot_spectrogram(t,ripplesLFPs(:,ii),filtered(:,ii),Spect_t,freq,zSpec)    
    end
    
 
end


function plot_spectrogram(t,Raw,dfilt,Spect_t,freq,zSpec)
figure;

subplot(1,3,1)
plot(t,Raw,'lineWidth',2), xlabel('Times(sec)'), ylabel('Amplitude(\mu V)')
set(gca,'xlim',[-0.2 0.2],'fontsize',12,'FontWeight','bold'), axis square, title('Wide-Band signal')

%     subplot(1,4,2)
%     plot(t,Low{1,n},'lineWidth',2), xlabel('Times(sec)'), ylabel('Amplitude(\mu V)')
%     set(gca,'xlim',[-0.2 0.2]), axis square,  title('Low-Pass signal')

subplot(1,3,2)
plot(t,dfilt,'lineWidth',2), %hold on, plot(t,abs(hilbert(filtered{1,n})),'r', 'lineWidth',1.5), hold off,...
    xlabel('Times(sec)'), ylabel('Amplitude(\mu V)'), axis square, title('Filtered 80-200')
    set(gca,'xlim',[-0.2 0.2],'fontsize',12,'FontWeight','bold')

subplot(1,3,3)
colormap(jet)
imagesc(Spect_t,freq,transpose(zSpec)), colorbar, 
xlabel('Times(sec)'), ylabel('Frequency(Hz)'),set(gca,'XTick',[-0.1 -0.05 0 0.05 0.1],'fontsize',12,'FontWeight','bold'),
title('Spectrogram')
axis xy;
axis square;   
end

function pure_ripples = CheckEpoch(ripplesTimes,epochsTime)
    
    [~,cols]  = size(ripplesTimes);
    
    pure_ripples = zeros(size(epochsTime,1),cols+1);
   for k = 1:size(ripplesTimes,1)

        for iTrial = 1:size(epochsTime,1)

            if (ripplesTimes(k,2) >= epochsTime(iTrial,1) && ripplesTimes(k,2) < epochsTime(iTrial,2)) 
                pure_ripples(iTrial,1:4) =  ripplesTimes(k,:);
                pure_ripples(iTrial,5)   = iTrial;
            end
        end
    end
end