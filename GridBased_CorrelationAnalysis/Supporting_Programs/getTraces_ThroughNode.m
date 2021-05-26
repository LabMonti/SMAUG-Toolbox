function [ThroughTraces, nThrough] = getTraces_ThroughNode(GridCorrObj, NodeID)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: find all the coarse traces that pass through a
    %given node, and how many of them there are
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: grid correlation object containing coarsened traces and
    %   node information for a given dataset
    %
    %NodeID: the node ID# for the chosen node
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %ThroughTraces: cell array containing each of the coarse traces (as a
    %   two-column matrix of node coordinates) passing through the selected
    %   node
    %
    %nThrough: the # of coarse traces passing through the selected node
    
    
    if isempty(GridCorrObj.NodeOccupancy)
        GridCorrObj.calculate_NodeOccupancies();
    end

    Ntraces = GridCorrObj.Ntraces;
    AllTraces = GridCorrObj.CoarseTraces;
    NodeOccupancy = GridCorrObj.NodeOccupancy;

    %Go through all traces, and copy over just those passing through
    %the node of interest
    TraceCount = 0;
    ThroughTraces = cell(Ntraces,1);
    for i = 1:Ntraces
        if NodeOccupancy(NodeID, i)
            TraceCount = TraceCount + 1;
            ThroughTraces{TraceCount} = AllTraces{i};
        end
    end 
    ThroughTraces = ThroughTraces(1:TraceCount);
    nThrough = TraceCount;
    
end