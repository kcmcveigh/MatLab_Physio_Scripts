%%test filtering
test_data_path = 'test_data/RESP_ECG.csv';
respiration_ecg = importdata(test_data_path);
resp_ecg_data= respiration_ecg.data;
time_ecg =  resp_ecg_data(:,1)/1000;
time_ecg = time_ecg - time_ecg(1);
respiration =resp_ecg_data(:,2);
sampling_rate = 256;
Hd = designfilt('lowpassfir','FilterOrder',20,'CutoffFrequency',50, ...
       'DesignMethod','window','Window',{@kaiser,6},'SampleRate',1000);
y1 =filter(Hd,respiration);
[peaks, peak_times,ibi,suspect_peak_indices]= GetPeaks(y1,time_ecg, .03, ...
            .5, 10);
        
        plot(time_ecg,y1)'
        hold on
        plot(time_ecg,respiration);
        plot(peak_times, peaks, 'rs');
        hold off
        
        suspect_peak_times = peak_times(suspect_peak_indices);
        fprintf('peaks (times) that are either too close together or too far appart\n')
        disp(suspect_peak_times);