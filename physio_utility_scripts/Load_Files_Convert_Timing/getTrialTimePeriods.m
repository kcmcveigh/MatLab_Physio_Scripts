function [trial_time_periods, video_names_in_order] = getTrialTimePeriods(filename)
    delimiterIn = ' ';
    headerlinesIn = 1;
    subject_file = importdata(filename,delimiterIn,headerlinesIn);
    %first column we re-assign to the name
    %4-5 word onset and offset
    %8:9 video onset and offset
    trial_time_periods = subject_file.data(:,[4:5,8:9]);
    number_of_trials = length(subject_file.textdata(:,1));
    video_names_in_order = subject_file.textdata(2:number_of_trials,1);    
end

