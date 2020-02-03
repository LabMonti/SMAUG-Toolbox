%Give a SortedList of values (ascending), finds the index of the first
%element after (i.e. greater than or equal to) 'value'
function index = FirstAfter(SortedList, value)
    
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