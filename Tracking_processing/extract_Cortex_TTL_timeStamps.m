function [CortexTTLtimes_us,Cortex_timeStamps_local_us] = extract_Cortex_TTL_timeStamps(AnalogSignals,AnalogFrameRate)
% This script uses findpeaks to find the time points of the TTL in the
% extracted m.file you get from readC3D_analog 



Fs = AnalogFrameRate; % this is in Hz


% first create a vector of the local time stamps
Fs_us = 1000000/Fs; 
Cortex_timeStamps_local_us = 0:Fs_us:Fs_us*(length(AnalogSignals)-1); 

% find the peaks 

TTLch = AnalogSignals(:,2); 
TTLchPeaks = TTLch>1; 
TTLchDiff = diff(TTLchPeaks); 
TTLidx = find(TTLchDiff>0)+1; 
CortexTTLtimes = TTLidx./Fs; 
CortexTTLtimes_us = CortexTTLtimes*1000000; 

% plot results to see if it makes sense 
figure; 
subplot(2,1,2)
plot(diff(CortexTTLtimes),"*"); % this should be a flat line. if not there are some TTLs that are found a few samples off 
title('each peak is an offset from expected diff')
 
subplot(2,1,1)
plot(TTLch(Fs*60*1:Fs*60*2),'k') % plot first 5 min;
hold on
plot(TTLch(Fs*60*1:Fs*60*2),'k*') % plot first 5 min;

plot(TTLchPeaks(Fs*60*1:Fs*60*2),'b') % plot first 5 min;
plot(TTLchPeaks(Fs*60*1:Fs*60*2),'b*') % plot first 5 min;

plot(TTLchDiff(Fs*60*1:Fs*60*2),'g') % plot first 5 min; 
plot(TTLchDiff(Fs*60*1:Fs*60*2),'g*') % plot first 5 min; 
title('k=signal. b=k>1. g= estimated TTLtimeStamp')
ylim([0 2]) % change these for better viewing 
xlim([2000 2020]); % change these for better viewing 

