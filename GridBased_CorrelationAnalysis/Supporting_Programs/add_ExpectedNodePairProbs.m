function add_ExpectedNodePairProbs(GridCorrObj,Parallelize)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: for each pair of ordered nodes, this function
    %calculates the probability that a coarse trace passing through the
    %first node would also pass through the second node, under the
    %assumption that traces proceed like random walks. This information is
    %then added to the GridCorrelationObject. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObj: GridCorrelationObject that this function will update the
    %   ExpecteNodePairProbs property of.
    %
    %Parallelize: logical variable; whether or not to use parallelization
    %   to speed up this calculation, since it is one of the slowest steps
    %   of the overall correlation workflow.
    
    
    if nargin < 2
        Parallelize = false;
    end
    
    %If parallelization is on, get (or create) parallel pool
    if Parallelize
        pool = gcp;
    else
        pool = [];
    end

    NUnique = GridCorrObj.NUnique;
    
    %The index NUninque+1 refers to the "StartTrace" node; the index NUnique+2
    %refers to the "EndTrace" node;    
    NodePairProbs = zeros(NUnique+2);
    
    %Temporary storage to help with parallelization
    Bmat_FirstColumns = zeros(NUnique);
    
    %Extract matrix to transfer probabilities now to help with
    %parallelization
    TransferProbsOG = GridCorrObj.TransferProbs;
    
    %Go through all real nodes and find the probability of ending up at
    %them from any other node; option to run in parallel
    if isempty(pool)
        for EndNode = 1:NUnique

            %Modify transfer matrix to create a sink at the ending node
            TransferProbs = TransferProbsOG;
            TransferProbs(EndNode, :) = 0;
            TransferProbs(EndNode, EndNode) = 1;

            %Re-order the transfer matrix to put both absorbing states at the
            %end (The "EndTrace" absorbing state is already at the end, so we
            %just need to move the state we just made into an abosrbed into the
            %second to last position.  This second-to-last position currently 
            %contains the "StartTrace" node, so we are switching the EndNode
            %with the "StartTrace" node)
            TransferProbs([EndNode, NUnique+1],:) = TransferProbs([NUnique+1, EndNode],:); %Swap rows
            TransferProbs(:,[EndNode, NUnique+1]) = TransferProbs(:,[NUnique+1, EndNode]); %Swap columns

            %Find the fundamental matrix, N (or really it's inverse, for speed)
            Qmat = TransferProbs(1:NUnique,1:NUnique);
            Nmatinv = (eye(NUnique) - Qmat);

            %Find the absorption probabilities, B:
            Rmat = TransferProbs(1:NUnique, NUnique+1:NUnique+2);
            Bmat = Nmatinv \ Rmat; %Using matrix division here is faster than calculating the inverse above and multiplying   
            Bmat_FirstColumns(:,EndNode) = Bmat(:,1);

            %Note: this works!!!       

            if mod(EndNode,64) == 0
                disp([EndNode NUnique]);
            end
        end
    else
        parfor EndNode = 1:NUnique

            %Modify transfer matrix to create a sink at the ending node
            TransferProbs = TransferProbsOG;
            TransferProbs(EndNode, :) = 0;
            TransferProbs(EndNode, EndNode) = 1;

            %Re-order the transfer matrix to put both absorbing states at the
            %end (The "EndTrace" absorbing state is already at the end, so we
            %just need to move the state we just made into an abosrbed into the
            %second to last position.  This second-to-last position currently 
            %contains the "StartTrace" node, so we are switching the EndNode
            %with the "StartTrace" node)
            TransferProbs([EndNode, NUnique+1],:) = TransferProbs([NUnique+1, EndNode],:); %Swap rows
            TransferProbs(:,[EndNode, NUnique+1]) = TransferProbs(:,[NUnique+1, EndNode]); %Swap columns

            %Find the fundamental matrix, N (or really it's inverse, for speed)
            Qmat = TransferProbs(1:NUnique,1:NUnique);
            Nmatinv = (eye(NUnique) - Qmat);

            %Find the absorption probabilities, B:
            Rmat = TransferProbs(1:NUnique, NUnique+1:NUnique+2);
            Bmat = Nmatinv \ Rmat; %Using matrix division here is faster than calculating the inverse above and multiplying   
            Bmat_FirstColumns(:,EndNode) = Bmat(:,1);

            %Note: this works!!!       

            if mod(EndNode,64) == 0
                disp([EndNode NUnique]);
            end
        end        
    end
    
    %Now use a separate loop to transfer data from all the Bmat columns to
    %the NodePairProbs matrix (could not be done in the above loop with
    %parallelization because of how the indexing works)
    for EndNode = 1:NUnique
        %Fill in the absorption probabilities into the Node pair
        %probabilities matrix:
        NodePairProbs(1:EndNode-1,EndNode) = Bmat_FirstColumns(...
            1:EndNode-1,EndNode);
        NodePairProbs(EndNode, EndNode) = 1;
        NodePairProbs(EndNode+1:NUnique,EndNode) = Bmat_FirstColumns(...
            EndNode+1:NUnique,EndNode);
        
        %Note: the value in the "EndNode" index actually belonds to the
        %StartTrace index because we swapped the order of the states above.
        %Hence we skipped that index above, but now add it to the correct
        %place to represent the probability of getting to EndNode from the
        %"StartTrace" node.  Note that this is NOT simply equal to the
        %fraction of traces that pass through EndNode (I have conclusively
        %proven this to myself).  
        NodePairProbs(NUnique+1,EndNode) = Bmat_FirstColumns(EndNode,EndNode);   
        
        %Note: this works!!!  
    end
    
    %The probability of passing through the end node is 1, regardless of
    %what other nodes a trace passes through
    NodePairProbs(:,NUnique+2) = 1;
    
    %The probability of passing through the start node given that you've
    %already passed through the start node is 1 of course!  (All other
    %probabilities ENDING at the start node are zero)
    NodePairProbs(NUnique+1,NUnique+1) = 1;
    
    GridCorrObj.ExpectedNodePairProbs = NodePairProbs;

end