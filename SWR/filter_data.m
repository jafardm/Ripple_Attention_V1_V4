
function data = filter_data(data, sample_rate, lo_cutoff_freq, hi_cutoff_freq)
% filter data 
% data should be a column vectror  or a matrix with row as sample and
% columns as trials or data

lo_cutoff_wn = double(lo_cutoff_freq) / (double(sample_rate) / 2.);
hi_cutoff_wn = double(hi_cutoff_freq) / (double(sample_rate) / 2.);
[b_lo_cutoff, a_lo_cutoff] = butter(4, lo_cutoff_wn, 'high');
[b_hi_cutoff, a_hi_cutoff] = butter(4, hi_cutoff_wn, 'low');
data = filtfilt(b_lo_cutoff, a_lo_cutoff, data);
data = filtfilt(b_hi_cutoff, a_hi_cutoff, data);
end
