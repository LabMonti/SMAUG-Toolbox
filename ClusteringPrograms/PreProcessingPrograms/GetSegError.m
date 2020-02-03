%11May18 NDB: Given an array of xy-data, find the total sum-of-squares
%residual error when a linear regression is performed on the data
function error = GetSegError(SegmentPoints)
    %~~~INPUTS~~~:
    %
    %SegmentPoints: a two-column array of data points with x in the 1st
    %   column and y in the second column
    %
    %######################################################################
    %
    %~~~OUTPUTS~~~:
    %
    %error: total error from linear regression of SegmentPoints (the sum of
    %   all the squared residuals)
    

    %Get best fit slope for data:
    covariance = NathansCovariance(SegmentPoints);
    %covariance = cov(SegmentPoints);
    
    %If all the points have the same x-value or all points have the same
    %y-value, then they perfectly fall along a line so set the error to
    %zero
    if covariance(1,1) == 0 || covariance(2,2) == 0
        error = 0;  
        
    %Else, do the linear regression to get the residuals
    else
        
        %The sum of the squared residuals can be calculated completely just
        %using the 4 elements of the covariance matrix I already calculated
        %(see https://en.wikipedia.org/wiki/Residual_sum_of_squares)
        error = covariance(2,2)*(1 - covariance(1,2)^2/(covariance(1,1)*covariance(2,2)));
        %error = (N-1)*covariance(2,2)*(1 - covariance(1,2)^2/(covariance(1,1)*covariance(2,2)));

    end
    
 
    
end
