%assumes hold on == true
function ShadeTrials(trial_times, y_min, y_max)
    for i = 1:length(trial_times(:,1))
        trial = trial_times(i,:);
        word_on = trial(1);
        word_off = trial(2);
        video_start = trial(3);
        video_off = trial(4);
        
        %plot word period
        fill_word = fill([word_on word_off word_off word_on], [y_min y_min y_max y_max], 'g');
        set(fill_word,'facealpha',.5);
        %plot video period
        fill_video=fill([video_start video_off video_off video_start], [y_min y_min y_max y_max], 'r');
        set(fill_video,'facealpha',.5);
    end
end

