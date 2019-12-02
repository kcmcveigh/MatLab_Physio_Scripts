%*min_prominence* - min height to count as a peak
%*interval_low minimum* distance between peaks required ie not .01 for hr
% *interval_high* max distance between peaks allowed not 50 seconds for resp
function [peaks,peak_times,ibi, suspect_peaks] = GetPeaks(...
                            ecg_signal, time_sec,...
                            min_prominence,interval_low,...
                            interval_high)  
    [peaks, peak_times] = findpeaks(ecg_signal,time_sec, 'MinPeakProminence',min_prominence);
    %add peak times 
    %cut manually cutable peaks
    ibi = diff(peak_times);
    %identify peak that the time between them is too long or too
    out_of_bound_peaks = find(ibi <interval_low | ibi > interval_high);
    suspect_peaks = out_of_bound_peaks;
    %clean array so each peak is only logged once
    suspect_peaks = unique(suspect_peaks);
end

