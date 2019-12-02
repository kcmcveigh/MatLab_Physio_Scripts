%get all log files
clear
folder = "log_files_w_physio";
files = dir(sprintf('%s/log*',folder));
%create master file
fid = fopen('master_file_20191121_5.txt','w');
%for first file get header
initial_file = importdata(sprintf('%s/%s', folder, files(1).name));
header = initial_file.textdata(1,:);
fprintf(fid,'%s ',header{:});
fprintf(fid,'\n');
%for each log file load data and add to master array
num_files = length(files);
for file=2:num_files
    log_file = importdata(sprintf('%s/%s', folder, files(file).name));
    disp(length(log_file.data(:,1)))
    for i = 1:length(log_file.data(:,1))
        %plus one for text data because header of log file is included in text
        %data and is the first row so we want to skip that
        %'video', 'video_condition', 'im_condition', 'pred_val'
        fprintf(fid,'%s %1.3f %1.3f %1.3f ', log_file.textdata{i+1}, log_file.data(i,1:3));
        %'word_start', 'word_end', 'resp_exp_fear', 'rt_exp_fear', 'resp_current_anxiety', 'rt_current_anxiety'
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f %1.3f %1.3f ', log_file.data(i,4:9));
        %'video_start','video_end','resp_fear','resp_anxiety','resp_arousal', 'resp_valence'
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f %1.3f %1.3f ', log_file.data(i,10:15));
        %'rt_fear', 'rt_anxiety', 'rt_arousal','rt_valence'
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f ', log_file.data(i,16:19));
        %anticipation_respiration', 'anticipation_hrv','anticipation_hp','anticipation_scr_events
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f ', log_file.data(i,20:23));
        %video_respiration', 'video_hrv', 'video_hp', 'video_scr
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f %1.3f ', log_file.data(i,24:28));
        %'hp_video_ratings', 'hp_isi', 'resp_video_ratings', 'resp_isi'
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f ', log_file.data(i,29:32));
        %'rating_scr_events', 'isi_scr_events', 'participant_num'
        fprintf(fid, '%1.3f %1.3f %1.3f', log_file.data(i,33:34));
        %'hp_base_anticipation', 'resp_base_anticipation', 'hp_base_videos', 'resp_base_videos'
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f ', log_file.data(i,35:38));
        %base_resp, base_hp, base_SCR, 
        fprintf(fid, '%1.3f %1.3f %1.3f %1.3f', log_file.data(i,39:42));
        %next line
        fprintf(fid,'\n');
    end
end

%save