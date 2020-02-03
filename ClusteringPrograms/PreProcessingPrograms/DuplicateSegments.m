%06Jun18 NDB: Given a set of parameterized segments, create a larger set of
%segment parameters by duplicating each segment's info in proportion to the
%length of the segment
function [SegParamsWithDups, segIDs, Nduplicates, OGvsDup] = ...
    DuplicateSegments(AllSegments, SegmentParameters, length_per_dup)
    %~~~INPUTS~~~:
    %
    %AllSegments: an array holding the x- and y- endpoint values for all
    %   segments
    %
    %SegmentParameters: an array holding parameters for each trace
    %   segment; each row corresponds to a new segment, each column holds a
    %   different parameter
    %
    %length_per_dup: each segment will be duplicated (length of segment in 
    %   nm) / (length_per_dup), rounded DOWN to the nearest integer
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %SegParamsWithDups: the same as the input array SegmentParameters
    %   except that segments have been duplicated in proportion to their
    %   lengths and so extra rows have been added
    %
    %segIDs: an integer for each of the new segments indicating the ID# of
    %   the original segment that it is a copy of
    %
    %Nduplicates: a vector indicating how many times each of the original
    %   segments was duplicated
    %
    %OGvsDup: a logical vector with one element per new segment, with that
    %   element true for the first copy of each segment and false for all
    %   later, duplicated copies
    

    NSegments = size(AllSegments,1);
    
    %Find length of each segment:
    seg_lengths = AllSegments(:,2) - AllSegments(:,1);

    %Overestimate of how many segments there will be after duplication:
    newNSegs = sum(ceil(seg_lengths./length_per_dup));
    
    SegParamsWithDups = zeros(newNSegs, size(SegmentParameters,2));
    counter = 0;
    Nduplicates = zeros(NSegments,1);
    OGvsDup = false(newNSegs, 1);
    segIDs = zeros(newNSegs,1);
    for i = 1:NSegments
        
        %Determine # of duplicates
        n = floor(seg_lengths(i)/length_per_dup);
        %n = max(1,n);
        Nduplicates(i) = n;
        
        %The first copy of this segment is the original (all others are
        %duplicates)
        if n > 0
            OGvsDup(counter+1) = true;
        end
        
        for j = 1:n
            counter = counter + 1;
            SegParamsWithDups(counter,:) = SegmentParameters(i,:);
            segIDs(counter) = i;
        end
        
    end
    
    %Trim outputs to account for how many total segments were actually
    %created
    SegParamsWithDups = SegParamsWithDups(1:counter, :);
    segIDs = segIDs(1:counter);
    OGvsDup = OGvsDup(1:counter);

end
