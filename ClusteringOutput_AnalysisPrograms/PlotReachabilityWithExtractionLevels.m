function PlotReachabilityWithExtractionLevels(OutputStruct, cutoff_fraction)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: plots a reachability plot with all "significant"
    %extraction levels overlaid, i.e. those at peaks that separate valleys
    %of at least cutoff_fraction size
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster
    
    
    RD = OutputStruct.RD;
    
    [~, peak_values] = FindReachabilityPeaks(RD, cutoff_fraction);
    
    figure();
    plot(RD);
    hold on;
    for i = 1:length(peak_values)
        plot([0 length(RD)], [peak_values(i) peak_values(i)]);
    end    
    disp(length(peak_values));
    hold off;
    xlabel('Cluster Order');
    ylabel('Reachability Distance');

end