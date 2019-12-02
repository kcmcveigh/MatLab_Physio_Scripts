clear
%ecg libraries
addpath('../ECG_Data_Analysis');
%GSR libraries
addpath('../GSR_Analysis');
%timing libraries
addpath('../Load_Files_Convert_Timing');
%Data loading library
addpath('../data_loaders');

subject_code_str = input('Enter subject code: ','s');
subject_code = str2num(subject_code_str);
raw_data_dir =sprintf('raw_peaks/%s',subject_code_str);
mkdir (raw_data_dir);

%find shimmer data directory
shimmer_dir = dir(sprintf('../../shimmer_data/*_%s_*/*',subject_code_str));
shimmer_data_folder = shimmer_dir.folder;


%get paths for data files TODO: make a method
gsr_file = dir(sprintf('../../shimmer_data/*_%s_*/*_89*',subject_code_str));
gsr_file_path =sprintf('%s/%s', gsr_file.folder,gsr_file.name);
ecg_file = dir(sprintf('../../shimmer_data/*_%s_*/*Shimmer_CA*',subject_code_str));
ecg_file_path = sprintf('%s/%s', ecg_file.folder,ecg_file.name);
baseline_file = dir(sprintf('../../shimmer_data/*_%s_*/*Baseline*',subject_code_str));
baseline_file_path =sprintf('%s/%s', baseline_file.folder,baseline_file.name);
log_file_dir = dir(sprintf('../../shimmer_data/*_%s_*/*log*',subject_code_str));
log_file_path =sprintf('%s/%s', log_file_dir.folder,log_file_dir.name);

%%load log file
delimiter = ' ';
lines_in = 1;
log_file = importdata(log_file_path, delimiter, lines_in);

%%load baseline
baseline_log_file =importdata(baseline_file_path);

eda_raw = LoadConsensysData(gsr_file_path, ["Unix","Conductance"]);
resp_ecg_data= LoadConsensysData(ecg_file_path, ["Unix","RESP", "LA-RA"]);

%add baseline 
%get baseline start and stop time and convert to unix
baseline_start_datetime = datetime(baseline_log_file.data(1), 'ConvertFrom', 'datenum');
baseline_end_datetime = datetime(baseline_log_file.data(2), 'ConvertFrom', 'datenum');
baseline_start_unix = posixtime(baseline_start_datetime + hours(4));
baseline_end_unix = posixtime(baseline_end_datetime+ hours(4));

%get index of start time unix for resp and gsr
index_of_baseline_start_ecg = find(baseline_start_unix<= resp_ecg_data(:,1)/1000,1);
index_of_baseline_start_eda = find(baseline_start_unix<= eda_raw(:,1)/1000,1);

%get index of end time in unix
index_of_baseline_end_ecg = find(baseline_end_unix<= resp_ecg_data(:,1)/1000,1);
index_of_baseline_end_eda = find(baseline_end_unix<= eda_raw(:,1)/1000,1);

%baseline eda data
base_eda = eda_raw(index_of_baseline_start_eda:index_of_baseline_end_eda,:);
base_time_eda = base_eda(:,1) - base_eda(1,1);
base_time_eda = base_time_eda/1000;

[scr_peaks_base,scr_peak_time_base] = CleanSCRandFindPeaks(base_eda(:,2), base_time_eda);
scr_peak_times_file_name = sprintf('%s/%s_base_scr_peaks', raw_data_dir, num2str(subject_code));
scr_peak_time_base(:,2) = scr_peaks_base;
csvwrite(scr_peak_times_file_name,scr_peak_time_base);

%base line ECG / RESP
base_ecg_resp = resp_ecg_data(index_of_baseline_start_ecg:index_of_baseline_end_ecg,:);
base_ecg_resp_time = base_ecg_resp(:,1) - base_ecg_resp(1,1);
base_ecg_resp_time = base_ecg_resp_time/1000;

opol = 6;
[resp_p,resp_s,resp_mu] = polyfit(base_ecg_resp_time,base_ecg_resp(:,2),opol);
resp_detrender = polyval(resp_p,base_ecg_resp_time,[],resp_mu);
detrended_resp = base_ecg_resp(:,2) - resp_detrender;


[ecg_p,ecg_s,ecg_mu] = polyfit(base_ecg_resp_time,base_ecg_resp(:,3),opol);
ecg_detrender = polyval(ecg_p,base_ecg_resp_time,[],ecg_mu);
detrended_ecg = base_ecg_resp(:,3) - ecg_detrender;
CleanECGRespData(base_ecg_resp_time,detrended_ecg,"ecg", raw_data_dir, subject_code_str, 'base')
CleanECGRespData(base_ecg_resp_time,detrended_resp,"respiration", raw_data_dir, subject_code_str, 'base')

%line up experiment start time with correct index in shimmer files
unix_exp_start = GetExpStartUnix(log_file);
index_of_experiment_start_ecg = find(unix_exp_start<= resp_ecg_data(:,1)/1000,1);
index_of_experiment_start_eda = find(unix_exp_start<= eda_raw(:,1)/1000,1);

%get all experiment data for ecg/resp
resp_ecg_data_exp = resp_ecg_data(index_of_experiment_start_ecg:end,:);
time_ecg_exp = (resp_ecg_data_exp(:,1)- resp_ecg_data_exp(1,1))/1000;
CleanECGRespData(time_ecg_exp,resp_ecg_data_exp(:,3),"ecg", raw_data_dir, subject_code_str, 'exp');
CleanECGRespData(time_ecg_exp,resp_ecg_data_exp(:,2),"respiration", raw_data_dir, subject_code_str, 'exp');

%get all experiment data for eda
eda_exp = eda_raw(index_of_experiment_start_eda:end,:);
time_eda_exp = (eda_exp(:,1)- eda_exp(1,1))/1000;

[scr_peak_percents,scr_peak_time_sec] = CleanSCRandFindPeaks(eda_exp(:,2), time_eda_exp);
scr_peak_times_file_name = sprintf('%s/%s_exp_scr_peaks', raw_data_dir, subject_code_str);
scr_peak_time_sec(:,2) = scr_peak_percents;
csvwrite(scr_peak_times_file_name,scr_peak_time_sec);

