% Simple plot mostly for presentation purposes:

%Use same params from experiment
dur = 0.4;
isi = .25;
fs = 44e3;
sigrms = 0.2;
ramp = 0.02;
rank = 6;
nharms_total = 20;
f0 = 103;

%Alt phase phi
phi = ones(nharms_total, 1) * pi/2;
phi(1:2:end) = 0;
phi = phi + pi/4; % offset needed to ensure stim starts at zero during alt phase.


%make tone complex with no dif limen, no filter:

dL = 0;
freqs = (1:nharms_total)*f0*(1+dL/100); 
t = 0:1/fs:dur-1/fs;
tc = sum(sin(2*pi*freqs'*t+phi));
tc = tc*sigrms/rms(tc);
[Ptc, f] = pmtm(tc,5/4,[],fs);


nharms_pass = 4;
db_drop_eqex = nan;
[xbp, rms_tc] = stimGen.makeBPTC(f0, dL, dur, fs, sigrms, db_drop_eqex, rank, nharms_total, nharms_pass, ramp);
[Pbp, f] = pmtm(xbp,5/4,[],fs);

%ADDING MORE NOISE FOR EFFECT
db_drop_eqex = 20;
[x, rms_tc] = stimGen.makeBPTC(f0, dL, dur, fs, sigrms, db_drop_eqex, rank, nharms_total, nharms_pass, ramp);
[Px, f] = pmtm(x,5/4,[],fs);

%Adding a diff limen
dL = 20;
[xdL20, rms_tc] = stimGen.makeBPTC(f0, dL, dur, fs, sigrms, db_drop_eqex, rank, nharms_total, nharms_pass, ramp);
[PxdL20, f] = pmtm(xdL20,5/4,[],fs);

%Another diff limen
dL = 1;
[xdL1, rms_tc] = stimGen.makeBPTC(f0, dL, dur, fs, sigrms, db_drop_eqex, rank, nharms_total, nharms_pass, ramp);
[PxdL1, f] = pmtm(xdL1,5/4,[],fs);

%% Plotting:

posit = [1083 420 743 533];
set(0, 'DefaultFigureRenderer', 'painters');
set(0, 'defaultFigureUnits', 'pixels');
vert_lims = [1e-8,1e-2];

tc_only = figure();
plot(f,Ptc,'k','LineWidth',1.5);
set(gca,'YScale','log');
xlim([0,1400]);
ylim(vert_lims);
xlabel('Frequency (Hz)');
yticks([]);
ylabel('Amplitude');
title('Pure Tone Complex | F_0 = 103');
set(gcf,'Position',posit);

tc_bp = figure();
plot(f,Pbp,'Color',[0,0,0],'LineWidth',1.5);
set(gca,'YScale','log');
xlim([0,1400]);
ylim(vert_lims);
xlabel('Frequency (Hz)');
yticks([]);
ylabel('Amplitude');
title('Tone Complex_{bandpass} | F_0 = 103');
set(gcf,'Position',posit);

tc_noise = figure();
plot(f,Px,'Color',[0,0,0],'LineWidth',1.5);
set(gca,'YScale','log');
xlim([0,1400]);
ylim(vert_lims);
xlabel('Frequency (Hz)');
yticks([]);
ylabel('Amplitude');
title('Noise + Tone Complex_{bandpass} | F_0 = 103');
set(gcf,'Position',posit);

dl20 = figure();
hold on
plot(f,Px,'Color',[0,0,0],'LineWidth',1);
plot(f,PxdL20,'Color',[0.5,0,0.5,0.8],'LineWidth',1.5);

set(gca,'YScale','log');
xlim([0,1400]);
ylim(vert_lims);
xlabel('Frequency (Hz)');
yticks([]);
ylabel('Amplitude');
title('20% Pitch Change (F_0DL)| F_0 = 103');
set(gcf,'Position',posit);

dl1 = figure();
hold on
plot(f,Px,'Color',[0,0,0],'LineWidth',1);
plot(f,PxdL1,'Color',[0.5,0,0.5,0.8],'LineWidth',1.5);

set(gca,'YScale','log');
xlim([0,1400]);
ylim(vert_lims);
xlabel('Frequency (Hz)');
yticks([]);
ylabel('Amplitude');
title('1% Pitch Change (F_0DL)| F_0 = 103');
set(gcf,'Position',posit);

%% Save Figures
cd('example_sounds_figures')
print(tc_only,'tc_only','-dpng','-r300');
print(tc_bp,'tc_bp','-dpng','-r300');
print(tc_noise,'tc_noise','-dpng','-r300');
print(dl20,'dl20','-dpng','-r300');
print(dl1,'dl1','-dpng','-r300');
%% Save sounds

dl_20_out = [x,zeros(1,isi*fs),xdL20,zeros(1,isi*fs),x,zeros(1,isi*fs)];
dl_1_out = [x,zeros(isi*fs,1)',xdL1,zeros(1,isi*fs),x,zeros(1,isi*fs)];

audiowrite('tc.wav',tc,fs);
audiowrite('tc_bp.wav',xbp,fs);
audiowrite('tc_noise.wav',x,fs);
audiowrite('dl20.wav',dl_20_out,fs);
audiowrite('dl1.wav',dl_1_out,fs);


cd('../');


