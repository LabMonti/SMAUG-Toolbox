function criteriaChecker = get_criteriaChecker(CriteriaType)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: get a function handle for the criteria checker
    %for a specified type of criteria for node-chains in the MCMC. This is
    %its own function so that if new types of criteria need to be added,
    %they only have to be added in this one place.
    %
    %~~~INPUTS~~~:
    %
    %CriteriaType: string specifying the type of criteria the user wants to
    %   use
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %   
    %criteriaChecker: function handle to the criteria checking function
    %   chosen by the user
    
    
    %Get function handle for requested type of criteria to check
    if strcmp(CriteriaType,'None') || isempty(CriteriaType)
        criteriaChecker = @checkCriteria_None;
    elseif strcmp(CriteriaType,'RangeSlope')
        criteriaChecker = @checkCriteria_RangeSlope;
    elseif strcmp(CriteriaType,'FitSlope')
        criteriaChecker = @checkCriteria_BestFitSlope;
    elseif strcmp(CriteriaType,'FitAndRangeSlope')
        criteriaChecker = @checkCriteria_FitAndRangeSlope;
    elseif strcmp(CriteriaType, 'ZigZagUp')
        criteriaChecker = @checkCriteria_ZigZag;
    elseif strcmp(CriteriaType, 'LargeJump')
        criteriaChecker = @checkCriteria_LargeJump;
    elseif strcmp(CriteriaType, 'SteadySlope')
        criteriaChecker = @checkCriteria_SteadySlope;
    elseif strcmp(CriteriaType, 'PlateauAndDrop')
        criteriaChecker = @checkCriteria_PlateauAndDrop;
    else
        error('Unrecognized sequence criteria');
    end
    
end