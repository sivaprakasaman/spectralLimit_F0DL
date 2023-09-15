function [x, rms_tc] = makeBPTC(F0, dL, dur, fs, rms_tc, db_drop_eqex, rank, nharms_total, nharms_pass, ramp, phi)
% Tone Complex with spectral envelope fixed based on a given F0 freq.
% F0 - Fundamental Frequency to set as reference, filter bandwidth is then
% set by nharms_pass
% dL - difference limen to add to the F0 (keep in mind filter bandwidth
% stays the same. dL = 0 = F0
% dur - tone duration in sec
% fs - Sample Rate
% rms_tc - tone complex (in absence of noise) rms.
% db_drop_eqex - how much to lower the noise in dB relative to tone
% complex rms
% rank = harmonic rank to test (higher rank adjusts increases bottom edge
% of spectral envelope and high edge of the equal excitation noise)
% nharms_pass = how many harmonics of F0 wide to make the passband
% ramp = ramp on/off in secs
% phi = phase of tone complex. 

if ~exist('F0','var')
    F0 = 103;
end

%in percent!!
if ~exist('dL','var')
    dL = 0;
end


if ~exist('dur','var')
    dur = 1;
end

if ~exist('fs','var')
    fs = 48828.125; % Sampling Rate
end

if ~exist('rms_tc','var')
    rms_tc = 0.20; % Sampling Rate
end

%if NaN, no noise.
if ~exist('db_drop_eqex','var')
    db_drop_eqex = 10;
end

if ~exist('rank','var')
    rank = 12;
end

if ~exist('nharms_total','var')
    nharms_total = 20;
end

if ~exist('nharms_pass','var')
    nharms_pass = 4;
end

if(~exist('ramp','var'))
    ramp = 0.030; %In seconds
end

if(~exist('phi','var'))
    phi = ones(nharms_total, 1) * pi/2; 
    phi(1:2:end) = 0; %defaults to ALT
    phi = phi + pi/4; % offset needed to ensure stim starts at zero during alt phase.
end

%make nharms tone complex, amp is unity for all at this stage...be sure to
%scale based on RMS
freqs = (1:nharms_total)*F0*(1+dL/100); 
t = 0:1/fs:dur-1/fs;
tc = sum(sin(2*pi*freqs'*t+phi));

%Apply bandpass 4th order, filtfilt will make it 8th order
f_low = rank*F0;
f_high = (rank+nharms_pass-1)*F0;
[b,a] = butter(4,[f_low,f_high]/(fs/2));

tc_filt = filtfilt(b,a,tc);

%Scale tone complex to rms_tc...
tc_filt = rms_tc*tc_filt/rms(tc_filt);
x = tc_filt;

%set rms of noise to be 
if ~isnan(db_drop_eqex)
    %bandwidth = ~0 Hz -> harmonic rank, fc should be half that.
    bw = f_low - 1; %has to be 1 fft bin greater than 0 Hz, right?
    fcenter = .5*(f_low);
    noise = stimGen.makeEqExNoiseFFT(bw,fcenter,dur,fs,ramp);
    rms_noise = db2mag(mag2db(rms_tc)-db_drop_eqex);
    noise = rms_noise*noise/rms(noise);

    x = noise'+x;
end

x = stimGen.rampsound(x,fs,ramp);

end

