function visualizeGsrData(filename)
    data = importdata(filename);
    headers = data.colheaders;
    gsr_data = data.data;
    %assume that time is column 
    time = gsr_data(:,1);
    %assume GSR is column 2
    gsr = gsr_data(:,2);
    
    plot(time,gsr)
    title('GSR vs Time')
    xlabel('time (sec)')
    ylabel('GSR uS')
end

    
    