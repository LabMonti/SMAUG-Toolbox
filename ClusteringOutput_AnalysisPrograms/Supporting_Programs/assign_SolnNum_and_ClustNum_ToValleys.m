function [soln_nums, clust_nums] = ...
    assign_SolnNum_and_ClustNum_ToValleys(valley_bounds, valley_tops, ...
    RD, CD, cutoff_frac)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given information about some "maximum valleys" 
    %from a reachability plot, this function finds the solution number and
    %cluster number that correspond to each of these valleys
    %
    %~~~INPUTS~~~:
    %
    %valley_bounds: a two-column matrix indicating the starting and ending
    %   indices for each valley in the cluster order
    %
    %valley_tops: the extraction level that aligns with the very top of
    %   each valley, which can be used to extrat each "maximum valley
    %   cluster"
    %
    %RD: column vector of reachability distances for each data point (in
    %   the order of the cluster order)
    %
    %CD: column vector of core distances for each data point (in the order
    %   of the cluster order)
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
    %soln_nums: the solution #s (i.e., the number of the extraction level,
    %   counting up from low to high and only counting extraction levels at
    %   peaks separating valleys of at least cutoff_frac size) for each
    %   valley
    %
    %clust_nums: the cluster #s (i.e., the number of the valley counting
    %   from left to right) for each valley
    

    n = length(valley_tops);
    soln_nums = zeros(n,1);
    clust_nums = zeros(n,1);
    
    extraction_levels = unique(valley_tops);
    
    for i = 1:n
        
        %Find solution number by finding the order of the valley top in the
        %list of unique valley tops
        soln_nums(i) = find(extraction_levels == valley_tops(i));
        
        %Find the cluster number by finding the cluster ID assigned to a
        %point from the middle of the cluster
        [Y,~] = ExtractClusterSolution(RD,CD,valley_tops(i),cutoff_frac);
        test_point = round((valley_bounds(i,2) + valley_bounds(i,1))/2);
        clust_nums(i) = Y(test_point);
        
    end

end