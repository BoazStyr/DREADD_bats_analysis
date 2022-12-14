
function [SpikeMatrixAll,SpikesPerFlight] = getLandingPhaseSpikes(SpikeData,flightPaths,trajNum,preTime,postTime,showPlot)
% This script compares the spiking activity after lading  before and
% after DCZ. 



% user input:
%trajNum = 2; 
%postTime = 10; % time to show after landing in sec
%preTime = 0; % time before landing to show in sec 
 



figure; set(gcf,'Color','w')
tiledlayout('flow')
for unitNum = 1:length(SpikeData.global_SpikeTimes_Sec_all) 


trajIdx = find(flightPaths.id==trajNum); % find the idx numbers of the flights from a sepcific traj 
UnitSpikes = SpikeData.global_SpikeTimes_Sec_all{unitNum}; % get the spike times for the unit

SpikeMatrix = zeros(length(trajIdx),100); 

for fnum = 1:length(trajIdx) % we go flight by flight for this traj

    fendidx = flightPaths.flight_ends_idx(trajIdx(fnum)); 
    fstartTime =flightPaths.global_ts_Sec(fendidx)-preTime; % the start time is the end of the flight - pretime
    fendTime = fstartTime+preTime+postTime;
     

    if fstartTime > SpikeData.global_DCZ_ts_Sec % we store the number of the flights that DCZ starts; 
        DCZf(fnum) = 1; 
    end 

    UnitSpikes_f = UnitSpikes(UnitSpikes>fstartTime & UnitSpikes<fendTime); % get the spikes that happend during this flight
    SpikesPerFlight(unitNum,fnum) = length(UnitSpikes_f); % store the number of spikes per fight for later. 
    
        
    UnitSpikesf_zeroed = UnitSpikes_f-fstartTime; % we first find the Spike times relative to start of flight.  
    UnitSpikesf_normed = UnitSpikesf_zeroed/(fendTime-fstartTime);  % then we norm to the lenght of the flight. 

        binSize = 0.01; % this is for bins of 1% of the flight. 
        for binNum = 1:100 % now lets put the spiking activity in bins of % of the flight phase 
            
            binTime = (binNum*binSize)-binSize;
            SpikesinBin = UnitSpikesf_normed(UnitSpikesf_normed>binTime & UnitSpikesf_normed<binTime+binSize); 
            SpikeMatrix(fnum,binNum) = length(SpikesinBin); 
        end 
       
 end

% now we insert NaN to the row that seperates the control from DCZ flights 
DCZf = find(DCZf,1); 
SpikeMatrix = [SpikeMatrix(1:DCZf-1,:);nan(1,100);SpikeMatrix(DCZf:end,:)]; 
DCZf = []; 

if showPlot == true

nexttile
h = heatmap(SpikeMatrix); 
grid off
h.XDisplayLabels = nan(1,100); 
h.YDisplayLabels = nan(1,fnum+1);
colormap('parula'); 
title(['unit # ',num2str(unitNum)]); 

end 

SpikeMatrixAll{unitNum} = SpikeMatrix; 
end 
if showPlot == true
sgtitle(['date:',num2str(SpikeData.date),'activty: ',num2str(postTime) ,' sec post landing'])

figure; set(gcf,'Color','w')
plot(SpikesPerFlight','LineWidth',2)
title('Spikes per reward period'); xlabel('reward #'); ylabel('# of spikes')
end         




