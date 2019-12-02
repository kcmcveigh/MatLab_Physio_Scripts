%function converts the start time in the affvids log file
%to a unix time stamp
%shimmers time is five hours ahead of matlab
function [exp_start_time_unix] = GetExpStartUnix(log_file)
    first_row = log_file.textdata{1};
    first_row_array = strsplit(first_row);
    %get date num from log file - assumption is that exp start it is the
    %last thing in the header row
    date_num = str2num(first_row_array{end});
    %time is given in etc
    time_est = datetime(date_num, 'ConvertFrom', 'datenum');
    %convert to utc
    time_utc = time_est + hours(4);
    %convert to unix and return
    exp_start_time_unix = posixtime(time_utc);
end
    