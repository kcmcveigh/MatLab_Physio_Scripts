
file_name = 'AffVids_logfile_2.txt';
exp_start_time = GetExpStartUnix('AffVids_logfile_2.txt');
shimmer_data = readtable('../../shimmer_data/GSRh2h_Session2_Shimmer_89B8_Calibrated_PC.csv');
shimmer_time = shimmer_data.Shimmer_89B8_TimestampSync_Unix_CAL;
shimmer_time_length = length(shimmer_time);
for i = 2:shimmer_time_length
    time_in_ms = str2double(shimmer_time{i})/1e3;
    adjusted_for_exp_start_time = time_in_ms - exp_start_time;
    shimmer_data.Shimmer_89B8_TimestampSync_Unix_CAL{i} = adjusted_for_exp_start_time;
end
