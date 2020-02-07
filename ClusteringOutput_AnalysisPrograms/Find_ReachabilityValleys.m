function [valley_bounds, valley_tops] = Find_ReachabilityValleys(RD, ...
    cutoff_fraction)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Finds all valleys in reachability plot that 
    %exceed the specified fraction of all data points
    %
    %~~~INPUTS~~~:
    %
    %RD: column vector of reachability distances for each data point (in
    %   the order of the cluster order)
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %valley_bounds: a two-column matrix indicating the starting and ending
    %   indices for each valley in the cluster order
    %
    %valley_tops: the extraction level that aligns with the very top of
    %   each valley, which can be used to extrat each "maximum valley
    %   cluster"
    
    
    N = length(RD);
    min_valley_length = ceil(N*cutoff_fraction);

    %First, find locations of all significant peaks
    [all_peaks,~] = FindReachabilityPeaks(RD,cutoff_fraction);
    Npeaks = length(all_peaks);
    
    %For each peak, see if the preceeding valley is long enough to keep
    preceeding_valleys = zeros(Npeaks,3);
    counter = 0;
    for i = 1:Npeaks
        j = all_peaks(i);
        alt = RD(j);
        
        %We know that the peak itself DOESN'T belong to the valley, so move
        %on and don't count it
        j = j - 1;
        valley_size = 0;
        
        %Keep going backwards until we exceed the altitude of the peak
        while RD(j) <= alt
            valley_size = valley_size + 1;
            j = j - 1;
        end
        
        %The first point to the left at greater altitude belongs to this
        %valley (it is it's preceeding "peak")
        valley_size = valley_size + 1;
        
        %If valley is long enough to keep, store the first and last indices
        %that belong in the valley and the valley's maximum altitude
        if valley_size >= min_valley_length
            counter = counter + 1;
            preceeding_valleys(counter,1) = j;
            preceeding_valleys(counter,2) = all_peaks(i) - 1;   
            preceeding_valleys(counter,3) = alt;
        end
    end
    preceeding_valleys = preceeding_valleys(1:counter,:);

    %For each peak, see if the following valley is long enough to keep
    following_valleys = zeros(Npeaks,3);
    counter = 0;
    for i = 1:Npeaks
        j = all_peaks(i);
        alt = RD(j);
        
        %We know that the peak itself belongs to the valley, so move on and
        %start with one point in the valley
        j = j + 1;
        valley_size = 1;
        
        %Keep going forwards until we exceed the altitude of the peak OR
        %reach the end; no equal to here because a peak at the END of a 
        %valley does not belong to it
        while RD(j) < alt && j < N
            valley_size = valley_size + 1;
            j = j + 1;
        end
        if j == N
            j = j + 1;
        end
        
        %If valley is long enough to keep, store the first and last indices
        %that belong in the valley and the valley's maximum altitude
        if valley_size >= min_valley_length
            counter = counter + 1;
            following_valleys(counter,1) = all_peaks(i);
            following_valleys(counter,2) = j - 1;   
            following_valleys(counter,3) = alt;
        end
    end
    following_valleys = following_valleys(1:counter,:);
    
    %Combine valleys, remove duplicates:
    all_valleys = [preceeding_valleys; following_valleys];
    all_valleys = unique(all_valleys,'rows');
    
    valley_bounds = all_valleys(:,1:2);
    valley_tops = all_valleys(:,3);
    
%     figure();
%     plot(RD);
%     hold on;
%     for index = 1:length(all_valleys)
%         plot((all_valleys(index,1):all_valleys(index,2))',...
%             RD(all_valleys(index,1):all_valleys(index,2))+index*0.01);
%     end

end