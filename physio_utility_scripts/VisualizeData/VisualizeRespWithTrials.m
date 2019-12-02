% Visualize respiration
%get paths for data files TODO: make a method
clear
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/data_loaders');
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/Load_Files_Convert_Timing');


subject_code_str = input('Enter subject code: ','s');
respiration_file = dir(sprintf('../../shimmer_data/*_%s_*/*_CA2*',subject_code_str));
respiration_file_path =sprintf('%s/%s', respiration_file.folder,respiration_file.name);
respiration_raw = LoadConsensysData(respiration_file_path, ["Unix","RESP"]);

log_file_dir = dir(sprintf('../../shimmer_data/*_%s_*/*log*',subject_code_str));
log_file_path =sprintf('%s/%s', log_file_dir.folder,log_file_dir.name);

delimiter = ' ';
lines_in = 1;
log_file = importdata(log_file_path, delimiter, lines_in);

unix_exp_start = GetExpStartUnix(log_file);
index_of_experiment_start_respiration = find(unix_exp_start<= respiration_raw(:,1)/1000,1);

respiration_exp = respiration_raw(index_of_experiment_start_respiration:end,:);
time_respiration_exp = (respiration_exp(:,1)- respiration_exp(1,1))/1000;

resp_data=respiration_exp(:,2);

smoothed = smooth(resp_data, 256, 'moving');

max_y = max(smoothed);
min_y = min(smoothed);

clf;
hold on
ShadeTrials(log_file.data(:,[4 5 10 11]), min_y, max_y);
plot(time_respiration_exp, smoothed);