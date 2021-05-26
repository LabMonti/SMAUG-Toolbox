function TransferFROMProbs = get_TransferFROMProbs(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a square matrix where the (i,j)th element
    %represents the probability of a trace having just come FROM node i 
    %given that it is now at node j. Used to randomly generate traces
    %according to the null distribution that propogate backwards from a
    %given node. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: grid correlation object containing the coarse traces and
    %   node information for a given dataset
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %TransferFROMProbs: square matrix where the (i,j)th element
    %   represents the probability of a trace having just come FROM node i 
    %   given that it is now at node j, according to the null distribution
    
    
    NUnique = GridCorrObj.NUnique;

    %Get the # of traces directly transfering between each pair of nodes
    TransferCounts = get_TransferCounts(GridCorrObj);
    
    %This is to ensure that if you are in the StartTrace node, you have a
    %100% probability of having just previously been in the StartTrace node
    TransferCounts(NUnique+1,NUnique+1) = 1;
    
    %Now we need to calculate the probability of having transferred directly from
    %one node to another (so, most will be zero except for adjacent nodes).
    %To do this we just normalize the counts by the total # of traces
    %ENTERING each node
    TransferFROMProbs = zeros(NUnique+2);
    NEntering = sum(TransferCounts,1);
    for i = 1:NUnique + 2
        TransferFROMProbs(:,i) = TransferCounts(:,i)./NEntering(i);
    end

end