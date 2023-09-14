function [x, rms_tc] = makeBPTC(F0, dL, dur, fs, rms_tc, db_drop_eqex, rank, nharms_total, nharms_pass, ramp, phi)
% Always have lots of harmonics (from 1 to 20, let's say)
% Use 223 Hz as F0
% Have a bandpass filter that is ~4-5 harmonics wide
% Have equal excitation noise until the lower edge of the bandpass filter at 10 dB below stimulus level.
% Move the lower edge of the bandpass filter up to increase harmonic rank
% Do a simple 3-AFC with one token per interval and ask which one is different. Keep the filter constant when introducing delta-F0
% No roving of anything

%TODO: FIX THE BW FOR FILTERING BASED ON A SECONDARY F0!!!

if ~exist('F0','var')
    F0 = 223;
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

if ~exist('db_tc','var')
    rms_tc = 0.10; % Sampling Rate
end

%if NaN, no noise.
if ~exist('db_drop_eqex','var')
    db_drop_eqex = 10;
end

if ~exist('rank','var')
    rank = 4;
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
end

%make nharms tone complex, amp is unity for all at this stage...be sure to
%scale based on RMS
freqs = (1:nharms_total)*F0*(1+dL/100); 
t = 0:1/fs:dur-1/fs;
tc = sum(sin(2*pi*freqs'*t+phi));

%Apply bandpass (should it be ideal or have roll-off?? edge pitch effects)
f_low = rank*F0;
f_high = (rank+nharms_pass-1)*F0;
% [b,a] = butter(4,[f_low,f_high]/(fs/2));

%Any need to constrain ripple/stopband attn?
Wp = [f_low,f_high]/(fs/2);
Ws = [f_low-F0,f_high+F0]/(fs/2);
[N, Wn] = buttord(Wp,Ws,1,6); 

[b,a] = butter(N,Wn);
tc_filt = filtfilt(b,a,tc);

%Scale to rms_tc...should the full 20 tone complex be scaled or the
%passband? I think after filtering is better
tc_filt = rms_tc*tc_filt/rms(tc_filt);
tc_filt = stimGen.rampsound(tc_filt,fs,ramp);

x = tc_filt;
%set rms of noise to be 
if ~isnan(db_drop_eqex)
    %bandwidth = ~0 Hz -> harmonic rank, fc should be half that.
    bw = f_low-1; %has to be 1 fft bin greater than 0 Hz, right?
    fcenter = .5*f_low;
    noise = stimGen.makeEqExNoiseFFT(bw,fcenter,dur,fs,ramp);
    rms_noise = db2mag(mag2db(rms_tc)-db_drop_eqex);
    noise = rms_noise*noise/rms(noise);

    x = noise'+x;
end



end

