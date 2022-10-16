
function [SpikeData,flightPaths] = getSpikeCortexIdx(SpikeData,flightPaths)
% This script takes the spike times from SpikeData structure and finds the
% idx times for them in flightPath strucutre. it puts the results into the
% SpikeData and flightPaths strucs. 

for unitNum = 1:length(SpikeData.global_SpikeTimes_Sec_all)
    
    disp(['calculating Cortex indxs for unit number: ',num2str(unitNum)])
    
    unitSpikes = SpikeData.global_SpikeTimes_Sec_all{unitNum};
    SpikeCortexIdx = []; 

    for spikeNum = 1:length(unitSpikes)
        SpikeCortexIdx(spikeNum) = find(flightPaths.global_ts_Sec>unitSpikes(spikeNum),1,'first');
    end 

    SpikeData.SpikeCortexIdxAll{unitNum} = SpikeCortexIdx;  
    flightPaths.SpikeCortexIdxAll{unitNum} = SpikeCortexIdx; 
    SpikeCortexIdx = [];

end 
disp('getSpikeCortexIdx complete. Save worksapce for future use.')
end 
