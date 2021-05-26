function NodeFreqs = get_node_counts_for_CoarseTraces(TraceNodeIDs, NUnique, ...
    AllNodeIDs)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a cell array of coarse traces (with EITHER
    %the ID# for each node listed OR a pair of node indices), calculate the
    %frequency of each node in that set of traces
    %
    %~~~INPUTS~~~:
    %
    %TraceNodeIDs: a cell array of coarse traces; each trace can either be
    %   a vector of node ID #s or a 2-column matrix of node coordinates
    %
    %NUnique: the number of unique nodes in the dataset
    %
    %AllNodeIDs: the matrix used to convert from node coordinates to node
    %   ID #s; the ID# of  node with coordinates (x,y) will be stored as
    %   the (x,y)th element of this matrix
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %NodeFreqs: vector containing total counts of how many coarse traces
    %   from the input set passed through each node
    
    
    if size(TraceNodeIDs{1},2) == 2 && nargin < 3
        error('AllNodeIDs required if node indices are passed in');
    end

    NT = length(TraceNodeIDs);
    
    NodeFreqs = zeros(NUnique,1);
    
    %In this case, each "trace" contains a list of node IDs
    if size(TraceNodeIDs{1},2) == 1
        for i = 1:NT
            tr = TraceNodeIDs{i};
            n = length(tr);
            for j = 1:n
                %%%disp([j tr(j) n NUnique i]);
                NodeFreqs(tr(j)) = NodeFreqs(tr(j)) + 1;
            end
        end
    %In this case, each "trace" contains a list of pairs of node indices
    elseif size(TraceNodeIDs{1},2) == 2
        for i = 1:NT
            tr = TraceNodeIDs{i};
            n = size(tr,1);
            for j = 1:n
                id = AllNodeIDs(tr(j,1),tr(j,2));
                NodeFreqs(id) = NodeFreqs(id) + 1;
            end
        end        
    end

end