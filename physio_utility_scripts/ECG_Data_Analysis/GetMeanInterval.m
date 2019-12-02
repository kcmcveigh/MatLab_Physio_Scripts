function [mean_interval] = GetMeanInterval(...
    start_time,...
    end_time,...
    peak_times,...
    ibi,...
    excluded_peaks...
    )
     %get the indices of the ibi on either side of the ones contained within
    %this interval this accounts for the possibility of if you have
    %something like this --^--^--^|-------^--^--^--^---------|--^--^ you
    %can see that that although all the ibi in between | and | are within
    %the allow able range but the ones book end it are no
    peaks_indices_in_interval = find(start_time<peak_times & peak_times < end_time);
    ibis_in_interval = ibi(peaks_indices_in_interval);
    ibis_in_interval_check = peaks_indices_in_interval;
    %need to create check to ensure that indices do not go out of bounds
    if(numel(ibis_in_interval) > 0)
        ibis_in_interval_check(end+1)=ibis_in_interval_check(end)+1;
        ibis_in_interval_check(end+1) = ibis_in_interval_check(1)-1;
        if(numel(intersect(ibis_in_interval_check,excluded_peaks))==0)
            mean_interval = mean(ibis_in_interval);
        else
            mean_interval = nan;
        end
    else
        mean_interval=nan;
    end
end
