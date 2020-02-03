function centroids = FindCluster_Centroids(OutputStruct, eps, cutoff_frac)

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