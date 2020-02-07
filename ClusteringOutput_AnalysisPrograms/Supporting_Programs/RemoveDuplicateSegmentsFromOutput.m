function OutputStruct = RemoveDuplicateSegmentsFromOutput(OutputStruct)
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
    %OutputStruct: the clustering output structure
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %OutputStruct: the same as the input, but with the duplicate values
    %   removed
    
    
    %Get logical vector indicating which points are originals and which are
    %duplicates
    OGvsDup = OutputStruct.original_vs_duplicate;
    
    OutputStruct.AllSegments = OutputStruct.AllSegments(OGvsDup,:);
    OutputStruct.AllBounds = OutputStruct.AllBounds(OGvsDup,:);
    OutputStruct.SegmentTraceIDs = OutputStruct.SegmentTraceIDs(OGvsDup,:);
    if isfield(OutputStruct,'AlignedSegments')
        OutputStruct.AlignedSegments = OutputStruct.AlignedSegments(OGvsDup,:);
        OutputStruct.ActiveRegions = OutputStruct.ActiveRegions(OGvsDup,:);
    end
    
    %Get original order
    OG_order = OutputStruct.order;
    OutputStruct.OG_order = OG_order;
    
    %Make new order with duplicates removed
    order = zeros(sum(OGvsDup),1);
    counter = 0;
    for i = 1:length(OGvsDup)
        if OGvsDup(OG_order(i))
            counter = counter + 1;
            order(counter) = OG_order(i);
        end
    end
    
    %However, now order does not contain only consecutive integers overall;
    %therefore we must sort it, make the integers consecutive, then put
    %them back in their unsorted order.  This can cleverly be done in one
    %step!
    [~, ~, new_order] = unique(order);
    OutputStruct.order = new_order;

end