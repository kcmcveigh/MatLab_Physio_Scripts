function [event_rate] = CalculateSCREventsPerTrial(start_time,end_time, peak_time_sec,...
    peak_EDA_uS, SCR_percent_cutoff)
    %count events up to 4 seconds after
    SCR_Period_Off_Offset = 4;
     %don't count events unless they happen after 1 second for eda lag
    SCR_Period_Onset_Offset = 1;
    %word onset + 1 in seconds
    start_time = start_time+SCR_Period_Onset_Offset;
    %word offset + 4
    end_time = end_time+SCR_Period_Off_Offset;
    %times indices of events in period
    event_times = find(peak_time_sec > start_time & peak_time_sec < end_time);
    %Get all the events of these indices
    events = peak_EDA_uS(event_times);
    %take events that are above the threshold - gives logical array
    valid_events = events > SCR_percent_cutoff;
    %return the number of events above threshold
    num_events = sum(valid_events);
    %duration
    duration = end_time - start_time;
    %return events per - second
    event_rate = num_events/duration;
end

