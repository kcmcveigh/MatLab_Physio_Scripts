clear
%ecg libraries
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/ECG_Data_Analysis');
%GSR libraries
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/GSR_Analysis');
%timing libraries
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/Load_Files_Convert_Timing');
%Data loading library
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/data_loaders');

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

SCR_Cut_Off = 6;
%load data eda
eda_raw = LoadConsensysData(gsr_file_path, ["Unix","Conductance"]);
resp_ecg_data= LoadConsensysData(ecg_file_path, ["Unix","RESP", "LA-RA"]);
%%load baseline
baseline_log_file =importdata(baseline_file_path);
%calc baseline physio measurements
[baseline_hp, baseline_eda, baseline_hrv, baseline_resp] = GetBaseLineMeasurements(subject_code, raw_data_dir,...
                                                            resp_ecg_data,eda_raw, SCR_Cut_Off, baseline_log_file);

%line up experiment start time with correct index in shimmer files
unix_exp_start = GetExpStartUnix(log_file);
index_of_experiment_start_ecg = find(unix_exp_start<= resp_ecg_data(:,1)/1000,1);
index_of_experiment_start_eda = find(unix_exp_start<= eda_raw(:,1)/1000,1);

%get all experiment data for ecg/resp
resp_ecg_data_exp = resp_ecg_data(index_of_experiment_start_ecg:end,:);
time_ecg_exp = (resp_ecg_data_exp(:,1)- resp_ecg_data_exp(1,1))/1000;

%get all experiment data for eda
eda_exp = eda_raw(index_of_experiment_start_eda:end,:);
time_eda_exp = (eda_exp(:,1)- eda_exp(1,1))/1000;

%get list of SCR events above SCR cutoff for each trial in anticipatory and
%video period
[anticipation_scr,video_scr] = GetSCREvents(subject_code, raw_data_dir, 'experiment',...
                                            eda_exp(:,2), time_eda_exp, log_file.data, SCR_Cut_Off);

%get list of resp, hp, hrv for anticipation and video portions
[resp_anticipation, hrv_anticipation,...
 heart_period_anticipation, resp_video,...
 hrv_video, heart_period_video] = GetEcgAndRespMeasures(...
                                          subject_code, raw_data_dir, resp_ecg_data_exp,...
                                           time_ecg_exp, log_file.data);
%conglomerate data
log_file.data(:,20:27) = [resp_anticipation, hrv_anticipation,...
                            heart_period_anticipation, anticipation_scr...
                            resp_video, hrv_video, heart_period_video,video_scr];
%write data to file
CreateLogFileWithPhysio(subject_code,log_file,baseline_resp,baseline_hrv, baseline_hp, baseline_eda);




