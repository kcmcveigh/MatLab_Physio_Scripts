%excluded_peaks - peaks that are further apart then the specified
%ranges for eligible measurements
function [hrv,heart_period] = GetECGMeasures(start_time,end_time,peak_times,ibi,excluded_peaks)
    
    %get peak times in time period
    peaks_indices_in_interval = find(start_time<=peak_times & peak_times <= end_time);
    %get ibi for peaks - don't get the last one because that will over lap
    ibis_in_interval = ibi(peaks_indices_in_interval(1:(end-1)));
    
    %get the indices of the ibi on either side of the ones contained within
    %this interval this accounts for the possibility of if you have
    %something like this --^--^--^|-------^--^--^--^---------|--^--^ you
    %can see that that although all the ibi in between | and | are within
    %the allow able range but the ones book end it are not this could lead
    %to erroneous judgements
    ibis_in_interval_check = peaks_indices_in_interval;
    ibis_in_interval_check(end+1)=ibis_in_interval_check(end)+1;
    ibis_in_interval_check(end+1) = ibis_in_interval_check(1)-1;
    %check to see if any peaks in our interval our outside of peak interval
    %range
    num_ineligible_ibis = numel(intersect(ibis_in_interval_check,excluded_peaks));
    
    if(num_ineligible_ibis==0)%if all ibis are eligible continue
        hrv = CalculateHRV(ibis_in_interval);
        heart_period = mean(ibis_in_interval);
    else%if not return nan
        hrv = nan;
        heart_period = nan;
    end
end

