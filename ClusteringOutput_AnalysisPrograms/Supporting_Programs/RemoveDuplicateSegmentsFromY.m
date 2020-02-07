function Y = RemoveDuplicateSegmentsFromY(Y, OutputStruct)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: when clustering was performed using the Segment
    %   clustering mode with length weighting, then each segment got
    %   duplicated in proportion to its length.  This function removes
    %   those duplicates to speed up plotting.  
    %
    %~~~INPUTS~~~:
    %
    %Y: the cluster number of each segment, in the order of the cluster
    %   order
    %
    %OutputStruct: the clustering output structure
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %Y: same as the input, but with duplicates removed
    
    
    %Make sure to get the original order, including duplicates:
    if isfield(OutputStruct,'OG_order')
        order = OutputStruct.OG_order;
    else
        order = OutputStruct.order;
    end
    
    %Get logical vector indicating which points are originals and which are
    %duplicates
    OGvsDup = OutputStruct.original_vs_duplicate;
    
    %Convert to same order as Y is in:
    OGvsDup = OGvsDup(order);
    
    %Now we can remove the duplicates from Y:
    Y = Y(OGvsDup);

end