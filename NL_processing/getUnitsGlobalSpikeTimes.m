function SpikeData = getUnitsGlobalSpikeTimes(workingDir,date,batID)
% this function takes the sorted spike times of all the units in a dir, and gets the global time stamp for all of them, as well as the treatment ts.
% INPUT: the dir with the extracted data from a logger for a date. the date of the exp
% this folder should also contain a folder named 'sorted_units' that has the mat files of  spiketimes for indevidual sorted units. 
% OUTPUT: the global ts for units and treatment (and the TTLs). all in sec (convereted from us) 

% dependent sciripts: 
% 1.extract_logger_TTL_and_treat
% 2.local2GlobalTime 

% first load the event file  
EventsDir = dir([workingDir,'\*EVENTS.mat']); 
load([EventsDir(1).folder,filesep,EventsDir(1).name])

% now use the events data we loaded to get the TTL signal and treat ts: 
[NL_TTL_local_corrected_us,DCZ_ts,VHC_ts] = extract_logger_TTL_and_treat(event_timestamps_usec,event_types_and_details);

% now use the TTLs to get the global timestamp for DCZ or VHC treat 

global_VHC_ts_Sec = []; global_DCZ_ts_Sec = []; 
if ~isempty(DCZ_ts)
    [global_DCZ_timestamps_usec] = local2GlobalTime(NL_TTL_local_corrected_us,DCZ_ts);
    global_DCZ_ts_Sec = global_DCZ_timestamps_usec/1e6;  
    elseif ~isempty(VHC_ts)
    [global_VHC_timestamps_usec] = local2GlobalTime(NL_TTL_local_corrected_us,DCZ_ts);    
    global_VHC_ts_Sec = global_VHC_timestamps_usec/1e6;
    else 
    disp('no treatment token found for this day')
end 

% now use the TTLs to get the global Spike times for the units: 
    UnitFiles = dir([workingDir,'\sorted_units\','\*.mat']);
    for unitNum = 1:length(UnitFiles)
    
        load([UnitFiles(unitNum).folder, filesep, UnitFiles(unitNum).name])   
        
        [global_Spikes_timestamps_usec] = local2GlobalTime(NL_TTL_local_corrected_us,Spike_arrival_times);
        global_SpikesTimes_Sec = global_Spikes_timestamps_usec/1e6;  %
        global_SpikeTimes_Sec_all{unitNum} = global_SpikesTimes_Sec;    
    
    end 

    % gather results to a SpikeData structure:
SpikeData.global_SpikeTimes_Sec_all = global_SpikeTimes_Sec_all; 
SpikeData.global_DCZ_ts_Sec = global_DCZ_ts_Sec; 
SpikeData.global_VHC_ts_Sec = global_VHC_ts_Sec; 
SpikeData.NL_TTL_local_corrected_us = NL_TTL_local_corrected_us; 
SpikeData.date = date; 
SpikeData.Dir = workingDir; 
SpikeData.batID = batID; 



end 

