function [xspikes, yspikes] = computeRaster(spike_times, y)
% computes a raster from spike times
% 
% INPUT:
% spike_times: vector with times at which spike occured
% y: y-position, where to plot this trials' spikes (e.g. trial/channel index)
% 
% OUTPUT:
% xspikes, yspikes: x and y values of the spikes
%
% plot(xspikes, yspikes) plots the raster for the current trial
%
% 
 


% convert to row vector
spike_times = spike_times(:)';

xspikes = repmat(spike_times,2,1);
yspikes = nan(size(xspikes));
if ~isempty(yspikes)
   % yspikes(1,:) = y-1;
    yspikes(1,:) = y;
end