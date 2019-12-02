function CleanECGRespData(time,signal, signal_type, data_dir, subject_code, portion_exp)
    if(signal_type == "ecg")
        [peak_times,interval,suspect_peaks, peaks] = GetPeaksAndIBI(signal, time, signal_type);
    else
        filter_resp = smooth(signal, 256, 'moving');
        [peak_times,interval, suspect_peaks, peaks] = ...
                            GetPeaksAndIBI(filter_resp, time, signal_type);
    end
    file_name = sprintf('%s/%s_%s_%s_peak_times',data_dir,subject_code,portion_exp,signal_type);
    disp(suspect_peaks);
    peak_times(:,2) = nan(length(peak_times),1);
    peak_times(1:length(suspect_peaks),2) = suspect_peaks;
    csvwrite(file_name,peak_times);
end

