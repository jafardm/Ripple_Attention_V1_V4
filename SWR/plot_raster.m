
function plot_raster(raster,time,color,LW)
num_trial = size(raster,1);
for j=1:num_trial
    tj = reshape(time(raster(j,:) == 1),[],1);
    id = 1:3:3*length(tj);
    X = sort([tj;tj;tj]);
    Y = nan(length(X),1);
    Y(id) = j-1;
    Y(id+1) = j-.1;
    if size(color,1) == 1
        plot(X,Y+.4,'Color',color,'LineWidth',LW);
    else
        plot(X,Y+.4,'Color',color(j,:),'LineWidth',LW);
    end
    hold on
end
ylim([0 size(raster,1)])
end