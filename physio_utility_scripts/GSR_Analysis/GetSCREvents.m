
function [anticipation_events, video_events] = GetSCREvents(subject_code, data_dir, condition,...
                                                            EDA_data, time_sec, trial_times, SCR_percent_cutoff)  
    %validate eda and find peaks (events in data) - does not filter based
    %on peak size yet
    [peak_EDA_uS,peak_time_sec] = CleanSCRandFindPeaks(EDA_data, time_sec);
   %save intermediary step in its own folder - this way we have
   %accountability if we want to rerunning analysises as to where the peaks
   %we identified in our data are
    peak_times_file_name = sprintf('%s/scr_peak_times_%s_%s', data_dir, num2str(subject_code), condition); 
    csvwrite(peak_times_file_name,[peak_time_sec, peak_EDA_uS]);
    
    %return number of events in anticipation period and video periods based 
    %on whether the peak percentage is greater than SCR cutoff
    [anticipation_events, video_events] = CalculateSCREvents(trial_times,...
    peak_EDA_uS,peak_time_sec,SCR_percent_cutoff);
end