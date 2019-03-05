%GetECGMeasuresTest
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/ECG_Data_Analysis');
%create fake data for ibi - at this point interval itself doesn't matter
%should've already been screened out
ibi_first_50 = ones(50,1);
%arbitrary peaks times until define start and end
peak_times = linspace(1,50,50);
%suspect peak indices
suspect_peak_indices = [5, 9, 17, 18, 38, 39, 40];

%%Test One: Valid - start and end time don't contain any suspect indices
%start time and end time 20,30 don't contain any suspect indices or
%adjacent indices
 [hrv,heart_period] = GetECGMeasures(20,30,peak_times,ibi_first_50,suspect_peak_indices);
 assert(~isnan(hrv));
 assert(~isnan(heart_period));
 %%Test Two: Invalid interval contains suspect peak indices
 [hrv,heart_period] = GetECGMeasures(18,30,peak_times,ibi_first_50,suspect_peak_indices);
 assert(isnan(hrv));
 assert(isnan(heart_period));
 %%Test Three: Invalid interval adjacent suspect peak indices - low
 [hrv,heart_period] = GetECGMeasures(19,30,peak_times,ibi_first_50,suspect_peak_indices);
 assert(isnan(hrv));
 assert(isnan(heart_period));
 %%Test four: Invalid interval adjacent suspect peak indices - high
 [hrv,heart_period] = GetECGMeasures(20,37,peak_times,ibi_first_50,suspect_peak_indices);
 assert(isnan(hrv));
 assert(isnan(heart_period));
 %%Test 5: assert that getting right IBI ie one less then peak times