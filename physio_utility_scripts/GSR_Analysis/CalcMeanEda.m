function [mean_eda] = CalcMeanEda(time,eda, start_time, end_time)
    logic_index_time = time > (start_time+1) & time < (end_time+1);
    eda_in_period = eda(logic_index_time);
    mean_eda = mean(eda_in_period);
end

