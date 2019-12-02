% Visualize ecg
%get paths for data files TODO: make a method
clear
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/data_loaders');
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/Load_Files_Convert_Timing');
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/ECG_Data_Analysis');


subject_code_str = input('Enter subject code: ','s');
ecg_file = dir(sprintf('../../shimmer_data/*_%s_*/*_CA2*',subject_code_str));
ecg_file_path =sprintf('%s/%s', ecg_file.folder,ecg_file.name);
ecg_raw = LoadConsensysData(ecg_file_path, ["Unix","LA-RA"]);

log_file_dir = dir(sprintf('../../shimmer_data/*_%s_*/*log*',subject_code_str));
log_file_path =sprintf('%s/%s', log_file_dir.folder,log_file_dir.name);

delimiter = ' ';
lines_in = 1;
log_file = importdata(log_file_path, delimiter, lines_in);

unix_exp_start = GetExpStartUnix(log_file);
index_of_experiment_start_ecg = find(unix_exp_start<= ecg_raw(:,1)/1000,1);

ecg_exp = ecg_raw(index_of_experiment_start_ecg:end,:);
time_ecg_exp = (ecg_exp(:,1)- ecg_exp(1,1))/1000;

max_y = max(ecg_exp(:,2));
min_y = min(ecg_exp(:,2));

clf;
hold on
ShadeTrials(log_file.data(:,[4 5 10 11]), min_y, max_y);
plot(time_ecg_exp, ecg_exp(:,2));


