function [mn] = getReversalsF0DL_AMAJO(responses, plot_on)
%Gets the geometric mean of the last correct f0dl before reversal

if(~exist('plot_on','var'))
    plot_on = 0;
end

% load(datafile);

mlist = responses'; %convert to percent

reversals = zeros(1,length(mlist));
goingDown = 1;

%take derivative, truncate first value
deriv = [mlist,0]-[0,mlist];
deriv = deriv(2:end);

%simplify by making it a slope direction instead of value
pos = 1*(deriv>0);
neg = -1*(deriv<0);
slope_dir = pos+neg;

lastVal = -1; %assume first reversal is upwards.
for i = 1:length(slope_dir)
    %account for N down N up paradigms
     if slope_dir(i)~=0
         if slope_dir(i) ~= lastVal
            reversals(i) = 1;
            lastVal = slope_dir(i);
         end
     end
end

f0dls = mlist(reversals==1);
mn = geomean(f0dls((end-5):end));

if plot_on
    
    plot(mlist,'*')
    hold on
    plot(mlist.*reversals,'ro','MarkerSize',10,'LineWidth',2);
    ylim([0.01,20])
    plot(1:length(mlist),mn*ones(1,length(mlist)),'k','linewidth',2)

    ylabel('F0DL (%)');
    xlabel('Trial');
    hold off
end


end