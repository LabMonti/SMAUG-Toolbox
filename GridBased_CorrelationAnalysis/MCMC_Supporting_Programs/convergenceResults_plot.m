function convergenceResults_plot(Rhats,ConvergenceTable,legend_names)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Creates a plot to display how well-converged the
    %MCMC results for a parallel-tempering run are for each temperature's
    %sub-chain. This function needs the convergence calculations themselves
    %to have been already computed, and passed in--this just does the
    %plotting. Convergence of each node's probability of being in the
    %distribution is evaluated using a value called Rhat, which is
    %described elsewhere. This function computes histograms of the Rhat
    %values for all the nodes at each temperature, and those histograms are
    %what are displayed.
    %
    %~~~INPUTS~~~:
    %
    %Rhats: an nTemps-long cell array, with each cell containing a vector
    %   of Rhat values for all the different nodes at each temperature.
    %   Only nodes that appears in at least 0.1% of steps have had Rhat
    %   values computed for them, so all vectors will not be of the same
    %   length.
    %
    %ConvergenceTable: a table containing summary statistics on Rhat values
    %   at each temperature, which together with some specified criteria
    %   have been used to determine whether each temperature "passes" or
    %   "fails" convergence
    %
    %legend_names: cell array containing names for each MCMC sub-chain,
    %   which will be used as labels in the plot's legend
    
    
    nTemps = length(Rhats);
    if nargin < 3
        legend_names = cell(nTemps,1);
        for i = 1:nTemps
            legend_names{i} = strcat('Temperature #',num2str(i));
        end
    end
        
    %Generate the same set of bin edges for all temperatures
    bin_width = 2*iqr(Rhats{1}(:,1))*length(Rhats{1}(:,1))^(-1/3);
    
    %Get absolute max and min values:
    mm = Inf;
    MM = -Inf;
    for i = 1:nTemps
        m = min(Rhats{i}(:,1));
        M = max(Rhats{i}(:,1));
        if m < mm
            mm = m;
        end
        if M > MM
            MM = M;
        end
    end
    
    %Make sure bin width doesn't get too small (can cause a too-large array
    %to be requested!)
    min_width = (MM - mm)/10000;
    bin_width = max([min_width bin_width]);
    
    %Make sure bin width isn't smaller than range!
    if (MM - mm) > bin_width
        mm = mm - 2*bin_width;
        MM = MM + 2*bin_width;
    end
    
    bin_edges = (mm:bin_width:MM);        

    %Make the overlaid histograms
    figure();
    hold on;
    for i = 1:nTemps
        [counts,centers] = hist(Rhats{i}(:,1),bin_edges);
        [x,y] = convert_to_histogram_endpoints(centers,counts);
        plot(x,y);
    end    
    xlabel('R_{hat} Ratio');
    ylabel('# of Nodes');
    legend(legend_names);
    xlim([1 prctile(Rhats{1}(:,1),98)]);
    title('Within-Chain Convergence Evaluation');

    %Display the table
    disp(ConvergenceTable); 
    
    %Add pass/fail to plot:
    a = gca;
    XL = a.XLim;
    YL = a.YLim;
    xstart = XL(1) + range(XL)*0.7;
    ystart0 = YL(1) + range(YL)*0.4;
    hold on;
    text(xstart,ystart0+0.05*range(YL),'Convergence Criteria Pass/Fail:',...
        'HorizontalAlignment','center');
    for i = 1:nTemps
        text(xstart,ystart0-(i-1)*0.05*range(YL),ConvergenceTable{i,5}{1},...
            'HorizontalAlignment','center','Color',a.ColorOrder(i,:));
    end
  
end