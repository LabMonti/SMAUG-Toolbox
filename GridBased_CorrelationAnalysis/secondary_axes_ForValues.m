function secondary_axes_ForValues(GCO)
    %Copyright 2021 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: If a 2D plot of inter-electrode distance grid #
    %vs. log(G0) grid # has already been created, this function adds
    %secondary x- and y-axes to show the actual inter-electrode distance
    %and log(G0) values across from the grid #s. Should work whether or not
    %the orginal plot has a color bar. 
    %
    %~~~INPUTS~~~:
    %
    %GCO: The GridCorrelationObject for the dataset that the existing 2D
    %   plot is of (used to get Xstep, Xstart, Ystep, and Ystart info)
    
    
    %First of all we need a handle to the current set of axes; also get
    %it's limits
    a = gca;
    XL = a.XLim;
    YL = a.YLim;
    
    %First we add the secondary y-axis
    yyaxis('right');
    ylabel('Log(Conductance/G_0)','Rotation',270,'VerticalAlignment','bottom');
    ylim(YL*GCO.Ystep + GCO.Ystart);   
    a.YAxis(2).Color = [0 0 0];
    yyaxis('left');       
    
    %Now we add the secondary x-axis on the top
    a.Position(4) = a.Position(4) * 0.95; %Shrink slightly to fit in secondard x axis's label
    ax1_pos = a.Position;
    new_pos = [ax1_pos(1), ax1_pos(2) + 0.9*ax1_pos(4), ax1_pos(3), ...
        ax1_pos(4)*0.1];
    a2 = axes('Position',new_pos,'XAxisLocation','top','YAxisLocation',...
        'right','Color','none');    
    a2.YAxis.Visible = 'off';
    a2.XAxis.FontSize = a.XAxis.FontSize;
    xlim(XL*GCO.Xstep + GCO.Xstart);
    xlabel('Inter-Electrode Distance (nm)');

    %Important!  At the end we should re-set the current set of axes to be
    %the original axes, so that, for example, the caxis command by the user
    %will correctly update the colorbar
    axes(a);
    
    %We also need to make sure Matlab didn't try to change the axes limits
    %for this original set of axes
    a.XLim = XL;
    a.YLim = YL;
    
    %And NOW we can move the second set of axes to the front (so that the
    %tics are visible). If we had done this earlier, the axes command above
    %would have reset the order. 
    uistack(a2,'top');
    
end