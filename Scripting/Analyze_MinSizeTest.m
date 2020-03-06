%Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
%licensed under the Creative Commons Attribution-NonCommercial 4.0 
%International License. To view a copy of this license, visit 
%http://creativecommons.org/licenses/by-nc/4.0/.  

%Script for analyzing the results of the test in which the same dataset was
%re-clustered using several different values for the minSize parameter
function ResultStruct = Analyze_MinSizeTest(OO_List, TracesUsed, ...
    cutoff_frac, refOutputID, refSolnID, refClustID)

    %Get list of minSize values used
    N = length(OO_List);
    minSize_List = zeros(N,1);
    for i = 1:N
        minSize_List(i) = OO_List{i}.ClusteringInputParameters.minSize;
    end
    
    %Get all the conductance peak values
    [peaks, errors, halfwidths] = Standard_ProcessSegClust_Peaks(OO_List,...
        TracesUsed,cutoff_frac,refOutputID,refSolnID,refClustID,2);
    
    %Now we need to find the Rand similarity indices; first, get the 
    %cluster assignments for the reference cluster   
    OOref = OO_List{refOutputID};
    [~,eps] = FindReachabilityPeaks(OOref.RD,cutoff_frac);
    eps = unique(eps);
    [Yref,Tref] = ExtractClusterSolution(OOref.RD,OOref.CD,eps(refSolnID),cutoff_frac);
    Yref = reassign_cluster_labels(Yref,Tref);
    [~,neworder] = sort(OOref.order);
    Yref = Yref(neworder);

    %Next, find the extraction levels for the most-similar solutions:
    matching_eps = MatchSpecificClusterValley(OO_List,refOutputID,refSolnID,refClustID,cutoff_frac);

    %And now find the matching solution from each output and find its rand
    %similarity index with the reference output
    RandIndices = zeros(N,1);
    for i = 1:N
        OO = OO_List{i};
        [Y,T] = ExtractClusterSolution(OO.RD,OO.CD,matching_eps(i),cutoff_frac);
        Y = reassign_cluster_labels(Y,T);
        [~,neworder] = sort(OO.order);
        Y = Y(neworder);

        RandIndices(i) = RandSimilarityIndex(Y,Yref);
    end
    
    ResultStruct = struct();
    ResultStruct.minSize_List = minSize_List;
    ResultStruct.peaks = peaks;
    ResultStruct.errors = errors;
    ResultStruct.halfwidths = halfwidths;
    ResultStruct.RandIndices = RandIndices;

end