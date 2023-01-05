function ViolinplotAttention(y,attcond)

switch attcond
    case 'att'
     
          conditions = {'Pre RF'; 'Pre Away';
                      'Post RF';'Post Away';
                      'Sustain RF'; 'Sustain Away'};
        
        y1 = nan(size(y));
        y2 = nan(size(y));
        y1(:,1:2:end) = y(:,1:2:end);
        y2(:,2:2:end) = y(:,2:2:end);
        
        figure 
        hold on
        violinplot(y1, conditions, 'ViolinColor',[1,0,0]);
        
        violinplot(y2, conditions, 'ViolinColor',[0,0,1]);
        
        h = gca;
        set(h,'fontsize',8,'xticklabels',conditions,'FontName','Arial'),xtickangle(45)
        set(gca, 'TickDir', 'out'),box off
        ylabel('Ripple rate(events/sec)')
        

    case 'Foc'
          
             
        conditions = {'Pre N'; 'Pre W';
                      'Post N';'Post W';
                      'Sustain N'; 'Sustain W'};
        
        y1 = nan(size(y));
        y2 = nan(size(y));
        y1(:,1:2:end) = y(:,1:2:end);
        y2(:,2:2:end) = y(:,2:2:end);
        
        figure 
        hold on
        violinplot(y1, conditions, 'ViolinColor',[0.4660 0.6740 0.1880]);
        
        violinplot(y2, conditions, 'ViolinColor',[0.9290 0.6940 0.1250]);
        h = gca;
        set(h,'fontsize',8,'xticklabels',conditions,'FontName','Arial'),xtickangle(45)
        set(gca, 'TickDir', 'out'),box off
        ylabel('Ripple rate(events/sec)')


    case 'size'
        colors     = [0.2706 0.5020 0;0.4235 0 0.5020];         
        conditions = {'Large'; 'Small'};
        
        Large = y(:,1);
        Large(all(Large,2),:);

        Small =y(:,2);
        Small(all(Small,2),:)

        y = [Large Small];
        y1 = nan(size(y));
        y2 = nan(size(y));
        
        y1(:,1) = y(:,1);
        y2(:,2) = y(:,2);
        figure
        violinplot(y1, conditions,'ViolinColor',colors(1,:));
        hold on
        violinplot(y2, conditions,'ViolinColor',colors(2,:));

        h = gca;
        set(h,'fontsize',8,'xticklabels',conditions,'FontName','Arial')
        set(gca, 'TickDir', 'out'),box off
        ylabel('Ripple rate(ripple/sec)')
end