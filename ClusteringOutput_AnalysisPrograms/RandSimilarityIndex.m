function c = RandSimilarityIndex(Y1, Y2)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Finds c, the similarity between two clustering 
    %solutions Y1 and Y2.  c ranges from 0 (completely different) to 1 
    %(completely the same). Source: "Objective Criteria for the Evaluation
    %of Clustering Methods" by William M. Rand, 1971.  
    %
    %~~~INPUTS~~~:
    %
    %Y1: list of cluster ID assignments for first cluster solution
    %
    %Y2: list of cluster ID assignments for second cluster soluiton
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %c: Rand index for the two clustering solutions
    
    
    IDs_1 = unique(Y1);
    IDs_2 = unique(Y2);
    N = length(Y1);
    
    nIDs1 = length(IDs_1);
    nIDs2 = length(IDs_2);
    
    %First find the sum over i of (sum over j)^2 term as well as sum over i
    %and j of n_ij^2
    Term1 = 0;
    Term3 = 0;
    for i = 1:nIDs1
        temp_sum = 0;
        for j = 1:nIDs2
            n = n_ij(Y1,Y2,IDs_1,IDs_2,i,j);
            temp_sum = temp_sum + n;
            Term3 = Term3 + n*n;
        end
        Term1 = Term1 + temp_sum*temp_sum;
    end
    
    %Now find the sum over j of (sum oer i)^2 term
    Term2 = 0;
    for j = 1:nIDs2
        temp_sum = 0;
        for i = 1:nIDs1
            temp_sum = temp_sum + n_ij(Y1,Y2,IDs_1,IDs_2,i,j);
        end
        Term2 = Term2 + temp_sum*temp_sum;
    end
    
    %Finally, combine all terms to get final answer:
    BigTerm = 0.5*Term1  + 0.5*Term2 - Term3;
    c = (nchoosek(N,2) - BigTerm)/nchoosek(N,2);
            
end


function n = n_ij(Y1, Y2, IDs_1, IDs_2, i, j)

    Y1_membership_i = (Y1 == IDs_1(i));
    Y2_membership_j = (Y2 == IDs_2(j));
    
    n = sum(and(Y1_membership_i, Y2_membership_j));

end