%GetPeaksTest
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/ECG_Data_Analysis');
ecg_signal = [1 1 1 1 1 2 1 1 1 1 1 2 1 1 1 1 1 2 1 1];
time = linspace(1, length(ecg_signal), length(ecg_signal));

%%Test 1: valid - 3 peaks 2 ibis = 5 long interval no suspects
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, 4, 6);
assert(numel(r_spikes)==3);
assert(ibi(1) == 6);
assert(ibi(2) == 6);
assert(peak_times(1)==6);
assert(peak_times(2)==12);
assert(numel(suspect_peak_times) == 0);

%%Test 2: invalid - 3 peaks 2 peaks are too close together
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, 10, 15);
assert(numel(suspect_peak_times)==2);

%%Test 3: invalid - 3 peaks 2 peaks are too far apart
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, .5, 1.5);
assert(numel(suspect_peak_times)==2);