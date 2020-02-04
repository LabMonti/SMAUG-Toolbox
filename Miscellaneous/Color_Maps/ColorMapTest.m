function ColorMapTest(color_map)
    %Copyright 2020 LabMonti.  Written by Nathan Bamberger.  This work is 
    %licensed under the Creative Commons Attribution-NonCommercial 4.0 
    %International License. To view a copy of this license, visit 
    %http://creativecommons.org/licenses/by-nc/4.0/.  
    %
    %Function Description: Makes a circular plot with that should look 
    %continuous using your continuous color scale.  If certain circles 
    %stand out to the eye, it's not a great choice of color map.  Inspired 
    %by the EHT.  
    %
    %~~~INPUTS~~~:
    %
    %color_map: the name of a built-in MatLab color map, or a 3-column
    %   matrix containing a series of RGB values that define a custom color
    %   map
    
    N = 200;
    data = zeros(N, 3);
    counter = 0;
    for i = 1:N
        for j = 1:N
            counter = counter + 1;
            data(counter, 1) = i/N - 0.5;
            data(counter, 2) = j/N - 0.5;
            data(counter, 3) = sqrt((i/N - 0.5)^2 + (j/N - 0.5)^2);
            %max(abs(i/N - 0.5), abs(j/N - 0.5));            
        end
    end


    figure();
    scatter(data(:,1),data(:,2),10,data(:,3),'filled');
    colormap(color_map);
    colorbar();


end