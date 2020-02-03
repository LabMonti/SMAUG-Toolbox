%NDB 05Feb2019: Given some x and y data representing histogram centers and
%heights, respectively, generate the x and y data that will make a plot
%with a stair-steppy pattern instead of a normal plot
function [xOut, yOut] = convert_to_histogram_endpoints(xdata, ydata)

    N = length(xdata);
    step = (xdata(2) - xdata(1))/2;
    
    xOut = zeros(2*N+2,1);
    yOut = zeros(2*N+2,1);
    
    %Fill in first point at zero:
    xOut(1) = xdata(1) - step;
    yOut(1) = 0;
    
    %Fill in all other points
    for i = 1:N
        xOut(2*i) = xdata(i) - step;
        xOut(2*i+1) = xdata(i) + step;
        
        yOut(2*i) = ydata(i);
        yOut(2*i+1) = ydata(i);
    end
    
    %Fill in last point at zero:
    xOut(2*N+2) = xdata(N) + step;
    yOut(2*N+2) = 0;

end