function [sectionBounds, sectionLengths] = ...
    splitup_YnodeList(YnodeList, NoiseLevel)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Given a vector and a noise floor, this function
    %finds the bounds of the continuous sections of the vector that are
    %above the noise floor. Used in order to break up a coarse trace into
    %distinct sections.
    %
    %~~~INPUTS~~~:
    %
    %YNodeList: vector of y-values for each node in the coarse trace
    %
    %NoiseLevel: the value of the noise floor, in the same units as the
    %   y-values in the YNodeList
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %  
    %sectionBounds: a two column matrix with one row per ach distinct
    %   section discovered in the coarse trace. The first and second column
    %   show the starting and ending indices, respectively, of each such
    %   section
    %
    %sectionLengths: vector containing the length, in nodes, of each
    %   distinct section that was discovered
    
    
    n = length(YnodeList);
    
    sectionBounds = zeros(n,2);
    sectionBounds(1,1) = 1;
    active = (YnodeList(1) >= NoiseLevel);
    
    sectionCounter = 0;
    j = 2;
    while j <= n
        
        %If the previous point was above the noise floor (active) but the
        %current point is below it, then we know we terminated a section
        if YnodeList(j) < NoiseLevel && active
            sectionCounter = sectionCounter + 1;
            sectionBounds(sectionCounter,2) = j - 1;
        end
        
        %If the previous point was below the noise floor (not active) but
        %the current point is above it, then we know we just started a new
        %section
        if ~active && YnodeList(j) >= NoiseLevel
            sectionBounds(sectionCounter+1,1) = j;
        end
        
        active = (YnodeList(j) >= NoiseLevel);
        j = j + 1;        
    end
    
    %Close off the final active section, if necessary
    if active
        sectionCounter = sectionCounter + 1;
        sectionBounds(sectionCounter,2) = j-1;
    end
    sectionBounds = sectionBounds(1:sectionCounter,:);
    
    sectionLengths = sectionBounds(:,2) - sectionBounds(:,1) + 1;

end