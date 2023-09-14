clear;
clc;

%% Seed rng
load('s.mat');
rng(s);

%%

Nfiles = 6; % Number of files per parameter level
minparam = 1;
maxparam = 50;
params = minparam:maxparam;
m = logspace(log10(.15), log10(20), numel(params)); %F0DL to test
dur = 0.4;
isi = .25;
fs = 48828.125;
sigrms = 0.020;
ramp = 0.02;
db_drop_eqex = 10;
ranks = [2];
nharms_total = 20;
nharms_pass = 4;
f0 = 223;
dirs = [-1,1];

%Alt phase
phi = ones(nharms_total, 1) * pi/2;
phi(1:2:end) = 0;
phi = phi + pi/4; % offset needed to ensure stim starts at zero during alt phase.

ind = 0;

if ~exist('trialaudio','dir')
    mkdir('trialaudio');
end

for r = 1:length(ranks)
    rank = ranks(r);
    for k = 1:numel(params)
        difLimen = m(k);
        for nf = 1:Nfiles
            answer = randi(3);
            direction = dirs(randi(2));
            param = params(k);
            
            ind = ind + 1;

            direction_check(ind) = direction;
            choice_check(ind) = answer;
                
            %randomize (no replacement up/down)
            [dummy, ~] = stimGen.makeBPTC(f0,0,dur,fs,sigrms,db_drop_eqex,rank,nharms_total,nharms_pass,ramp,phi);
            [sig, ~] = stimGen.makeBPTC(f0,direction*difLimen,dur,fs,sigrms,db_drop_eqex,rank,nharms_total,nharms_pass,ramp,phi);
            
            buff = zeros(1,round(isi*fs));
            sig = [sig, buff];
            dummy = [dummy,buff];

            switch answer
                case 1
                    y = [sig, dummy, dummy];
                case 2
                    y = [dummy, sig, dummy];
                case 3
                    y = [dummy, dummy, sig];
            end

            fname = strcat('./trialaudio/trial',num2str(param),...
                '_',num2str(rank),'_', num2str(nf), '.mat');
            save(fname, 'y', 'fs', 'difLimen','sigrms', 'direction','rank','phi','nharms_total','nharms_pass','db_drop_eqex', 'param', 'answer');
            
            disp(['File ', num2str(ind), ' of ', num2str(length(ranks)*length(params)*Nfiles)]);
            clear dummy sig
        end
    end

end

figure;
histogram(choice_check);
title('Correct Choice');
xticks([1,2,3]);

figure;
histogram(direction_check);
title('Direction Check')
xticks([-1,1])

