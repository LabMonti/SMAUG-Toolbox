%This function generates a random trace section by taking a
%given number of steps forward and backward from a given node. The
%probabilities used to choose these steps are drawn from whatever
%probability matrices are input
function whole_sect = generate_randomtracesection_throughnode(...
    CumulativeTransferTO, CumulativeTransferFROM, StartNodeID, ...
    numSteps, ToPlot, OptionalUniqueNodes)
    %OptionalUniqueNodes needed for plotting

    if nargin < 5
        ToPlot = false;
    end
    if nargin < 4
        numSteps = 7;
    end
    
    %Divide up the number of steps into steps taken forward and backward
    %(in the case of odd numSteps, we will take one more step forward than
    %back).  Subtract one to account for the start node!
    nStepFor = ceil((numSteps-1)/2);
    nStepBac = floor((numSteps-1)/2);

    N = size(CumulativeTransferTO,2);

    %Generate the random trace section going forward from the requested
    %StartNode
    forward_sect = zeros(nStepFor,1);
    currID = StartNodeID;    
    endID = N; %End trace node will have an ID# of the size of the matrix
    counter = 0;
    while currID ~= endID && counter < nStepFor 
        
        %Use binary search to find the first cumulative transfer
        %probability greater than a random number, x. Use this to transfer
        %to a new node in proportion to the null transfer probs. 
        x = rand();
        a = 1;
        b = N;
        while b > a + 1
            mid = floor((a+b)/2);
            if CumulativeTransferTO(currID,mid) >= x
                b = mid;
            else
                a = mid;
            end
        end
        currID = b;
        
        %Add this new node to trace
        counter = counter + 1;
        forward_sect(counter) = currID;        
        
    end
    %Remove "EndTrace" node if that's where the trace section ends
    if currID == endID
        forward_sect = forward_sect(1:counter - 1);
    else
        forward_sect = forward_sect(1:counter);
    end
    
    %Generate the random trace starting just before the requested StartNode
    %and going backward   
    backward_sect = zeros(nStepBac,1);
    currID = StartNodeID; %Re-initialize to starting node    
    startID = N - 1; %StartTrace node will have an ID# of one less than the size of the matrix
    counter = nStepBac+1; %count backwards so that nodes are in correct order
    while currID ~= startID && counter > 1
        
        %Use binary search to find the first cumulative transfer FROM
        %probability greather than a random number, x. Use this to transfer
        %backwards in proportion to the null transfer from probabilities.
        x = rand();
        a = 1;
        b = N;
        while b > a + 1
            mid = floor((a+b)/2);
            if CumulativeTransferFROM(mid,currID) >= x
                b = mid;
            else
                a = mid;
            end
        end
        currID = b;        
        
        %Add this new node to trace
        counter = counter - 1;
        backward_sect(counter) = currID;        
        
    end
    %Remove "StartTrace" node if that's where the trace section ends
    if currID == startID
        backward_sect = backward_sect(counter + 1:nStepBac);
    else
        backward_sect = backward_sect(counter:nStepBac);
    end
    
    %Combine the forward and backward sections to get a single cohesive
    %section; don't forget to include the StartNode! (but only if the
    %StartNode was a real not and not the StartTrace or EndTrace node,
    %which we can infer from the size of the probability matrices). 
    if StartNodeID <= N-2
        whole_sect = [backward_sect; StartNodeID; forward_sect];
    else
        whole_sect = [backward_sect; forward_sect];
    end

    if ToPlot
        if nargin < 6
            error('UniqueNodes input needed for plotting!');
        end
        
        figure();
        plot(OptionalUniqueNodes(whole_sect,1),OptionalUniqueNodes(...
            whole_sect,2),'-o');
        
        %Plot the specified through node as long as it's a real node, not a
        %Start or End trace node
        if StartNodeID <= N-2
            hold on;
            plot(OptionalUniqueNodes(StartNodeID,1),OptionalUniqueNodes(...
                StartNodeID,2),'.','MarkerSize',30,'Color','g');
            hold off;
        end
    end

end