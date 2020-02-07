function centroids = FindCluster_Centroids(OutputStruct, eps, cutoff_frac)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Find the "median centroid" of each cluster at a
    %given extraction level, i.e. the median of all points belonging to the
    %cluster along each dimension
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %eps: the value of epsilon at which extraction takes place; clusters
    %   will be valleys that exist below this cut-off value in the
    %   reachability plot
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
    %centroids: the median of each cluster along each of the dimensions
    %   used for clustering.  Un-normalized data is used by this function. 
    
    
    [Y,T,~] = ExtractClusterSolution(OutputStruct.RD, OutputStruct.CD,...
        eps, cutoff_frac);
    
    %# of non-noise clusters
    nClust = size(T,1) - 1;

    nDim = size(OutputStruct.Xraw,2);
    centroids = zeros(nClust, nDim);
    
    %Put raw data in same order as Y
    Xraw = OutputStruct.Xraw(OutputStruct.order,:);
    
    %Calculate median of each dimension for all objects in cluster
    for i = 1:nClust
        centroids(i,:) = median(Xraw(Y == i, :));
    end

end