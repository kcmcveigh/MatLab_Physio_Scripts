function [EDA_datum_valid, data_EDA_uS_filtered] = run_automated_EDAQA( ...
    data_EDA_uS, data_time_sec, data_temperature_C, ... % Input data
    QA_filter_window_EDA_sec, ... % Filter 
    QA_EDA_floor, QA_EDA_ceiling, ... % Rule 1
    QA_EDA_max_slope_uS_per_sec, ... % Rule 2
    QA_temperature_C_min, QA_temperature_C_max, ... % Rule 3
    QA_radius_to_spread_invalid_datum_sec ) % Rule 4
% place holder see https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5880745/ for actual code
end
