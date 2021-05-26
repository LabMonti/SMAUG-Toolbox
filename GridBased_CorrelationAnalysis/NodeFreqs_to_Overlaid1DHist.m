function [binCountsMatrix, binCenters] = NodeFreqs_to_Overlaid1DHist(...
    NodeFreq_cellArray, GCO, cond_or_dist, ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: turns a cell array of vectors of node 
    %frequencies into either a conductance or distance one dimensional
    %histogram of those gridded values.
    %
    %~~~INPUTS~~~:
    %
    %NodeFreq_cellArray: a cell array in which each cell contains a vector
    %   with length equal to the number of nodes in the dataset. This
    %   vector contains a distribution of counts assigned to each node,
    %   which will be turned by this function into a histogram of either
    %   those nodes' conductance or distance values
    %
    %GCO: The GridCorrelationObject containing information about all of the
    %   nodes in the dataset that the relevant MCMC simulation was run on
    %
    %cond_or_dist: string variable; can be set to either "dist" or "cond"
    %   to specify whether a distance or conductance 1D histogram should be
    %   created
    %
    %ToPlot: logical variable; whether or not to plot the histogram results
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %  
    %binCountsMatrix: a matrix in which each column contains the bin counts
    %   for each histogram bin for the different node frequency
    %   distributions passes in
    %
    %binCenters: vector of the centers of each histogram bin, converted
    %   from grid units back to "real" units (e.g., log(G0) or nm)
    
    
    if nargin < 4
        ToPlot = true;
    end
    if nargin < 3
        cond_or_dist = 'cond';
    end
    
    if strcmp(cond_or_dist,'cond')
        col = 2;
    elseif strcmp(cond_or_dist,'dist')
        col = 1;
    else
        error('Unrecognized input for cond_or_dist');
    end
    
    UniqueNodes = GCO.UniqueNodes;
    minNode = min(UniqueNodes(:,col));
    maxNode = max(UniqueNodes(:,col));
    nRow = size(NodeFreq_cellArray{1},1);
    nCol = length(NodeFreq_cellArray);
    
    %Accumulate total count for each bin
    binCountsMatrix = zeros(maxNode-minNode + 1,nCol);
    for i = 1:nRow
        node = UniqueNodes(i,col) - minNode + 1;
        for j = 1:nCol
            binCountsMatrix(node,j) = binCountsMatrix(node,j) + ...
                NodeFreq_cellArray{j}(i);
        end
    end
    
    %Get bin centers and convert back to real (non-grid) units
    binCenters = (minNode:maxNode)';
    if col == 1
        binCenters = binCenters*GCO.Xstep + GCO.Xstart;
    else
        binCenters = binCenters*GCO.Ystep + GCO.Ystart;
    end

    %Make the overlaid plot
    if ToPlot
        figure();
        hold on;
        for j = 1:nCol
            [x,y] = convert_to_histogram_endpoints(binCenters,binCountsMatrix(:,j));
            plot(x,y);
        end
        ylabel('Count');
        if col == 1
            xlabel('Inter-Electrode Distance (nm)');
        else
            xlabel('Log(Conductance/G_0)');
        end
    end

end