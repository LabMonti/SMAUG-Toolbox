function index = FirstAfter(SortedList, value)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: given a SortedList of values (ascending), finds
    %the index of the first element after (i.e. greater than or equal to) 
    %'value'.  Used for binary search-type operations.  
    %
    %~~~INPUTS~~~:
    %
    %SortedList: a vector of values sorted in ascending order
    %
    %value: the value in the list that we want to find the first value
    %   after
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %index: the index of the first item in the list after "value"
    
    
    a = 1;
    b = length(SortedList);
    
    while b > a + 1
        
        mid = ceil((a+b)/2);
        if value <= SortedList(mid)
            b = mid;
        else
            a = mid;
        end
        
    end
    index = b;

end