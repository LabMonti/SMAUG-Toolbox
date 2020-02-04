function index = LastBefore(SortedList, value)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: given a SortedList of values (ascending), finds
    %the index of the last element before (i.e. less than or equal to) 
    %'value'.  Used for binary search-type operations.  
    %
    %~~~INPUTS~~~:
    %
    %SortedList: a vector of values sorted in ascending order
    %
    %value: the value in the list that we want to find the last value
    %   before
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %    
    %index: the index of the last item in the list before "value"
    
    a = 1;
    b = length(SortedList);
    
    while b > a + 1
        
        mid = ceil( (a + b)/2 );
        if value < SortedList(mid)
            b = mid;
        else
            a = mid;
        end
        
    end
    index = a;

end