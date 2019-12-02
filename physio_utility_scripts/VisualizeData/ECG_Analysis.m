
function VisualizeHRFromECG(filename)
    base_line_data = importdata(filename)
    headers = base_line_data.colheaders;
    ecg_data = base_line_data.data;
    time = ecg_data(:,1);
    ecg_signal = ecg_data(:,2);
    %all heart r spike peaks - calculate the difference between them
    [r_spikes, time_between_peaks] = findpeaks(ecg_signal,time, 'MinPeakProminence',1);
    ibi = diff(time_between_peaks);
    HR = ibi*60;
    %get first time
    start_time = time(1);
    %get second time
    end_time = time(length(time));
    %get difference
    total_time = end_time - start_time;
    %get length of HR
    number_of_heart_beats = length(HR)
    %create an array of length HR
    x_time = linspace(0,total_time, number_of_heart_beats);
    plot(x_time, HR)
end

