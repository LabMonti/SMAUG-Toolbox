function X = DataStandardization(X,format,w)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Program to standardize data before clustering, 
    %with different behavior for different data formats
    %
    %~~~INPUTS~~~:
    %
    %X: input data
    %
    %format: a string specifying the clustering format being used (and
    %   hence the format of the raw data)
    %
    %w: weighting factor for the conductance dimension
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %X: output data; same as input data but now standardized

    
    if nargin < 3
        w = 1;
    end

    if strcmp(format, 'Histogram')
        X(:,1) = zscore(X(:,1));
        X(:,2) = w*zscore(X(:,2));
        %Take reciprocal of counts dimension before standardizing
        X(:,3) = 1./X(:,3);
        X(:,3) = zscore(X(:,3));
    elseif strcmp(format, 'PointsFromTraces')
        X(:,1) = zscore(X(:,1));
        X(:,2) = w*zscore(X(:,2)); 
    elseif strcmp(format, 'Hybrid')
        %Standardize data using middle 80% of data range (new 24Aug17)
        X(:,1) = X(:,1) / (prctile(X(:,1),90) - prctile(X(:,1),10));
        X(:,2) = X(:,2) / (prctile(X(:,2),90) - prctile(X(:,2),10));
        X(:,3) = X(:,3) / (prctile(X(:,3),90) - prctile(X(:,3),10)); 
    end


end
