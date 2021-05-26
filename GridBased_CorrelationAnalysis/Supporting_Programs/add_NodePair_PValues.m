function add_NodePair_PValues(GridCorrObj)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: fills in the PValues_above and PValues_below
    %properties of a GridCorrelationObject. These two nNodes x nNodes
    %matrices contain the p-values from binomial hypothesis tests that are
    %performed for each node for the number of traces from the first node
    %making it to the second node being >= (above) and <= (below) the
    %observed amount. The null hypothesis for these tests is that traces
    %behaving like weighted random walks. 
    %
    %~~~INPUTS~~~:
    %
    %GridCorrObject: the GridCorrelationObject that this function will fill
    %   in the PValues_above and PValues_below fields of
    
    
    NUnique = GridCorrObj.NUnique;
    NodePairCounts = GridCorrObj.ActualNodePairCounts;
    NodePairProbs = GridCorrObj.ExpectedNodePairProbs;
    NodeFreqs = GridCorrObj.NodeFreqs;   
    Ntraces = GridCorrObj.Ntraces;
   
    %The index NUninque+1 refers to the "Start" node; the index NUnique+2
    %refers to the "End" node;
    p_above = NaN(NUnique+2);
    p_below = NaN(NUnique+2);
        
    %Add frequences for the "StartTrace" and "EndTrace" nodes:
    NodeFreqs = [NodeFreqs; Ntraces; Ntraces];
    
    %Calculate p-values between all pairs of real nodes
    for i = 1:NUnique %Index of starting node
        Ntrials = NodeFreqs(i); %Number of traces passing through first node
        for j = 1:NUnique %Index of ending node
            
            null_prob = NodePairProbs(i,j);
            actual_count = NodePairCounts(i,j);
            
            %It only makes sense to talk about the probability of getting
            %to node j from node i if that is possible in the first place!
            if null_prob > 0 || actual_count > 0

                %Whenever actual_count = Ntrials, there is a 100% chance of
                %seeing as many or fewer successes as were observed (i.e.
                %p_below), and so we can save computation by setting
                %p_below directly equal to 1 in this case. However, please
                %note that this is more than just efficiency!  In the
                %special case of null_prob = 1, the betainc calculation
                %would give the wrong result (0), and so this shortcut is
                %also necessary to get the correct answer in that case. 
                if actual_count == Ntrials
                    p_below(i,j) = 1;
                else
                    p_below(i,j) = betainc(null_prob,actual_count+1,...
                        Ntrials-actual_count,'upper');
                end
                
                %We don't need to worry about the special case where this
                %betainc calculation fails, becuase that would be when
                %actual_count and null_prob are both zero, which doesn't
                %happen inside this loop
                p_above(i,j) = betainc(null_prob,actual_count,...
                    Ntrials-actual_count+1);
            end
            
        end
        if mod(i,512) == 0
            disp([i NUnique]);
        end
    end
    GridCorrObj.PValues_above = p_above;
    GridCorrObj.PValues_below = p_below;

end