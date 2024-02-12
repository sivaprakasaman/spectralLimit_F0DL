function [output] = squeezeMean(input, log_flag)
%based on first column, mean rows with same val in col1
%returns 4 column matrix with val, mean, std, and N 
c1 = unique(input(:,1));

    for i = 1:length(c1)
        
       vals = input(input(:,1)==c1(i),2);
       mn = mean(vals);
       st = std(vals);
       n = length(vals);

       if log_flag
           log_vals = log10(vals);
           mn = mean(log_vals);
           st = std(log_vals);
       end

       output(i,:) = [c1(i),mn,st,n];



    end

end

