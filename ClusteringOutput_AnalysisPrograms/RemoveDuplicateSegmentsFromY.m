function Y = RemoveDuplicateSegmentsFromY(Y, OutputStruct)

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