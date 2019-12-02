function [hrv] = CalculateHRV(ibis_in_interval)
    mean_ibis_squared = mean(ibis_in_interval.^2);
    hrv = sqrt(mean_ibis_squared);
end

