
%get anticipation period and video period measures from ECG/Resp data
function [resp_anticipation, hrv_anticipation, heart_period_anticipation,...
                             resp_video, hrv_video, heart_period_video] =...
                              GetEcgAndRespMeasures(subject_code, data_dir,...
                              ecg_data, time_ecg, log_data)

% ECG - HR
    ecg_raw =ecg_data(:,3);
    [peak_times,ibi,suspect_peak_indices] = GetPeaksAndIBI(ecg_raw, time_ecg, 'ecg');
    %save peaks/peak times for accountability
    ecg_peak_times_file_name = sprintf('%s/ecg_peak_times_%s_experimental',data_dir, num2str(subject_code));
    csvwrite(ecg_peak_times_file_name,peak_times);
    
    
%RESPIRATION
    resp_raw =ecg_data(:,2);
    %filter respiration data
    Hd = designfilt('lowpassfir','FilterOrder',20,'CutoffFrequency',50, ...
       'DesignMethod','window','Window',{@kaiser,6},'SampleRate',1000);
    filter_resp = filter(Hd,resp_raw);
    
    %get respiration metrics - TODO decide what to do with suspect indices
    [resp_peak_times,breath_interval,resp_suspect_peak_indices] = ...
                        GetPeaksAndIBI(filter_resp, time_ecg, 'respiration');
    
    % save respiration peak tiemes and sizes for accountability
    resp_peak_times_file_name = sprintf('%s/resp_peak_times_%s_experimental', data_dir, num2str(subject_code));
    csvwrite(resp_peak_times_file_name,[resp_peak_times, resp_peaks]);
    
    %indexes for corresponding column in the log file
    video_start_col = 10;
    video_end_col = 11;
    word_on_col = 4;
    word_off_col = 5;
    num_trials = numel(log_data(:,1));
    
    %initialize empty arrays
    heart_period_anticipation = nan(num_trials,1);
    heart_period_video = nan(num_trials,1);

    hrv_anticipation = nan(num_trials,1);
    hrv_video = nan(num_trials,1);

    resp_anticipation = nan(num_trials,1);
    resp_video= nan(num_trials,1);

    %need to control for if calculating in a gap
    for i = 1:num_trials
        
        %get timing information from log file
        log_file_row = log_data(i,:);
        video_start = log_file_row(video_start_col);
        video_end = log_file_row(video_end_col);
        word_on =log_file_row(word_on_col);
        word_off = log_file_row(word_off_col);
        expected_fear_rating_onset = word_off+4;%TODO will be 8 with the next set of data
        
        %get anticipation measures from ecg
        [hrv_anticipation(i), heart_period_anticipation(i)] = GetECGMeasures(word_on,...
            expected_fear_rating_onset,peak_times,ibi,suspect_peak_indices);
        %get video measures from ecg
        [hrv_video(i), heart_period_video(i)] = GetECGMeasures(video_start,video_end,...
            peak_times,ibi,suspect_peak_indices);
        
        %get anticipation breaths
        resp_anticipation(i) = GetRespMeasures(word_on, expected_fear_rating_onset, resp_peak_times,...
            breath_interval, resp_suspect_peak_indices);
        %get video breaths
        resp_video(i) = GetRespMeasures(video_start, video_end, resp_peak_times,...
            breath_interval, resp_suspect_peak_indices);
    end
    
end

