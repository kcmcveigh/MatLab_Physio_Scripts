clear
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/Load_Files_Convert_Timing');

subject_code_str = "107";%input('Enter subject code: ','s');
subject_code = str2num(subject_code_str);

%%load log file
log_file_dir = dir(sprintf('../../shimmer_data/*_%s_*/*log*',subject_code_str));
log_file_path =sprintf('%s/%s', log_file_dir.folder,log_file_dir.name);
delimiter = ' ';
lines_in = 1;
log_file = importdata(log_file_path, delimiter, lines_in);
log_data=log_file.data;

subject_peak_dir = sprintf('../Pipelines/raw_peaks/%s/*', subject_code_str);
peak_files = dir(subject_peak_dir);
peak_dir = peak_files(1).folder;

ecg_exp_path = strcat(peak_dir,'/',subject_code_str,'_exp_ecg_peak_times');
exp_ecg = csvread(ecg_exp_path);

HP = diff(exp_ecg(:,1));
min_y = min(HP);
max_y = max(HP)
hold on
ShadeTrials(log_file.data(:,[4 5 10 11]), min_y, max_y);
plot(exp_ecg(2:end,1),HP);