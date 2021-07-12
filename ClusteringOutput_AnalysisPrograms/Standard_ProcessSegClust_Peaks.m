function [peaks, peak_errors, peak_halfwidths, cond_medians] = ...
    Standard_ProcessSegClust_Peaks(OO_List, TracesUsed, cutoff_frac, ...
    ref_outputID, ref_solID, ref_clustID, ToPlot, nPeaksPerPlot)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a set of different segment clustering
    %outputs for the same data set and a particular cluster from one of 
    %them, find that same cluster in the rest and fit the conductances of
    %the segments belonging to it
    %
    %~~~INPUTS~~~:
    %
    %OO_List: a cell array containing segment clustering output structures
    %   for the same dataset clustered using different parameters
    %
    %TracesUsed: the "TracesUsed" field that belongs to each clustering
    %   output
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster
    %
    %ref_outputID: the ID# for which output in OO_List contains the
    %   reference cluster
    %
    %ref_solID: the ID# for the extraction level/clustering solution that
    %   the reference cluster belongs to
    %
    %ref_clustID: the cluster # of the reference cluster in its respective
    %   solution and output
    %
    %ToPlot: if equal to 0/false, no plot are made; if equal to 1/true, a
    %   1D histogram is made only for the reference cluster; if equal to 2,
    %   a 1D histogram is made for the cluster from each output that got
    %   matched to the reference cluster
    %
    %nPeaksPerPlot: the number of Gaussian peaks that will be used to fit
    %   the 1D conductance histogram for each identified cluster (default
    %   is 1)
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %peak: peaks of the fitted Gaussian(s) for each cluster
    %
    %error: errors in the peaks of the fitted Gaussian(s) for each cluster
    %
    %halfwidth: half width at half maximums of the fitted Gaussian(s) for
    %   each cluster
    %
    %cond_medians: median conductance value for each cluster
    
    
    if nargin < 7
        ToPlot = false;
    end
    if nargin < 8
        nPeaksPerPlot = 1;
    end

    Nout = length(OO_List);
    peaks = zeros(Nout,nPeaksPerPlot);
    peak_errors = zeros(Nout,nPeaksPerPlot);
    peak_halfwidths = zeros(Nout,nPeaksPerPlot);  
    cond_medians = zeros(Nout,1);
    
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
        [peaks(i,:),peak_errors(i,:),peak_halfwidths(i,:),cond_medians(i)] = ...
            SegmentCluster_to_1DHist(OO,extraction_eps(i),cutoff_frac,...
            clust_nums(i),plot_now,nPeaksPerPlot);   
    end

end