function TransferCounts = get_TransferCounts(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a square matrix where the (i,j)th element
    %represents the number of traces that transfer directly from node i to
    %node j. Used to calculate transfer probabilities (exit probabilites).
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: a GridCorrelationObject containing the coarse traces and
    %   node information for a given dataset
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %TransferCounts: square matrix where the (i,j)th element represents 
    %   the number of traces that transfer directly from node i to
    %   node j
    
    
    NUnique = GridCorrObj.NUnique;
    Ntraces = GridCorrObj.Ntraces;
    
    %Extra two nodes are the "start trace node" and "end trace node"
    TransferCounts = zeros(NUnique+2);
    StartID = NUnique + 1;
    EndID = NUnique + 2;
    
    AllNodeIDs = GridCorrObj.AllNodeIDs;
    
    %Go through and count the number of direct transfers between each node
    for i = 1:Ntraces
        
        tr = GridCorrObj.CoarseTraces{i};
        n = size(tr,1);
        
        %Count each transfer along the trace
        for j = 2:n
            prev_node = tr(j-1,:);
            curr_node = tr(j,:);
            
            prev_ID = AllNodeIDs(prev_node(1),prev_node(2));
            curr_ID = AllNodeIDs(curr_node(1),curr_node(2));
            
            TransferCounts(prev_ID, curr_ID) = TransferCounts(prev_ID, curr_ID) + 1;
        end
        
        %Count the start and end transfers:
        first_ID = AllNodeIDs(tr(1,1), tr(1,2));
        last_ID = AllNodeIDs(tr(n,1), tr(n,2));
        
        TransferCounts(StartID, first_ID) = TransferCounts(StartID, first_ID) + 1;
        TransferCounts(last_ID, EndID) = TransferCounts(last_ID, EndID) + 1;       
    end
    
end