function [peak_times,ibi,suspect_peak_indices, peaks] = GetPeaksAndIBI(ecg_raw,time_ecg, measure_type)
    
    %assign baseline values for expected interval and peak size
    if(strcmp(measure_type,'ecg'))
        min_prominence = .8;
        interval_low =.4;
        interval_high=1.5;
    else
        min_prominence = .02;
        interval_low = .5;
        interval_high = 15;
    end
    
    
    [peaks, peak_times,ibi,suspect_peak_indices]= GetPeaks(...
            ecg_raw,time_ecg,...
            min_prominence, ...
            interval_low, ...
            interval_high);
    approval_string = "";
    %Human review of data
    while(approval_string ~= 'y')
        
        %plot data and peaks
        plot(time_ecg,ecg_raw)
        hold on
        plot(peak_times, peaks, 'rs');
        ylim ([min(ecg_raw) max(ecg_raw)]);
        hold off
        
        %print suspect peaks indices for human to review
        suspect_peak_times = peak_times(suspect_peak_indices);
        fprintf('peaks (times) that are either too close together or too far appart\n')
        disp(suspect_peak_times);
        fprintf('IBI Values\n')
        disp(ibi(suspect_peak_indices));

        fprintf('adjust find peaks params? type: peaks \n');
        fprintf('Want to add peaks at a specific time? type add \n');
        fprintf('need to cut noisy data? type split \n');
        fprintf('things are all good? type all good \n');
        cut_or_peaks = input('split/peaks/add: ','s');

        %if missing or getting too many peaks adjust the prominence
        if(strcmp(cut_or_peaks,'peaks')),
            min_prominence = str2num(input('enter new prominence: ', 's'));
            fprintf('\n rerunning')
            [peaks, peak_times,ibi,suspect_peak_indices]= GetPeaks(...
                                                ecg_raw,time_ecg,...
                                                min_prominence, ...
                                                interval_low, ...
                                                interval_high);
        %other wise cut data 
        elseif(strcmp(cut_or_peaks,'add'))
            [peaks, peak_times] = addPeaks(peaks, peak_times);
        elseif(strcmp(cut_or_peaks,'split'))
            [peaks, peak_times] = manuallyCutPeaks(peaks, peak_times);
        end
        ibi = diff(peak_times);
        %identify peak that the time between them is too long or too
        out_of_bound_peaks = find(ibi <interval_low | ibi > interval_high);
        suspect_peaks = out_of_bound_peaks;
        %clean array so each peak is only logged once
        suspect_peak_indices= unique(suspect_peaks);
        approval_string = input('peaks identified correctly? (y/n): ','s');
    end
end


%manually add peaks and update peaks and peak times with new peaks
function [peaks, peak_times] = addPeaks(peaks, peak_times)
    still_adding = true;
    manually_added_peaks = [];
    %get manually added peaks
    while(still_adding)
        new_peak_time = str2num(input('enter new peak time: ', 's'));
        manual_peak_num = numel(manually_added_peaks) + 1;
        manually_added_peaks(manual_peak_num) = new_peak_time;
        done = input('done adding peaks? (y/n): ', 's');
        if(strcmp(done,'y'))
            still_adding = false;
        end
    end
    %add peaks to peaks and peak_times
    for i=1:numel(manually_added_peaks)
       %get times to add peaks from user
       new_peak_time = manually_added_peaks(i);
       peak_after_manual_peak = find(peak_times > new_peak_time,1);
       peaks_times_before_manual = peak_times(1:(peak_after_manual_peak-1));
       peaks_times_after_manual = peak_times(peak_after_manual_peak:end);
       peak_times = cat(1,peaks_times_before_manual,[new_peak_time],peaks_times_after_manual);
       %insert peaks at correct times
       peaks_before_manual = peaks(1:(peak_after_manual_peak-1));
       peaks_after_manual = peaks(peak_after_manual_peak:end);
       peaks = cat(1,peaks_before_manual,[mean(peaks)],peaks_after_manual);
    end
end

function [peaks, peak_times] = manuallyCutPeaks(peaks, peak_times)
    still_cutting = true;
    manually_excluded_peaks=[];
    while(still_cutting)
        cut_start = str2num(input('enter cut start: ','s'));
        cut_end = str2num(input('enter cut end (seconds): ','s'));
        newly_excluded_peaks = find(cut_start<peak_times & peak_times<cut_end);
        manually_excluded_peaks = cat(1,newly_excluded_peaks,manually_excluded_peaks);
        done_cutting = input('done cutting peaks? (y/n): ', 's');
        if(strcmp(done_cutting,'y'))
            still_cutting = false;
        end
    end
    %delete peak times
    peak_times(manually_excluded_peaks)=[];
    peaks(manually_excluded_peaks)=[];
end
