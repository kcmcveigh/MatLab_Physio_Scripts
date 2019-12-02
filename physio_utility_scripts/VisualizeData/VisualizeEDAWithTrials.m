% Visualize eda
%get paths for data files TODO: make a method
clear
addpath('../data_loaders');
addpath('../Load_Files_Convert_Timing');
addpath('../GSR_Analysis');

eda_event_cutoff = 1;

cur_dir = pwd;
raw_data_dir = sprintf("%s/test_datum",cur_dir);

subject_code_str = input('Enter subject code: ','s');
eda_file = dir(sprintf('../../shimmer_data/*_%s_*/*_89*',subject_code_str));
eda_file_path =sprintf('%s/%s', eda_file.folder,eda_file.name);
eda_raw = LoadConsensysData(eda_file_path, ["Unix","Conductance"]);

log_file_dir = dir(sprintf('../../shimmer_data/*_%s_*/*log*',subject_code_str));
log_file_path =sprintf('%s/%s', log_file_dir.folder,log_file_dir.name);

delimiter = ' ';
lines_in = 1;
log_file = importdata(log_file_path, delimiter, lines_in);

unix_exp_start = GetExpStartUnix(log_file);
index_of_experiment_start_eda = find(unix_exp_start<= eda_raw(:,1)/1000,1);

eda_exp = eda_raw(index_of_experiment_start_eda:end,:);
time_eda_exp = (eda_exp(:,1)- eda_exp(1,1))/1000;

[peak_EDA_percent,peak_time_sec, clean_eda, peak_EDA_uS] = CleanSCRandFindPeaks(eda_exp(:,2), time_eda_exp);
valid_peaks = find(peak_EDA_percent>eda_event_cutoff);

y_min = min(eda_exp(:,2));
y_max = max(eda_exp(:,2));

clf;
hold on
ShadeTrials(log_file.data(:,[4 5 10 11]), y_min, y_max);
plot(time_eda_exp, clean_eda);
hold on
plot(peak_time_sec,peak_EDA_uS,'rs');
hold off



