function [SizeArray, SizeTable] = GetPopulationTables(Y)

    clustID = unique(Y);
    %If there are no noise points, still add an extra row to the size
    %tables for the noise cluster
    if clustID(1) > 0
        nClust = length(clustID) + 1;
    else
        nClust = length(clustID);
    end
    
    SizeArray = zeros(nClust, 3);
    SizeArray(2:nClust,1) = (1:nClust-1);
    
    %Get # of points in each cluster
    N = length(Y);
    for i = 1:N
        SizeArray(Y(i) + 1, 2) = SizeArray(Y(i) + 1, 2) + 1;
    end
    
    %Get population of each cluster as fraction of total points
    TotPoints = sum(SizeArray(:,2));
    for i = 1:nClust
        SizeArray(i,3) = SizeArray(i,2) / TotPoints;
    end
    
   SizeTable = array2table(SizeArray,'VariableNames',...
       {'Cluster_ID','Points_in_Cluster','Fraction_Points_in_Cluster'});


end