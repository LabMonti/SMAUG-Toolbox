function [peak, error, halfwidth, cond_median] = ...
    SegmentCluster_to_1DHist(OutputStruct, epsilon, cutoff_frac, ...
    cluster_num, ToPlot, nPeaksToFit)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a segment clustering solution with one 
    %cluster specified, get all data points corresponding to that cluster,
    %make a 1D histogram from those data, and fit that histogram with a
    %single unrestricted Gaussian function
    %
    %~~~INPUTS~~~:
    %
    %OutputStruct: structure containing clustering output
    %
    %epsilon: the value of epsilon at which extraction takes place; 
    %   clusters will be valleys that exist below this cut-off value in the
    %   reachability plot
    %
    %cutoff_fraction: the minimum size a valley in the reachability plot
    %   must be to be considered a true cluster, as a fraction of the total
    %   # of data points (so 0.02 means clusters must contain at least 2%
    %   of all data points). Points in valleys with fewer than this # of
    %   data points are re-assigned to the noise cluster
    %
    %cluster_num: the # of the specific cluster in the cluster solution
    %   (which valley it corresponds to, counting left to right)
    %
    %ToPlot: logical variable; whether to make a visible plot or not
    %
    %nPeaksToFit: the number of Gaussian peaks to use for fitting the 1D
    %   conductance distribution
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %peak: peak(s) of the fitted Gaussian(s)
    %
    %error: error in the peak(s) of the fitted Gaussian(s)
    %
    %halfwidth: half width at half maximum of the fitted Gaussian(s)
    %
    %cond_median: median of all conductance values in the chosen cluster
    
    
    if nargin < 5
        ToPlot = false;
    end
    if nargin < 6
        nPeaksToFit = 1;
    end

    [Y,~,~] = ExtractClusterSolution(OutputStruct.RD,OutputStruct.CD,epsilon,...
        cutoff_frac);
    
    %Remove duplicates if necessary
    if strcmp(OutputStruct.Format, 'Segments_LengthWeighting')
        Y = RemoveDuplicateSegmentsFromY(Y,OutputStruct);
        OutputStruct = RemoveDuplicateSegmentsFromOutput(OutputStruct);
    end
    
    Traces = OutputStruct.TracesUsed;
    
    %Get bounds and TraceIDs and put them in the same order as Y
    order = OutputStruct.order;
    TraceIDs = OutputStruct.SegmentTraceIDs(order);
    Bounds = OutputStruct.AllBounds(order,:);
    
    %Keep just the traces and bounds of the cluster we are looking for
    TraceIDs = TraceIDs(Y == cluster_num);
    Bounds = Bounds(Y == cluster_num,:);
    
    Nmax = length(Traces)*15000;
    
    AllCondData = zeros(Nmax,1);
    counter = 0;
    for i = 1:length(TraceIDs)
        n = Bounds(i,2) - Bounds(i,1) + 1;
        AllCondData(counter+1:counter+n) = Traces{TraceIDs(i)}(Bounds(i,1):Bounds(i,2),2);
        counter = counter + n;
    end
    AllCondData = AllCondData(1:counter);
    
    [peak, error, halfwidth] = fit_histogram_peak(AllCondData,...
        nPeaksToFit,'algorithm',ToPlot);
    
    %Get median conductance value
    cond_median = median(AllCondData);
    
    if ToPlot
        xlabel('Log(Conductance/G_0)');
        ylabel('Count');
    end

end
