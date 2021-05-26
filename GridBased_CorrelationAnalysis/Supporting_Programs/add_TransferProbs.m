function add_TransferProbs(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Fills in the TrasferProbs property of a 
    %GridCorrelationObject (also known as "exit probabilities"), which is
    %a square matrix where the (i,j)th element represents the probability
    %of a trace going to node ID #j in its next step given that it is 
    %currently at node ID #i
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: the GridCorrelationObject that this function will fill in
    %   the TransferProbs property of
    
    
    NUnique = GridCorrObj.NUnique;

    %Get the # of traces directly transfering between each pair of nodes
    TransferCounts = get_TransferCounts(GridCorrObj);
    
    %This is to make sure that once you are in the end trace node, you have
    %a 100% chance of staying there
    TransferCounts(NUnique+2,NUnique+2) = 1;
    
    %Now we need to calculate the probability of transfering directly from
    %one node to another (so, most will be zero except for adjacent nodes).
    %To do this we just normalize the counts by the total # of traces
    %leaving each node
    TransferProbs = zeros(NUnique+2);
    NLeaving = sum(TransferCounts,2);
    for i = 1:NUnique + 2
        TransferProbs(i,:) = TransferCounts(i,:)./NLeaving(i);
    end    
    GridCorrObj.TransferProbs = TransferProbs;   

end