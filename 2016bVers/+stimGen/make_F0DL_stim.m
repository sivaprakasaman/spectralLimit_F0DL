function [x, sigrms] = make_F0DL_stim(F0, dur, fs, db_main, db_flank, sigrms, rank, nharms, ramp, phi, noise_on, rove)

if(~exist('fs','var'))
    fs = 48828.125; % Sampling Rate
end

if(~exist('db_main','var'))
    db_main = 75; % dB of 10 middle tones
end

if(~exist('db_flank','var'))
    db_flank = 69; % dB of 2 flanked tones
end

if(~exist('sigrms','var'))
    sigrms = 0.02;
end

if(~exist('rank','var'))
    rank = 10; % dB of 2 flanked tones
end

if(~exist('nharms','var'))
    nharms = 10;
end

if(~exist('dur','var'))
    dur = 1; % Duration in Seconds
end

if(~exist('ramp','var'))
    ramp = 0.030; %In seconds
end

if(~exist('F0','var'))
    F0 = 103;
end

if(~exist('phi','var'))
    phi = ones(nharms+2, 1) * pi/2; % Sin for all harmonics
end

if(~exist('noise_on','var'))
    noise_on = 1; % noise on by default
end

if(~exist('rove','var'))
    rove = 0; % noise off by default
end

t = 0:(1/fs):(dur - 1/fs);
x = 0;

harmonics = (rank-1):(rank+nharms);

start = 1;

%rove bottom harmonic
if rove
    %it's one of these...figure out which
    harmonics = harmonics + 1;
end

for k = start:length(harmonics)
    
    if(k==1 || k==length(harmonics))
        mag = db2mag(db_flank); 
    else
        mag = db2mag(db_main);
    end
    
    x = x + mag*cos(2*pi*F0*harmonics(k)*t + phi(k));

end
sig_dB_overall = log10(nharms*10^(db_main/10) + 2*10^(db_flank/10))*10;
x = x / rms(x) * sigrms;

short_ramp = 0.01;
x = rampsound(x,fs,short_ramp);

%parameterize this at some point
if noise_on
    %set noise at 30 dB below tone complex level.
    db_noise_lf = -30; 

    f_low = 20;
%     f_high = 20000;
    f_high_lf = harmonics(1)*F0*2^(-1/2); %for dp masking noise, low pass below half octave below nominal freq.
    buff = 0.01;
    tmax = dur + buff;
    x = [zeros(1,round(fs*buff)),x];
    noise = rand(length(x),1)-.5; %uniformly distributed;
    noise = noise/rms(noise)*sigrms;

    rms_noise = sigrms*db2mag(db_noise_lf);

    % Scale is arbitrary
%     [noise, ratio_1k_dB] = TE_noise(tmax*1000,f_low,f_high,db_noise,0,fs);
%     noise = rand(tmax*fs,1); %uniformly distributed;
%     noise = noise(1:numel(x)); %truncate by a sample if rounded differently
%     SNR_desired_dB = sig_dB_overall - (db_noise + ratio_1k_dB);
% 
% 
%     noise = noise / rms(noise) * db2mag(-SNR_desired_dB)*sigrms;
%     
%     %Create the dp-masking noise
%     [noise2, ~] = TE_noise(tmax*1000,f_low,f_high,db_noise,0,fs);
%     noise2 = noise2(1:numel(x));
%     noise2 = noise2 / rms(noise2) * db2mag(-SNR_desired_dB)*sigrms;
%     scaleFact = db2mag(db_noise_lf-db_noise);
%     dp_noise = scaleFact*noise2;
    %limiting cutoff to a max of 500 Hz
    if f_high_lf>=500
        f_high_lf = 500;
    end
    [b,a] = butter(4,f_high_lf/(fs/2),'low');
    dp_noise = filtfilt(b,a,noise);
    dp_noise = dp_noise/rms(dp_noise) * rms_noise;

    x = x + dp_noise';
    
end

x = rampsound(x,fs,ramp);

end

