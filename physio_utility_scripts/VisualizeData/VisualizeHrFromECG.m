
function VisualizeHRFromECG(ecg_filename, log_filename)
    base_line_data = importdata(ecg_filename)
    headers = base_line_data.colheaders;
    ecg_data = base_line_data.data;
    time = ecg_data(:,1);
    time = time - time(1,1);
    ecg_signal = ecg_data(:,2);
    %all heart r spike peaks - calculate the difference between them
    [r_spikes, time_between_peaks] = findpeaks(ecg_signal,time, 'MinPeakProminence',1);
    ibi = diff(time_between_peaks);
    HR = ibi*60;
    hr_min = min(HR);
    hr_max = max(HR);
    trial_times = getTrialTimePeriods(log_filename)
    %get first time
    start_time = time(1);
    %get second time
    end_time = time(length(time));
    %get difference
    total_time = end_time - start_time;
    %get length of HR
    number_of_heart_beats = length(HR);
    %create an array of length HR
    x_time = linspace(0,total_time, number_of_heart_beats);
    hold on %turn on hold on to shade periods
    ShadeTrials(trial_times, hr_min, hr_max)%shade periods for trials
    plot(x_time, HR)
    xlabel('time (sec)')
    ylabel('Heart Beats Per Minute')
    title('Time vs HR')
end

