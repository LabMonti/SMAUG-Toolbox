function SmoothedNodeValues = twoD_nodeSmooth(UniqueNodes, AllNodeIDs,...
    NodeValues,ToPlot)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: This function "smooths" a distribution of values
    %assigned to each node by averaging each node's value with the values
    %from the 8 neighboring nodes (N, S, W, E, NW, SW, NE, SE)
    %
    %~~~INPUTS~~~:
    %
    %UniqueNodes: two-column matrix containing the coordinates for each
    %   unique node in the dataset
    %
    %AllNodeIDs: a matrix where the (i,j)th element contains the node ID#
    %   for the node with coordinates i & j
    %
    %NodeValues: a vector with the same number of rows as UniqueNodes,
    %   containing the values of some property that has been assigned to
    %   each node
    %
    %ToPlot: logical variable; whether or not to create a plot of the
    %   smoothed values when done
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %SmoothedNodeValues: vector just like the input NodeValues, but with
    %   the values now smoothed by averaging each node's values with those of
    %   its neighbors
    
    
    if nargin < 4
        ToPlot = false;
    end

    NUnique = length(NodeValues);
    SmoothedNodeValues = NodeValues;
    
    %The different steps that we will try to take in grid-space,
    %representing one step N, S, E, or W, plus the 4 diagonal steps
    step_types = [0 1; 0 -1; 1 0; -1 0; 1 1; 1 -1; -1 1; -1 -1];
    
    %Options for larger net
%     step_types = [0 1; 0 -1; 1 0; -1 0; 1 1; 1 -1; -1 1; -1 -1;...
%         0 2; 0 -2; 2 0; -2 0; 1 2; -1 2; 1 -2; -1 -2; 2 1; 2 -1; -2 1; -2 -1; ...
%         2 2; 2 -2; -2 2; -2 -2];
    
    %How much to weight each step by.  We weight the diagonal steps by less
    %since they are slightly farther away
    w = 1/sqrt(2);
    step_weights = [1; 1; 1; 1; w; w; w; w];
    
    %Options for larger net
%     w1 = 1/2;
%     w2 = 1/sqrt(5);
%     w3 = 1/sqrt(8);
%     step_weights = [1; 1; 1; 1; w; w; w; w; w1; w1; w1; w1; w2; w2; w2; w2; ...
%         w2; w2; w2; w2; w3; w3; w3; w3];  

    nSteps = length(step_types);
    IDbounds = size(AllNodeIDs);
    
    for i = 1:NUnique
        
        current_node = UniqueNodes(i,:);
        
        counter = 1; %To account for original node
        for j = 1:nSteps
            %First we need to see if a node exists in the direction we want
            %to step
            test_node = current_node + step_types(j,:);
            if test_node(1) <= IDbounds(1) && test_node(2) <= IDbounds(2) && ...
                    test_node(1) > 0 && test_node(2) > 0 && ...
                    AllNodeIDs(test_node(1),test_node(2)) > 0
                
                test_nodeID = AllNodeIDs(test_node(1),test_node(2));
                counter = counter + 1;
                
                SmoothedNodeValues(i) = SmoothedNodeValues(i) + NodeValues(test_nodeID)*step_weights(j);                
            end
        end 
        SmoothedNodeValues(i) = SmoothedNodeValues(i)/counter;
    end
    
    if ToPlot
        figure();
        scatter(UniqueNodes(:,1),UniqueNodes(:,2),10,SmoothedNodeValues,'filled');
        cmap = importdata('cmap.mat');
        colormap(cmap);
        colorbar();
    end

end