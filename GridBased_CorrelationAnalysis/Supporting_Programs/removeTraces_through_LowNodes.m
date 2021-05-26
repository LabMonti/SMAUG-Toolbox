function nRemovedTraces = removeTraces_through_LowNodes(GridCorrObj, ...
    minTracesThru)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Iteratively remove traces in order to get rid 
    %of nodes with very few traces passing through them.
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: the GridCorrelationObject whose information will be
    %   modified by removing coarse traces in order to eliminate low-trace
    %   nodes
    %
    %minTracesThru: the minimum # of traces that must pass through a node
    %   for this function to NOT try to eliminate that node
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %nRemovedTraces: number of traces that were removed in order to remove
    %   the low-trace nodes
    
    %Make sure node occupancies are calculated
    GridCorrObj.calculate_NodeOccupancies;

    %Sum up the # of traces passing through each node and find which nodes
    %need to be removed
    numTraces_Thru = sum(GridCorrObj.NodeOccupancy,2);
    removeNodes = (numTraces_Thru < minTracesThru);      
    
    nRemovedTraces = 0;
    nRemovedNodes = 0;
    while sum(removeNodes) > 0
    
        %Figure out which TRACES need to be removed
        removeTraces = false(GridCorrObj.Ntraces,1);
        for i = 1:GridCorrObj.Ntraces
            if any(GridCorrObj.NodeOccupancy(removeNodes,i))
                removeTraces(i) = true;
            end
        end
        
        %Update # of traces
        GridCorrObj.Ntraces = GridCorrObj.Ntraces - sum(removeTraces);
        
        %Update total # of nodes
        node_decrease = sum(GridCorrObj.CoarseTraceLengths(removeTraces));
        GridCorrObj.NumTotalNodes = GridCorrObj.NumTotalNodes - node_decrease;
        
        %Remove the traces:
        GridCorrObj.CoarseTraces = GridCorrObj.CoarseTraces(~removeTraces);
        GridCorrObj.CoarseTraceLengths = GridCorrObj.CoarseTraceLengths(~removeTraces);
        GridCorrObj.OriginalTraceIDs = GridCorrObj.OriginalTraceIDs(~removeTraces);
        
        %Update totals:
        nRemovedTraces = nRemovedTraces + sum(removeTraces);
        nRemovedNodes = nRemovedNodes + sum(removeNodes);
        
        %Update other node information (e.g. UniqueNodes, NodeFreqs,
        %AllNodeIDs, etc.)
        index_nodes(GridCorrObj);
        
        %Re-calculate node occupancies
        GridCorrObj.calculate_NodeOccupancies;
        
        %Re-check if any more nodes need to be removed:
        numTraces_Thru = sum(GridCorrObj.NodeOccupancy,2);
        removeNodes = (numTraces_Thru < minTracesThru);            
        
    end
    
    %Announce to user:
    disp(strcat(num2str(nRemovedTraces),' traces removed in order to remove',...
        {' '},num2str(nRemovedNodes),' nodes'));

end