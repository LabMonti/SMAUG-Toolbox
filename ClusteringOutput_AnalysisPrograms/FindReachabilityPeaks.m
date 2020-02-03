function [peak_indices, peak_values] = FindReachabilityPeaks(RD, cutoff_fraction)

    tic;

    N = length(RD);
    min_valley_length = ceil(N*cutoff_fraction);

    %First, find locations of all peaks of any sort
    all_peaks = zeros(N - 2*min_valley_length, 1);
    counter = 0;
    for i = min_valley_length+1:N-min_valley_length
        if RD(i-1) <= RD(i) && RD(i+1) < RD(i)
            counter = counter + 1;
            all_peaks(counter) = i;
        end
    end
    all_peaks = all_peaks(1:counter);
    N2 = length(all_peaks);
    
    %Next, keep only the peaks that are followed by a valley of at least
    %minimum length
    peaks_next = zeros(N2, 1);
    counter = 0;
    for i = 1:N2
        index = all_peaks(i);
        value = RD(index);
        valley = true;
        j = 1;
        
        %See if valley extends at least min_vally_length
        while valley && j <= min_valley_length
            if RD(index + j) > value
                valley = false;
            end
            j = j + 1;
        end
        
        %If so, keep peak
        if j > min_valley_length
            counter = counter + 1;
            peaks_next(counter) = index;            
        end
        
    end
    peaks_next = peaks_next(1:counter);
    N3 = length(peaks_next);
        
    %Finally, only keep peaks that are PRECEEDED by a valley of at least 
    %min_valley_length length 
    peak_indices = zeros(N2, 1);
    counter = 0;
    for i = 1:N3
        index = peaks_next(i);
        value = RD(index);
        valley = true;
        j = 1;
        
        %See if valley extends at least min_vally_length
        while valley && j <= min_valley_length
            if RD(index - j) > value
                valley = false;
            end
            j = j + 1;
        end
        
        %If so, keep peak
        if j > min_valley_length
            counter = counter + 1;
            peak_indices(counter) = index;            
        end
        
    end
    peak_indices = peak_indices(1:counter);
    peak_values = RD(peak_indices);


end