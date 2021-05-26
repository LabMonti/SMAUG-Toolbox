function whole_trace = generate_randomtrace_throughnode(GridCorrObj, ...
    CumulativeTransferFROMProbs, StartNode, ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: This function generates a random trace passing
    %through a specified node (going both forward and backwards from that
    %node) with each step chosen using the "null hypothesis" probabilities
    %of traces transferring between nodes assuming no correlations
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: the GridCorrelationObject containing information on a
    %   given dataset and its nodes
    %
    %CumulativeTransferFROMProbs: matrix containing cumulative
    %   probabilities of transfering directly to each node FROM all other
    %   nodes (AKA "entrance probabilities"). This information can be
    %   deduced from the TransferProbabilities in the grid correlation
    %   object, calculating them just one is more efficient so they are
    %   passed in as a variable. 
    %
    %StartNode: the node that the null distribution will be generated
    %   starting from; can be specified either by its ID# or by a 2x1 vector
    %   of its grid coordinates 
    %
    %ToPlot: logical variable; whether or not to plot the generated random
    %   trace when done
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %whole_trace: a vector containing the node ID#s, in order, of the
    %   generated random trace
    
    
    if nargin < 4
        ToPlot = false;
    end

    %StartNode can be EITHER a tuple of the coordinates of the node, or the
    %node's ID#
    
    NUnique = GridCorrObj.NUnique;
    if nargin < 3
        StartNode = NUnique+1;
    end

    %Make sure cumulative transfer probabilities exist!
    if isempty(GridCorrObj.CumulativeTransferProbs)
        GridCorrObj.calculate_CumulativeTransferProbs();
    end
    CumulativeTransferProbs = GridCorrObj.CumulativeTransferProbs;

    StartNode = GridCorrObj.getNodeID(StartNode);
    
    %Find length of longest coarse trace
    maxN = max(GridCorrObj.CoarseTraceLengths);

    %Generate the random trace starting at the requested StartNode and
    %going forward
    forward_trace = zeros(maxN,1);
    currID = StartNode;
    if StartNode == NUnique+1
        %If we are starting at the very beginning, don't add the
        %"StartTrace" node to the trace because it's not a real node
        counter = 0;        
    elseif StartNode == NUnique+2
        %If we are starting at the end, there is no forward looking trace
        forward_trace = [];
    else
        %Otherwise, add starting node to the trace
        counter = 1;
        forward_trace(counter) = currID;
    end
    
    endID = NUnique + 2;
    while currID ~= endID        
        
        %Transfer to next node with probability previously calculated
        x = rand();
        cum_prob = CumulativeTransferProbs(currID, 1);
        j = 1;
        while x > cum_prob
            j = j + 1;
            cum_prob = CumulativeTransferProbs(currID, j);
        end
        
        %Move to next node
        currID = j;
        
        %Add this new node to trace
        counter = counter + 1;
        forward_trace(counter) = currID;        
        
    end
    %Chop off last node in trace, because it must be the "EndTrace" node
    if ~isempty(forward_trace)
        forward_trace = forward_trace(1:counter-1);
    end
    
    %Generate the random trace starting just before the requested StartNode
    %and going backward:
    
    backward_trace = zeros(maxN,1);
    currID = StartNode; %Re-initialize to starting node
    if StartNode == NUnique+1
        %If we are starting at the very beginning, there is no backward
        %looking trace
        backward_trace = [];     
    end
    
    startID = NUnique + 1;
    counter = 0;
    while currID ~= startID   
        
        %Transfer backwards with a probability equal to that of having
        %transferred to current node
        x = rand();
        cum_prob = CumulativeTransferFROMProbs(1,currID);
        j = 1;
        while x > cum_prob
            j = j + 1;
            cum_prob = CumulativeTransferFROMProbs(j,currID);
        end
        
        %Move to next node
        currID = j;
        
        %Add this new node to trace
        counter = counter + 1;
        backward_trace(counter) = currID;        
        
    end
    %Chop off last node in trace, because it must be the "StartTrace" node
    backward_trace = backward_trace(1:counter-1);    
    
    %Combine the forward and backward traces to get a single complete trace
    %that goes from the "StartTrace" node to the "EndTrace" node
    backward_trace = flipud(backward_trace);
    whole_trace = [backward_trace; forward_trace];
    
    if ToPlot
        UniqueNodes = GridCorrObj.UniqueNodes;
        
        figure();
        plot(UniqueNodes(whole_trace,1),UniqueNodes(whole_trace,2),'-o');
        
        %Plot the specified through node as long as it's a real node, not a
        %Start or End trace node
        if StartNode <= NUnique
            hold on;
            disp([UniqueNodes(StartNode,1),UniqueNodes(StartNode,2)]);
            plot(UniqueNodes(StartNode,1),UniqueNodes(StartNode,2),'.','MarkerSize',30,'Color','g');
            hold off;
        end
    end

end