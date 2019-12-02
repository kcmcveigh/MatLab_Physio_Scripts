%GetPeaksTest
clear
addpath('/Users/phoenix/Desktop/Matlab/Physio_Data_Analysis/physio_utility_scripts/ECG_Data_Analysis');
ecg_signal = [1; 1; 1; 1; 1;2; 1; 1; 1; 1; 1; 2; 1; 1; 1; 1; 1; 2; 1; 1];
time(:,1) = linspace(1, length(ecg_signal), length(ecg_signal));
manual_peaks = [];
excluded_peaks=[];
%%Test 1: valid - 3 peaks 2 ibis = 5 long interval no suspects
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time,...
                                                        .8, 4, 6, manual_peaks, excluded_peaks);
assert(numel(r_spikes)==3);
assert(ibi(1) == 6);
assert(ibi(2) == 6);
assert(peak_times(1)==6);
assert(peak_times(2)==12);
assert(numel(suspect_peak_times) == 0);

%%Test 2: invalid - 3 peaks 2 peaks are too close together
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, 10, 15, manual_peaks, excluded_peaks);
disp(suspect_peak_times)
disp(ibi)
assert(numel(suspect_peak_times)==2);

%%Test 3: invalid - 3 peaks 2 peaks are too far apart
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, .5, 1.5, manual_peaks, excluded_peaks);
assert(numel(suspect_peak_times)==2);

%%TEST 4: Insert Manual peak - no supect peaks
manual_peaks(1)=9;
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, 3, 8, manual_peaks, excluded_peaks);
assert(numel(peak_times)==4);
assert(numel(suspect_peak_times)==0);
%%TEST 5: Insert Manual peak - suspect peak
manual_peaks(1)=9;
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, 3, 5, manual_peaks, excluded_peaks);
assert(numel(peak_times)==4);
assert(numel(suspect_peak_times)==1);
%%TEST 5: Insert excluded peaks test
manual_peaks=[];
excluded_peaks = [4];
[r_spikes,peak_times,ibi, suspect_peak_times] = GetPeaks(ecg_signal, time, .8, .5, 1.5, manual_peaks, excluded_peaks);
assert(numel(suspect_peak_times)==3);

