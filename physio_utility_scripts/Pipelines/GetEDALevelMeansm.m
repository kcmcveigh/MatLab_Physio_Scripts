clear

%GSR libraries
addpath('../GSR_Analysis');
%timing libraries
addpath('../Load_Files_Convert_Timing');
%Data loading library
addpath('../data_loaders');
% load data 
subject_code_str = "120";
%find shimmer data directory
shimmer_dir = dir(sprintf('../../shimmer_data/*_%s_*/*',subject_code_str));
shimmer_data_folder = shimmer_dir.folder;


%get paths for data files TODO: make a method
gsr_file = dir(sprintf('../../shimmer_data/*_%s_*/*_89*',subject_code_str));
gsr_file_path =sprintf('%s/%s', gsr_file.folder,gsr_file.name);
% clean data
log_file_dir = dir(sprintf('../../shimmer_data/*_%s_*/*log*',subject_code_str));
log_file_path =sprintf('%s/%s', log_file_dir.folder,log_file_dir.name);

%%load log file
delimiter = ' ';
lines_in = 1;
log_file = importdata(log_file_path, delimiter, lines_in);

eda_raw = LoadConsensysData(gsr_file_path, ["Unix","Conductance"]);

%line up experiment start time with correct index in shimmer files
unix_exp_start = GetExpStartUnix(log_file);
index_of_experiment_start_eda = find(unix_exp_start<= eda_raw(:,1)/1000,1);

%get all experiment data for eda
eda_exp = eda_raw(index_of_experiment_start_eda:end,:);
time_eda_exp = (eda_exp(:,1)- eda_exp(1,1))/1000;

[scr_peak_percents,scr_peak_time_sec, clean_eda, peak_EDA_uS] = CleanSCRandFindPeaks(eda_exp(:,2), time_eda_exp);

clean_eda;
time_eda_exp;
log_data = log_file.data;

video_start_col = 10;
video_end_col = 11;
word_on_col = 4;
word_off_col = 5;
video_rating_resp_times = [16, 17, 18, 19];

num_trials = numel(log_data(:,1));
anticipation_baseline = nan(num_trials,1);
anticipation = nan(num_trials,1);
video = nan(num_trials,1);
video_baseline = nan(num_trials,1);
video_rating= nan(num_trials,1);
break_between_trials = nan(num_trials,1);
file_name = sprintf("eda_mean_levels/mean_eda_levels_%s",subject_code_str);
fid = fopen(file_name,'w');
for i = 1:num_trials
    log_file_row = log_data(i,:);
    %get baseline before anticipation
    
    word_on =log_file_row(word_on_col);
    pre_word_ant_start = word_on - 3;
    pre_trial_base = CalcMeanEda(time_eda_exp, clean_eda, pre_word_ant_start, word_on);
    fprintf(fid, "%s %s %1.3f \n", subject_code_str, "pre_trial_base", pre_trial_base);
    
    %get anticipation breaths
    word_off = log_file_row(word_off_col);
    expected_fear_rating_onset = word_off+8;
    anticipation = CalcMeanEda(time_eda_exp, clean_eda, word_on, word_off);
    fprintf(fid, "%s %s %1.3f \n", subject_code_str, "anticipation", anticipation);

    %get pre video baseline
    video_start = log_file_row(video_start_col);
    pre_video_anticipation_start = video_start-3;
    pre_video_baseline = CalcMeanEda(time_eda_exp, clean_eda, pre_video_anticipation_start, video_start);
    fprintf(fid, "%s %s %1.3f \n", subject_code_str, "pre_video_base", pre_video_baseline);

    %get video breaths
    video_end = log_file_row(video_end_col);
    video = CalcMeanEda(time_eda_exp, clean_eda, video_start, video_end);
    fprintf(fid, "%s %s %1.3f \n", subject_code_str, "video", video);
end

% chop up data
% get means
% write to file
% aggregate