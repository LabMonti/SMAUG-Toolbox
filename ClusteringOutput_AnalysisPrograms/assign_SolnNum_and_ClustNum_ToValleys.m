%NDB 13Nov19: Given information about some "maximum valleys" from a
%reachability plot, this function finds the solution number and cluster
%number that correspond to each of these valleys
function [soln_nums, clust_nums] = ...
    assign_SolnNum_and_ClustNum_ToValleys(valley_bounds, valley_tops, ...
    RD, CD, cutoff_frac)


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