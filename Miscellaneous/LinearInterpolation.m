function new_y = LinearInterpolation(data, target_x)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given an array of xy-data, find a value for y 
    %at a target x-value not in the original array using linear 
    %interpolation
    %
    %~~~INPUTS~~~:
    %
    %data: a two-column array with x-values in ascending order in the first
    %   column and y-values in the second column
    %
    %target_x: the x-value at which we want to interpolate a y-value
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %new_y: the interpolated y-value that corresponds to the target_x value


    %Starting bounds
    a = 1;
    b = size(data,1);
    
    %Find two x-indices bracketing target_x using binary search
    while (b - a) > 1
        mid = floor((a+b)/2);
        
        if data(mid,1) - target_x >= 0
            b = mid;
        else
            a = mid;
        end
    end
    
    %If bracketing x-values are the same, return the average y-value
    if data(b,1) == data(a,1)
        new_y = (data(b,2) + data(a,2)) / 2;
    %If the bracketing x-values are not the same, use linear interpolation
    else
        slope = (data(b,2) - data(a,2)) / (data(b,1) - data(a,1));
        intercept = data(b,2) - slope * data(b,1);
        new_y = slope*target_x + intercept;
    end

end