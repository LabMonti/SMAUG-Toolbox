%NDB 22Apr2019: Makes a circular plot with that should look continuous
%using your continuous color scale.  If certain circles stand out to the
%eye, it's not a great choice of color map.  Inspired by EHT.  
function ColorMapTest(color_map)

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