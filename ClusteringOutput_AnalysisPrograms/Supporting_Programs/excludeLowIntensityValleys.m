function [valley_bounds, valley_tops] = excludeLowIntensityValleys(...
    counts, valley_bounds, valley_tops)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: In accordance with Ben's paper, for histogram
    %clustering results this program takes a list of maximum cluster
    %valleys and removes all those consisting ONLY those valleys that
    %only contain bins with counts of <= 5.  
    %
    %~~~INPUTS~~~:
    %
    %counts: list of bin counts for each clustered points, in the same
    %   order as the reachability plot
    %
    %valley_bounds: a two-column matrix indicating the starting and ending
    %   indices for each valley in the cluster order
    %
    %valley_tops: the extraction level that aligns with the very top of
    %   each valley, which can be used to extrat each "maximum valley
    %   cluster"
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %valley_bounds/valley_tops: same as inputs, but with valleys 
    %   corresponding to low-intensity points removed
    
    
    n = length(valley_tops);
    keep = true(n,1);
    for i = 1:n
        clust_counts = counts(valley_bounds(i,1):valley_bounds(i,2));
        if ~any(clust_counts > 5)
            keep(i) = false;
        end
    end
    valley_tops = valley_tops(keep);
    valley_bounds = valley_bounds(keep,:);
    
end