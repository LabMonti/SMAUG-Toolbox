%NDB 24Jun19: Finds the clustering solution with a cluster that
%best-matches a given reference cluster
function [extraction_epsilons, solution_numbers, cluster_numbers] = ...
    MatchSpecificClusterValley(OutputList, RefID, RefPeakID, RefClustID, ...
    cutoff_frac)

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