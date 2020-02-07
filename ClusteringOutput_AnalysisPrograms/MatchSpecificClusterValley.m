%NDB 24Jun19: Finds the clustering solution with a cluster that
%best-matches a given reference cluster
function [extraction_epsilons, solution_numbers, cluster_numbers] = ...
    MatchSpecificClusterValley(OutputList, RefID, RefPeakID, RefClustID, ...
    cutoff_frac)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a list of clustering outputs, finds the
    %full-valley cluster in each output that best-matches one specified
    %full-valey cluster
    %
    %~~~INPUTS~~~:
    %
    %OutputList: a cell-array containing a list of clustering output
    %   structures
    %
    %RefID: the ID# of the output in OutputList that contains the reference
    %   cluster the user wishes to match
    %
    %RefPeakID: the ID# of the clustering solution that the reference
    %   cluster belongs to (i.e. how many extraction levels it is up from
    %   the bottom when finding all extraction peaks at a given cut-off
    %   fraction)
    %
    %RefClustID: the cluster # of the reference cluster (i.e. which valley
    %   the cluster corresponds to, counting left to right)
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
    %extraction_epsilons: a vector containing the extraction level for each
    %   clustering output that produces the solution containing the
    %   closest-matching cluster
    %
    %solution_numbers: the ID# for each of the extraction epsilons
    %   (counting up extraction levels from all for a given cutoff
    %   fraction)
    %
    %cluster_numbers: the cluster number for each clustering solution that
    %   refers to the best-matching cluster
    
    
    Nout = length(OutputList);
    extraction_epsilons = zeros(Nout,1);
    cluster_numbers = zeros(Nout,1);
    solution_numbers = zeros(Nout,1);
    
    %Find the centroid of the reference cluster
    OOref = OutputList{RefID};
    [~,peaks] = FindReachabilityPeaks(OOref.RD,cutoff_frac);
    peaks = unique(peaks);
    RefCentroid = FindCluster_Centroids(OOref,peaks(RefPeakID),cutoff_frac);
    RefCentroid = RefCentroid(RefClustID,:);

    %Loop over each clustering output to find its best-matching cluster to
    %the reference cluster
    for i = 1:Nout
        
        %Get next clustering output and find all of its valleys
        OO = OutputList{i};
        [valley_bounds, epsilons] = Find_ReachabilityValleys(OO.RD, cutoff_frac);
        nValleys = length(epsilons);
        [soln_nums,clust_nums] = assign_SolnNum_and_ClustNum_ToValleys(valley_bounds,...
            epsilons,OO.RD,OO.CD,cutoff_frac);
        
        %Find the centroids of the clusters corresponding to each valley
        Xraw = OO.Xraw;
        Xraw = Xraw(OO.order,:);
        n_dim = size(Xraw,2);
        centroids = zeros(nValleys, n_dim);
        for j = 1:nValleys
            centroids(j,:) = median(Xraw(valley_bounds(j,1):valley_bounds(j,2),:));
        end
        
        %Find which cluster has the closest centroid to the reference
        %cluster
        dists = pdist2(centroids, RefCentroid);
        [~,minIndex] = min(dists);
        
        %Save the clustering solution that the best-matching cluster
        %belongs to
        extraction_epsilons(i) = epsilons(minIndex);
        cluster_numbers(i) = clust_nums(minIndex);
        solution_numbers(i) = soln_nums(minIndex);
        
    end
    
end