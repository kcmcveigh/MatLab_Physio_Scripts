% Load files - analyze data
clear
SCR_cut_off = 5;

%ecg libraries
addpath('../ECG_Data_Analysis');
%GSR libraries
addpath('../GSR_Analysis');
%timing libraries
addpath('../Load_Files_Convert_Timing');

data_path ='/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/Data/raw_peaks_20191118/1*';

list_of_participants = dir(data_path);

for i=1:numel(list_of_participants)-2
    participant_num = list_of_participants(i).name;
    folder = list_of_participants(i).folder;
    try
        MakeLogFileWithPhysioMeasures(participant_num, folder, SCR_cut_off)
    catch e
        disp('error with participant num')
        disp(participant_num)
        disp('error:')
        disp(e)
    end

end


function MakeLogFileWithPhysioMeasures(subject_code_str, folder_path, SCR_cut_off)
    subject_code = str2num(subject_code_str);

    
    %% shimmer data/log file dir
    log_files_path = sprintf('/Users/phoenix/Desktop/Backup/Physio_Data/shimmer_data/*_%s_*/*log*',subject_code_str);
    subject_peak_dir = sprintf('%s/%s/*', folder_path,subject_code_str);
    
    %% load log file
    % log file
    log_file_dir = dir(log_files_path);
    log_file_path =sprintf('%s/%s', log_file_dir.folder,log_file_dir.name);
    delimiter = ' ';
    lines_in = 1;
    log_file = importdata(log_file_path, delimiter, lines_in);
    log_data=log_file.data;
    num_rows = length(log_data(:,1));

    %% load peak files 
    peak_files = dir(subject_peak_dir);
    peak_dir = peak_files(1).folder;

    %load ecg
    try
        ecg_base_path = strcat(peak_dir,'/',subject_code_str,'_base_ecg_peak_times');
        base_ecg = csvread(ecg_base_path);
    catch exception
        disp(strcat('base_ecg crash ',subject_code_str))
        base_ecg = nan;
    end

    try
        ecg_exp_path = strcat(peak_dir,'/',subject_code_str,'_validated_ecg_exp_peaks');
        %disp(ecg_exp_path)
        exp_ecg = importdata(ecg_exp_path);
        exp_ecg(:,2) = nan;
    catch exception
        disp(strcat('exp_ecg crash ',subject_code_str))
        exp_ecg = nan;
    end
    %load resp
    try
       resp_base_path = strcat(peak_dir,'/',subject_code_str,'_base_respiration_peak_times');
        base_resp = csvread(resp_base_path); 
    catch
        base_resp = nan;
    end

    try
        resp_exp_path = strcat(peak_dir,'/',subject_code_str,'_exp_respiration_peak_times');
        exp_resp = csvread(resp_exp_path);
    catch exception
        exp_resp = nan;
    end
    %load scr
    try
        scr_base_path = strcat(peak_dir,'/',subject_code_str,'_base_scr_peaks');
        base_scr = csvread(scr_base_path);
    catch exception
        base_scr = nan;
    end

    try
        scr_exp_path = strcat(peak_dir,'/',subject_code_str,'_exp_scr_peaks');
        exp_scr = csvread(scr_exp_path);
    catch exception
       exp_scr = nan;
    end

    %% get mean baseline measures 
    if(~isnan(base_resp(1,1)))
        baseline_resp = CalcBaseLine(base_resp);
        baseline_resp = baseline_resp*ones(num_rows,1);
    else
        baseline_resp = nan(num_rows,1); 
    end

    %ECG
    if(~isnan(base_ecg(1,1)))
        baseline_hp = CalcBaseLine(base_ecg);
        baseline_hp = baseline_hp*ones(num_rows,1);
    else
        baseline_hp = nan(num_rows,1); 
    end

    %SCR
    if(~isnan(base_scr(1,1)))
        baseline_scr = CalcBaselineSCR(base_scr, SCR_cut_off); %num SCR events per 20 second period
        baseline_scr  = baseline_scr * ones(num_rows,1);
    else
        baseline_scr  = nan(num_rows,1); 
    end

    %% EXPERMENT CALCS

    %RESPIRATION
    if(~isnan(exp_resp(1,1)))

    [resp_base_anticipation,...
        resp_anticipation,...
        resp_base_video,...
        resp_video,...
        resp_video_ratings, ...
        resp_isi] = GetEcgAndRespMeasures...
            (exp_resp(:,1),...
            exp_resp(:,2),...
            log_data);
    else
        resp_base_anticipation = nan(num_rows,1);
        resp_anticipation = nan(num_rows,1);
        resp_base_video = nan(num_rows,1);
        resp_video = nan(num_rows,1);
        resp_video_ratings = nan(num_rows,1);
        resp_isi = nan(num_rows,1);
    end

    %ECG
    if(~isnan(exp_ecg(1,1)))

        [heart_period_baseline_anticipation,...
            heart_period_anticipation,...
            heart_period_baseline_video,...
            heart_period_video,...
            hp_video_ratings,...
            hp_isi] = GetEcgAndRespMeasures...
            (exp_ecg(:,1),...
            exp_ecg(:,2),...
            log_data);
    else
        heart_period_baseline_anticipation = nan(num_rows,1);
        heart_period_anticipation = nan(num_rows,1);
        heart_period_baseline_video = nan(num_rows,1);
        heart_period_video = nan(num_rows,1);
        hp_video_ratings =nan(num_rows,1);
        hp_isi = nan(num_rows,1);
    end

    %SCR
    if(~isnan(exp_scr(1,1)))

        [anticipation_scr,...
            video_scr,...
            rating_scr,...
            isi_scr]...
            = CalculateSCREvents(...
            log_data,...
            exp_scr(:,2),...
            exp_scr(:,1),...
            SCR_cut_off);
    else
        anticipation_scr = nan(num_rows,1);
        video_scr = nan(num_rows,1);
        rating_scr = nan(num_rows,1);
        isi_scr = nan(num_rows,1);
    end

    hrv_anticipation = nan(num_rows,1);
    hrv_video = nan(num_rows,1);

    participant_number_on_row = ones(num_rows,1) * subject_code; 
    trial_num = transpose(linspace(1,num_rows,num_rows));
    %% Aggregation of all measures
    log_file.data(:,20:42) = [resp_anticipation, hrv_anticipation,...
                                heart_period_anticipation, anticipation_scr...
                                resp_video, hrv_video, heart_period_video,video_scr,...
                                hp_video_ratings, hp_isi, resp_video_ratings, resp_isi,...
                                rating_scr, isi_scr, participant_number_on_row...
                                heart_period_baseline_anticipation,resp_base_anticipation,...
                                heart_period_baseline_video, resp_base_video,...
                                baseline_resp, baseline_hp, baseline_scr, trial_num];
    %write data to file
    CreateLogFileWithPhysio(subject_code,log_file);
end
%% Helper Functions
%calculate averages from the baseline files
function baseline_average = CalcBaseLine(base_physio)
    cut_peaks = base_physio(:,2);
    cut_peaks = cut_peaks(~isnan(cut_peaks));
    if(numel(cut_peaks)~=0)%are there any cut peaks?
        sum_diff = zeros(numel(cut_peaks),1);
        num_elements = zeros(numel(cut_peaks),1);
        for i=1:numel(cut_peaks)%for get sections of averages between cut peaks
            
            %just calculating the averages inbetween cut peaks
            if(i ==1)
                first_idx = 1;
                last_idx = cut_peaks(i);
            elseif(i == numel(cut_peaks))
                first_idx = cut_peaks(i);
                last_idx = numel(base_physio(:,1));
            else
                first_idx = cut_peaks(i);
                last_idx = cut_peaks(i+1);
            end
            current_selection = base_physio(first_idx:last_idx,1);
            num_elements(i) = numel(current_selection);
            sum_diff(i) = sum(diff(current_selection));
        end

        baseline_average = sum(sum_diff) / sum(num_elements);
    else
        %if no cuts just get mean of HP
        baseline_average = mean(diff(base_physio(:,1)));
    end
end

function scr_peaks_per_sec_base = CalcBaselineSCR(base_scr_peaks, scr_cut_off)
    if isempty(base_scr_peaks(:,2))
        scr_peaks_per_sec_base = nan;
    else
        peaks_over_cut_off = base_scr_peaks(:,2)>scr_cut_off;
        eligible_peak_times = base_scr_peaks(peaks_over_cut_off,1);
        eligible_peaks = eligible_peak_times(5 < eligible_peak_times & eligible_peak_times < 295);
        num_peaks = numel(eligible_peaks);
        scr_peaks_per_sec_base = num_peaks/290;
    end
end