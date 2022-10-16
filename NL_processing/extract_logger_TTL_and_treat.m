
function [NL_TTL_local_corrected_us,DCZ_ts,VHC_ts] = extract_logger_TTL_and_treat(event_timestamps_usec,event_types_and_details)
% this script extract the TTL times from the NL event file 
% you need to load the events file saved from the extract_logger_data script 

% params:
defultTTL = 3e6; % what we exepcted the gap between TTLs to be
tolaranceFactor = 1.5; % a factor we use to determine when we missed a TTL


% find the rising edge (incoming TTL) timestamps: 
TTLRisingIdx = contains(event_types_and_details,'rising edge');
NL_TTL_local_us = event_timestamps_usec(TTLRisingIdx); 

% fix gaps of missted TTLs and put TTLs in them:
gapIdx = find(diff(NL_TTL_local_us)>defultTTL*tolaranceFactor); % we find diff between TTLs that is longer then expected
NL_TTL_local_corrected_us = NL_TTL_local_us'; 
Gapcounter = 0; 

while ~isempty(gapIdx)
NL_TTL_local_corrected_us = [NL_TTL_local_corrected_us(1:gapIdx(1)) NL_TTL_local_corrected_us(gapIdx(1))+defultTTL NL_TTL_local_corrected_us(gapIdx(1)+1:end)]; 
gapIdx = find(diff(NL_TTL_local_corrected_us)>defultTTL*tolaranceFactor); % idx number of the TTL before gap
Gapcounter = Gapcounter +1; 
end 

% plot the results to see the corrections 
plot(diff(NL_TTL_local_us),'*')
hold on; 
plot(diff(NL_TTL_local_corrected_us),'*')
ylabel('diff between TTLs (us)'); xlabel('sample number'); 
disp([num2str(Gapcounter),' missing TTLs found and fixed'])


% for DREADD bats - find if a treatment was given 
% assuming tokens: 'DCZ' or 'VHC' 

DCZ_ts = event_timestamps_usec(contains(event_types_and_details,'DCZ'));
VHC_ts = event_timestamps_usec(contains(event_types_and_details,'VHC'));


end 
