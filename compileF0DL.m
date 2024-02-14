%NEEDS UPDATED!!!

clear 
close all

ranks = 2:2:12;
condition = "YNH";
type = "F0DL";
subj_list = ["S161","S311","S353","S360","S363","S364","S365"];
%% Logistics
cwd = pwd;

local = 0;
plot_on = 1;
discard_n = 0;
range_F0DL = [.15,30];
increm = 50;
ytik = logspace(log10(range_F0DL(1)), log10(range_F0DL(2)), increm); %F0DL to test
ytik = ytik(1:9:end);
ytik = round(ytik,2);
ylabs = num2str(ytik);

if ispc && ~local
    %figure out what's best later
    prefix = 'A:/Pitch_Study/Pitch_Diagnostics_SH_AS/F0DL/Human/';
elseif ~local
    [~,uname] = unix('whoami');
    uname = uname(1:end-1);
    prefix = ['/media/',uname,'/AndrewNVME/Pitch_Study/Pitch_Diagnostics_SH_AS/F0DL/Human/'];
else
    prefix = '../../../../Data/';
end 


%% Sigmoidal Fxn Fit Model Params:
x = 0:0.1:15;
maximum = 1.2;
mid =6;
steep = 1.3;
start = 0.01;
sigmoid = 'a./(1+exp(-b*(x-c)))+d';
startPoints = [maximum, steep, mid, start];
fops = fitoptions('Method','NonlinearLeastSquares','Lower',[0, 0, 1, 0],'Upper',[inf, inf, 15, inf],'StartPoint',startPoints);
ft = fittype(sigmoid,'options',fops);

%% 
for s = 1:length(subj_list)

    suffix = [char(condition),'/',char(subj_list(s)),'/Processed'];
    datapath = [prefix,suffix];
    cd(datapath)
    
    filename = dir(strcat(subj_list(s),'*F0DL*')).name;
    disp(['loading ', filename]);
    load(filename);
    
    dataGeo = analysis.squeezeMean(output_geo,1);
    dataHari = analysis.squeezeMean(output_hari,1);
    
    all_means_geo(:,s) = dataGeo(:,2);
    all_stds_geo(:,s) = dataGeo(:,3);
    fit_subj = fit(ranks', all_means_geo(:,s),ft);
    sig_model_geo_all(:,s) = fit_subj(x);

    all_means_hari(:,s) = dataHari(:,2);
    all_stds_hari(:,s) = dataHari(:,3);
    sig_model_hari_all(:,s) = sig_model_hari;
    
end

cd(cwd)

%% Sigmoidal fit
mean_only_geo = mean(all_means_geo,2);
% mean_only_geo = 10.^mean_only_geo;
std_geo = std(all_means_geo')/sqrt(length(subj_list));
% std_geo = 10.^std_geo;

mean_only_hari = mean(all_means_hari,2);
std_hari = std(all_means_hari');

sig_fit_geo = fit(ranks', mean_only_geo,ft);
sig_fit_hari = fit(ranks', mean_only_hari, ft);

sig_model_geo = sig_fit_geo(x);
sig_model_hari = sig_fit_hari(x);

%% Making figure

clr_amajo = [0.6350, 0.0780, 0.1840];
clr_amajo = [0 0 0];
clr_hari = [0, 0.4470, 0.7410];
clr_plt = [0.4660, 0.6740, 0.1880];

err_geo = std_geo';
pool_F0DL_fig = figure;
tick_arr = [2:4:30];

hold on
errorbar(ranks, mean_only_geo,err_geo,'sq','color',clr_plt,'markerSize',12,'linewidth',2);
% errorbar(ranks+0.5, mean_only_hari,std_hari','sq','color',clr_hari,'markerSize',10,'linewidth',2);
plot(x,sig_model_geo,'--','Color',[clr_amajo,.7],'Linewidth',4)

legend('F0DL','Sigmoidal Fit','Location','SouthEast');
% xticks = ranks+0.5;
% xticklabels(xticks);
xlim([min(ranks)-1, max(ranks)+1]);
ylim([-.0001,log10(20)]);
yticks(log10(tick_arr));
yticklabels(tick_arr);
% set(gca,'yscale','log');
% title(['Pooled F0DL | N = ',num2str(length(subj_list))],'FontWeight','bold');
title('Behavioral Transition Point')
xlabel('Harmonic Rank','FontWeight','bold');
ylabel('F0DL (%)','FontWeight','bold');
set(findall(gcf,'-property','FontSize'),'FontSize',17)
grid on
hold off

set(gcf,'position',[1445 464 859 814]);
% print(gcf,'AllF0DL_updated.png','-dpng','-r300')

%% Combined Figure
n_panels = length(subj_list)+1;
all_plots = tiledlayout(2, ceil(n_panels/2),'TileSpacing','compact');


for l = 1:(n_panels-1)
    nexttile;
    hold on
    errorbar(ranks,all_means_geo(:,l),all_stds_geo(:,l),'.','color',[1,1,1]*.3,'markerSize',13,'linewidth',1.5);
    plot(x,sig_model_geo_all(:,l),'Color',[0,0,0,0.5],'linewidth',2);
    hold off
    title(subj_list(l));
    xticks(ranks);
    yticks([1,2:4:30]);
    xlim([0,15]);
    ylim([-1,log10(32)]);
    yticks(log10(tick_arr));
    yticklabels(tick_arr);
    grid on;
    set(gca,'FontSize',11)
end

xlabel(all_plots,'Harmonic Rank','FontWeight','bold','FontSize',15);
ylabel(all_plots,'F0DL (%)','FontWeight','bold','FontSize',15);
title(all_plots,['F0DL across N = ',num2str(length(subj_list))],'FontWeight','bold','FontSize',16);

nexttile;
title('Mean')
hold on
errorbar(ranks+0.5, mean_only_geo,std_geo','.','color',[1,1,1]*.4,'markerSize',13,'linewidth',1.5);
plot(x,sig_model_geo,'Color','k','Linewidth',3)
legend('F0DL','Sigmoidal Fit','Location','Northwest');
% xticklabels(xticks);
xticks(ranks);
yticks([1,2:4:30]);
xlim([0,15]);
ylim([-.001,log10(20)]);
yticks(log10(tick_arr));
yticklabels(tick_arr);
set(gca,'FontSize',11)
box on

grid on
hold off
set(gcf,"Position",[1081 91 1447 870]);

%% Saving
if ~exist('output_figs','dir')
    mkdir('output_figs');
end

cd('output_figs')
fname = strcat(condition,'_ALL_F0DL_Processed.mat');
exportgraphics(all_plots,'all_subj_F0DL.png','Resolution',300);
save(fname,'all_means_geo','all_means_hari','all_stds_geo','all_stds_geo','x','sig_model_geo','sig_model_hari','mean_only_geo','mean_only_hari','err_geo','ranks')
print(pool_F0DL_fig,[char(condition),'_F0DL_compiled.png'],'-dpng','-r300')
cd(cwd)
