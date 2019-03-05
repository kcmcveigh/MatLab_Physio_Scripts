%*min_prominence* - min height to count as a peak
%*interval_low minimum* distance between peaks required ie not .01 for hr
% *interval_high* max distance between peaks allowed not 50 seconds for resp
function [r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal,...
                            time_sec, min_prominence,interval_low, interval_high)
    [r_spikes, peak_times] = findpeaks(ecg_signal,time_sec, 'MinPeakProminence',min_prominence);
    ibi = diff(peak_times);
    %identify peak that the time between them is too long or too
    suspect_peak_times = find(ibi <interval_low | ibi > interval_high);
end

