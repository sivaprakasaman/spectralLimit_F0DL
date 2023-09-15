%Calculate F0DL% as the Geometric mean at the last 6 reverals
%TODO:
% - Make sure sorted by time!!!!
% - Allow for 2nd set of trials to be discarded
% - How many reversals by Hari? Should we use geometric mean?
% - Clean up the code some point
% - figure out what data to export

clear
close all

cwd = pwd;
warning('off');

addpath(pwd)
subj = 'test';
% local = 0;
plot_on = 1;
discard_n = 0; %discard n rounds of trials
range_F0DL = [.25,20];
increm = 40;
ytik = logspace(log10(range_F0DL(1)), log10(range_F0DL(2)), increm); %F0DL to test
ytik = ytik(1:9:end);
ytik = round(ytik,2);
ylabs = num2str(ytik);

datapath = ['Results/',subj];
cd(datapath)

files = {dir(fullfile(cd,'*.mat')).name};
[~,ind] = sort({dir(fullfile(cd,'*.mat')).date});
files = files(ind);

nfiles = length(files);
tcount = zeros(1,20); %assumed max

if plot_on
    f0DL_fig = figure;
    clr_resp = [.25,.25,.25];
    clr_amajo = [0.6350, 0.0780, 0.1840];
    clr_hari = [0, 0.4470, 0.7410];
    alps = ones(nfiles,1);
    alps(2:2:end) = .5;
end

for j = 1:nfiles
    file = files(j);
    load(file{1});
    rank = sscanf(file{1},[subj,'_Rank_%d']);

    tcount(rank) = tcount(rank)+1;

    if tcount(rank)>discard_n
        output_geo(j,1) = rank;
        output_hari(j,1) = rank;

        responses = responseList(:,5);

        mn1 = getReversalsF0DL_AMAJO(responses,0);
        [mn2, std2] = getReversalsF0DL_Hari(responseList,range_F0DL,increm,0);

        conf2 = 1.96*std2;

        output_geo(j,2) = mn1;
        output_hari(j,2) = mn2;
        conf_hari(j,3) = conf2;

        %plotting
        if plot_on
            lin = ones(1,length(responses));
            mn1_lin = lin.*mn1;
            mn2_lin = lin.*mn2;
                
            figure(f0DL_fig);
            subplot(2,4,rank/2)
            hold on
            plot(responses*100,'linewidth',2,'color',[clr_resp, tcount(rank)*.3]);
            plot(mn1_lin,'color',clr_amajo);
            plot(mn2_lin,'color',clr_hari);
            title(['Rank = ',num2str(rank+.5)]); %add .5 because of roving
            ylim(range_F0DL)
            yticks(ytik);
            yticklabels(ytik);
            set(gca,'yscale','log')
            grid on
            box on
            if rank == 12
                legend('Run 1','','','Run 2','Location','SouthEast')
            end
            hold off
        end
    end

end

%sort to get rank
[B,I] = sort(output_geo(:,1));
output_geo(:,2) = output_geo(I,2);
output_geo(:,1) = B;

output_hari(:,2) = output_hari(I,2);
output_hari(:,1) = B;


%% Calculate estimated psychometric function for mean of runs

%consolidate runs
means_geo = squeezeMean(output_geo);
means_geo = means_geo(:,1:2);
means_hari = squeezeMean(output_hari);
means_hari = means_hari(:,1:2);
ranks = unique(means_geo(:,1))+0.5;
xtik = ranks;

%Sigmoidal fit
x = 0:0.1:15;
maximum = 1.2;
mid =6;
steep = 1.3;
start = 0.01;
sigmoid = 'a./(1+exp(-b*(x-c)))+d';
startPoints = [maximum, steep, mid, start];
fops = fitoptions('Method','NonlinearLeastSquares','Lower',[0, 0, 1, 0],'Upper',[inf, inf, 15, inf],'StartPoint',startPoints);
ft = fittype(sigmoid,'options',fops);

sig_fit_geo = fit(means_geo(:,1)+.5, means_geo(:,2),ft);
sig_fit_hari = fit(means_hari(:,1)+.5, means_hari(:,2), ft);

sig_model_geo = sig_fit_geo(x);
sig_model_hari = sig_fit_hari(x);

if plot_on
    figure(f0DL_fig);
    subplot(2,4,[7,8]);
    hold on
    plot(ranks,means_geo(:,2),'.','color',clr_amajo,'MarkerSize',12);
    plot(ranks, means_hari(:,2),'.','color',clr_hari,'MarkerSize',12);
    plot(x, sig_model_geo,'Color',clr_amajo,'LineWidth',1.5);
    plot(x, sig_model_hari,'Color',clr_hari,'LineWidth',1.5);

    plot(output_geo(:,1)+.5,output_geo(:,2),'+','color',[clr_amajo],'MarkerSize',3);
    plot(output_hari(:,1)+.5,output_hari(:,2),'+','color',[clr_hari],'MarkerSize',3);
    hold off

    legend('Method 1','Method 2','Location','SouthEast');
    xticks = ranks;
    xlim([min(ranks)-1, max(ranks)+1]);
    set(gca,'yscale','log');
    title('Sigmoidal Fit','FontWeight','bold');
    xlabel('Harmonic Rank','FontWeight','bold');
    ylabel('F0DL (%)','FontWeight','bold');

    sgtitle(['Subject: ', subj]);
    set(f0DL_fig,'Position',[575 354 1123 611]);
    han=axes(f0DL_fig,'visible','off');
    han.XLabel.Visible='on';
    han.YLabel.Visible='on';
    ylabel(han,'\Delta F (%)','FontWeight','bold');
    xlabel(han,'Trial #','FontWeight','bold');
    set(findall(gcf,'-property','FontSize'),'FontSize',12)
end

%
% if ~exist('../Processed','dir')
%     mkdir('../Processed');
% end

% cd('../Processed')
% fname = strcat("PROCESSED_",dirs(i),".mat");
% save(fname,'output')
% clear output
% cd ../


cd(cwd)