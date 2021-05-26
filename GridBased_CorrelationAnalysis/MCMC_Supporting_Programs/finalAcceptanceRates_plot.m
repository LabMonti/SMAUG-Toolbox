function finalAcceptanceRates_plot(AcceptedAndRejected,legend_names)

    nTemps = length(AcceptedAndRejected);

    %Make a bar chart to show the acceptance rate for each type of step for
    %each temperature
    nStepTypes = 7;
    FinalRates = zeros(nStepTypes+1,nTemps);
    for i = 1:nTemps
        for j = 1:nStepTypes
            FinalRates(j,i) = AcceptedAndRejected{i}(j,2)/sum(AcceptedAndRejected{i}(j,:));
        end
        FinalRates(nStepTypes+1,i) = sum(AcceptedAndRejected{i}(:,2))/sum(sum(AcceptedAndRejected{i}));
    end
    
    figure();
    bar(FinalRates);
    xticks((1:nStepTypes+1));
    xticklabels({'SingleShift','RigidShift','SplitShift','ScrambleShift',...
        'RigidTranslate','SnakeTranslate','SwapChains','Total'});
    xtickangle(90);
    xlabel('Type of Step');
    ylabel('Acceptance Rate');
    legend(legend_names);

end