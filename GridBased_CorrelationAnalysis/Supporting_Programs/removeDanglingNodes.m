function nRemovedTraces = removeDanglingNodes(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Finds "dangling" nodes, i.e. those that are
    %missing a neighbor BOTH immmediately above AND immediate below, then
    %removes traces through those nodes in order to get rid of them. The
    %reason to remove such nodes is that they produce problems for the MCMC
    %(it tends to get stuck on them). 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: GridCorrelationObject for a given dataset that will be
    %   modified by this function in order to remove the dangling nodes
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %nRemovedTraces: number of traces that were removed in order to remove
    %   the dangling nodes 
    
    %Make sure node occupancies are calculated
    GridCorrObj.calculate_NodeOccupancies;    
    
    nRemovedTraces = 0;
    nRemovedNodes = 0;
    removal_finished = false;   
    while ~removal_finished
        %(re)-find any missing neighbors
        GridCorrObj.calculate_MissingNeighbors();
        
        %Find the node IDs of any node missing BOTH their northern and
        %sourthern neighbors (column 1 is for sourthern neighbor, column 2
        %for northern)
        dangling_nodes = find(and(GridCorrObj.MissingNeighbors(:,1),...
            GridCorrObj.MissingNeighbors(:,2)));
        
        if isempty(dangling_nodes)
            removal_finished = true;
        else
            
            %Find all trace going through the nodes to be removed
            removeTraces = false(1,GridCorrObj.Ntraces);
            for i = length(dangling_nodes)
                removeTraces = or(removeTraces, GridCorrObj.NodeOccupancy(...
                    dangling_nodes(i),:));
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

            %Update totals
            nRemovedTraces = nRemovedTraces + sum(removeTraces);
            nRemovedNodes = nRemovedNodes + length(dangling_nodes);

            %Update other node information (e.g. UniqueNodes, NodeFreqs,
            %AllNodeIDs, etc.)
            index_nodes(GridCorrObj);

            %Re-calculate node occupancies
            GridCorrObj.calculate_NodeOccupancies;
            
        end
    end
    
    %Announce to user:
    disp(strcat(num2str(nRemovedTraces),' traces removed in order to remove',...
        {' '},num2str(nRemovedNodes),' nodes'));

end