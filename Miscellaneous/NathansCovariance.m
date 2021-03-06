%11May18 NDB: A version of the built-in MatLab "cov" function that should 
%be faster for my purposes because it is no longer general and only works 
%in the case I need it to work in.  Also, I no longer divide by (N-1) 
%because for this purpose I'll just put it back in later anyway.  
function c = NathansCovariance(data)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: A version of the built-in MatLab "cov" function 
    %that is much faster for my purposes because it is no longer general 
    %and only works in the case I need it to work in.  Also, I no longer 
    %divide by (N-1) because for this purpose I'll just put it back in 
    %later anyway.  
    %
    %~~~INPUTS~~~:
    %
    %data: an array of data with two columns
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %c: 2-by-2 matrix of the covariance of the two columns of data (so the
    %   top left element is the variance of the first column, the top right
    %   element is the covariance of the first column with the second,
    %   etc.)
    
    
    %Get length
    n = size(data,1);
    
    %Remove mean
    xc = data - sum(data,1)./n;
    
    %Get covariance matrix
    c = (xc' * xc);  

end