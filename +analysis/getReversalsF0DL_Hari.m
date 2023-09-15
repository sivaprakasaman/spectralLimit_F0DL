function [thresh_mean,thresh_std] = getReversalsF0DL_Hari(responseList,range_F0DL,increm,to_plot)

if(~exist('plot_on','var'))
    plot_on = 0;
end

paramlist = responseList(:, 5);
revList = [];
downList = [];
upList = [];
nReversals = 0;
for k = 4:numel(paramlist)
    if((paramlist(k-1) > paramlist(k)) && (paramlist(k-1) == paramlist(k-2)) ...
            && (paramlist(k-2) > paramlist(k-3)))
        nReversals = nReversals + 1;
        revList = [revList, (k-1)]; %#ok<*AGROW> 
        downList = [downList, (k-1)];
    end
end

for k = 3:numel(paramlist)
    if((paramlist(k-1) < paramlist(k)) && (paramlist(k-1) < paramlist(k-2)))
        nReversals = nReversals + 1;
        revList = [revList, (k-1)];
        upList = [upList, (k-1)];
    end
end

for k = 4:numel(paramlist)
    if((paramlist(k-1) < paramlist(k)) ...
            && (paramlist(k-1) == paramlist(k-2)) ...
            && (paramlist(k-2) < paramlist(k-3)))
        nReversals = nReversals + 1;
        revList = [revList, (k-1)];
        upList = [upList, (k-1)];
    end
end

revList = sort(revList, 'ascend');
select = paramlist(revList(end-6:end));

%% Should be the same in trial audio and here for accurate thresholds
minparam = 1;
maxparam = increm;
params = minparam:maxparam;
% F0DLs = logspace(log10(range_F0DL(1)), log10(range_F0DL(2)), numel(params));

thresh_mean = mean(select);
thresh_std = std(select);

    if to_plot
        fprintf(['F0DL threshold = %0.000d', char(177),...
            ' %0.1d ', '% \n'],...
            thresh_mean, thresh_std);
        
        plot(F0DLs(paramlist), 'k-', 'linew', 2);
        hold on;
        plot(1:size(responseList,1)+2,ones(size(responseList,1)+2,1).*thresh_mean, 'r-','LineWidth', 2);
        plot(1:size(responseList,1)+2,ones(size(responseList,1)+2,1).*(thresh_mean + 1.96 * thresh_std), 'r--', 'LineWidth', 2);
        plot(1:size(responseList,1)+2,ones(size(responseList,1)+2,1).*(thresh_mean - 1.96 * thresh_std), 'r--', 'LineWidth', 2);
        
        set(gca, 'FontSize', 16);
        xlabel('Trial #', 'FontSize', 16);
        ylabel('F0DL', 'FontSize',16);
        legend('Adaptive Track', 'Estimated Threshold', ...
           '95% CI');
        text(numel(paramlist)/2, mean(F0DLs(paramlist)),...
            [num2str(thresh_mean), '%'] ,'FontSize', 16);
    end


end

