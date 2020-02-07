%28May18 NDB: In accordance with Ben's paper, for histogram clustering
%results this program finds clusters in which ALL the data points
%correspond to bins with counts less than or equal to 5, and re-assigns
%these clusters to the noise cluster
function [valley_bounds, valley_tops] = excludeLowIntensityValleys(...
    counts, valley_bounds, valley_tops)
    %~~~INPUTS~~~:
    %
    
    
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