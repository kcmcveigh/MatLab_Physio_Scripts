function [peak_times,ibi,suspect_peak_indices] = GetPeaksAndIBI(ecg_raw,time_ecg, measure_type)
    
    human_approved = false;
    
    %assign baseline values for expected interval and peak size
    if(strcmp(measure_type,'ecg'))
        min_prominence = .8;
        interval_low =.4;
        interval_high=1.4;
    else
        min_prominence = .05;
        interval_low =.2
        interval_high = 15;
    end
    
    %Human review of data
    while(~human_approved)
        [peaks, peak_times,ibi,suspect_peak_indices]= GetPeaks(ecg_raw,time_ecg, min_prominence, ...
            interval_low, interval_high);
        
        %plot data and peaks
        plot(time_ecg,ecg_raw)
        hold on
        plot(peak_times, peaks, 'rs');
        hold off
        
        %print suspect peaks indices for human to review
        suspect_peak_times = peak_times(suspect_peak_indices);
        fprintf('peaks (times) that are either too close together or too far appart\n')
        disp(suspect_peak_times);
        fprintf('IBI Values\n')
        disp(ibi(suspect_peak_indices));
        
        %ask human for approval
        approval_string = input('peaks identified correctly? (y/n): ','s');
        if(approval_string == 'y')
            human_approved = true;
        else
            fprintf('missing valid peaks? type: peaks \n');
            fprintf('need to cut noisy data? type split \n');
            cut_or_peaks = input('split or peaks: ','s');
            
            %if missing or getting too many peaks adjust the prominence
            %(peak height)
            if(strcmp(cut_or_peaks,'peaks'))
                min_prominence = str2num(input('enter new prominence: ', 's'));
                fprintf('\n rerunning')
            %other wise cut data    
            else
                cut_start = str2num(input('enter cut start: ','s'));
                cut_end = str2num(input('enter cut end (seconds): ','s'));
                indices_to_cut = find(cut_start<time_ecg & time_ecg<cut_end);
                num_data_points = numel(indices_to_cut,1);
                ecg_raw(indices_to_cut) = nan(num_data_points,1);
            end
        end
    
    end
end

