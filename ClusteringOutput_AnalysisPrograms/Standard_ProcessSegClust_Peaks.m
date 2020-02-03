%NDB 18Jun19: Given a set of different clustering outputs for the same data
%set and a particular cluster from one of them, find that same cluster in
%the rest and fit the conductances of the segments belonging to it
function [peaks, peak_errors, peak_halfwidths] = ...
    Standard_ProcessSegClust_Peaks(OO_List, TracesUsed, cutoff_frac, ...
    ref_outputID, ref_solID, ref_clustID, ToPlot)

    if nargin < 7
        ToPlot = false;
    end

    Nout = length(OO_List);
    peaks = zeros(Nout,1);
    peak_errors = zeros(Nout,1);
    peak_halfwidths = zeros(Nout,1);    
    
    %Find the peaks at which to extract each clustering output, and which 
    %of the clusters matched the best:
    [extraction_eps, ~, clust_nums] = MatchSpecificClusterValley(OO_List,ref_outputID,...
       ref_solID,ref_clustID,cutoff_frac);
    
    for i = 1:Nout
        disp([i Nout]);
        
        plot_now = false;
        if ToPlot == 2
            plot_now = true;
        elseif ToPlot == 1
            if i == ref_outputID
                plot_now = true;
            end
        end
        
        %Make 1D histogram for chosen cluster
        OO = OO_List{i};
        OO.TracesUsed = TracesUsed;
        [peaks(i),peak_errors(i),peak_halfwidths(i)] = SegmentCluster_to_1DHist(...
            OO,extraction_eps(i),cutoff_frac,clust_nums(i),plot_now);   
    end

end