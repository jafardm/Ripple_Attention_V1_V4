function [trialdata] = computeHistogram(spike_times, time, sigma)
% computes a histogram from spike times, with smooting sigma (in ms)
%
% INPUT
% spike_times: vector with times at which spike occured
% time: vector of timepoints (ms)
% sigma, smoothing factor (ms)
%
% OUTPUT
% trialdata: convolved spikes
%
% plot(time, trialdata), plots the histogram for the current trial
%
% 


% convert to row vector
spike_times = spike_times(:)';

trialdata=zeros(1,length(time));
y=ones(1,length(time));
for ispike = 1:length(spike_times)
    spike=(y*(1/(sigma*sqrt(2*pi))).*exp(-(((time-spike_times(ispike)).^2)/(2*sigma^2))));
    trialdata(1,:)=trialdata(1,:) + spike;
end