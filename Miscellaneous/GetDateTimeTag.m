function date_time_tag = GetDateTimeTag()

    %Get current time and date as nice string
    t = clock();
    year = num2str(t(1));
    year = year(3:4);
    if t(2) < 10
        month = strcat('0',num2str(t(2)));
    else
        month = strcat(num2str(t(2)));
    end
    if t(3) < 10
        day = strcat('0',num2str(t(3)));
    else
        day = strcat(num2str(t(3)));
    end    
    if t(4) < 10
        hour = strcat('0',num2str(t(4)));
    else
        hour = strcat(num2str(t(4)));
    end        
    if t(5) < 10
        minute = strcat('0',num2str(t(5)));
    else
        minute = strcat(num2str(t(5)));
    end        
    date_time_tag = strcat(year,month,day,'_',hour,minute);


end