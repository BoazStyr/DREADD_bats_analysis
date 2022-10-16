

for spikeNum = 1:length(global_SpikeArriveal_timestamps_usec)
    SpikeCortexIdx(spikeNum) = find(global_cortex_timestamps_usec>global_SpikeArriveal_timestamps_usec(spikeNum),1,'first');
end 


Traj2StartsIdx = flightPaths.flight_starts_idx(flightPaths.id==2);

Traj2Starts = global_Cortex_timestamps_usec(Traj2StartsIdx);
Traj2startMin = Traj2Starts/1e6/60;
DCZtimeMin = 28; 


Traj2DCZIdx = Traj2StartsIdx(Traj2startMin>DCZtimeMin); 
Traj2ControlIdx = Traj2StartsIdx(Traj2startMin<DCZtimeMin); 


trajIdx = find(flightPaths.id==2);

% plot flights 3d
figure; 
for fnum = 1:length(trajIdx)  
    fstartIdx = flightPaths.flight_starts_idx(trajIdx(fnum)); 
    fendIdx = flightPaths.flight_ends_idx(trajIdx(fnum)); 

% Plot the spikes 
    if fnum <= 11 % i know for this day that i injatedc DCZ after 37 flights of traj 2 , but this needs to be calc. 
        plot3(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx) ...
            ,flightPaths.trajectoriesContinous(3,fstartIdx:fendIdx),'Color',[0.2 0.2 0.2 0.2],'LineWidth',2)
        hold on;

   % find the spikes for this flight and plot them ontop 
    
    fSpikesIdx = SpikeCortexIdx(SpikeCortexIdx>fstartIdx & SpikeCortexIdx < fendIdx); 
    SpikesXYZ(1,:) = flightPaths.trajectoriesContinous(1,fSpikesIdx(:)); 
    SpikesXYZ(2,:) = flightPaths.trajectoriesContinous(1,fSpikesIdx(:)); 
    SpikesXYZ(3,:) = flightPaths.trajectoriesContinous(1,fSpikesIdx(:)); 
    
    
    else
        plot3(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx) ...
            ,flightPaths.trajectoriesContinous(3,fstartIdx:fendIdx),'Color',[0.2 0.2 0.7 0.2],'LineWidth',4)       
        hold on; 
    end   
end 

Traj2 = nan(2,700,69);
fSpikeTimesRelative = nan(100,69); 
SpikesXYZ = []; 

% plot in 2D
figure; set(gcf,'Color','w')
for fnum = 1:69
    fstartIdx = flightPaths.flight_starts_idx(trajIdx(fnum)); 
    fendIdx = flightPaths.flight_ends_idx(trajIdx(fnum)); 

     % find the loc during spikes for this flight 
        fSpikesIdx = SpikeCortexIdx(SpikeCortexIdx>fstartIdx & SpikeCortexIdx < fendIdx); 
        SpikesXYZ(1,:) = flightPaths.trajectoriesContinous(1,fSpikesIdx(:)); 
        SpikesXYZ(2,:) = flightPaths.trajectoriesContinous(2,fSpikesIdx(:)); 
        SpikesXYZ(3,:) = flightPaths.trajectoriesContinous(3,fSpikesIdx(:)); 

        % collect the flights 
         
        fsize = fendIdx-fstartIdx+1; 
        Traj2(1,1:fsize,fnum) = flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx); 
        Traj2(2,1:fsize,fnum) = flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx); 
        
        % here we find the spike times realtive to flight 
        fstartTime = global_sample_timestamps_usec(fstartIdx)-1*1e6; % start time min 1 sec (in us) to see baseline  
        fendTime = global_sample_timestamps_usec(fendIdx)+2*1e6; % 2 secs after to see the feeding reward activy 
        fSpikeTimes = global_SpikeArriveal_timestamps_usec(global_SpikeArriveal_timestamps_usec>fstartTime & global_SpikeArriveal_timestamps_usec<fendTime); 
        fSpikeTimesRelative(fnum,1:length(fSpikeTimes)) = fSpikeTimes-fstartTime; 


    if fnum <= 37 % i know for this day that i injatedc DCZ after 37 flights of traj 2 , but this needs to be calc. 
                
        subplot(1,2,1)
        plot(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),'Color',[0.2 0.2 0.2 0.2],'LineWidth',2)
        hold on;
        plot(SpikesXYZ(1,:),SpikesXYZ(2,:),'o','Color','k','MarkerSize',5,'MarkerFaceColor','r')
        
    else
        subplot(1,2,2)
        plot(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),'Color',[0.2 0.2 0.7 0.2],'LineWidth',4)       
        hold on; 
        plot(SpikesXYZ(1,:),SpikesXYZ(2,:),'o','Color','k','MarkerSize',5,'MarkerFaceColor','r') 
   
    end  
    SpikesXYZ = []; 
end 

% plot the spike times along the lin traj 

for fnum = 1:69
    plot(fSpikeTimesRelative(fnum,:),ones(1,length(fSpikeTimesRelative(fnum,:)))*fnum*-1,'|k','MarkerSize',10,'MarkerEdgeColor','k'); 
    hold on;
    yline((fnum*-1)-0.5,'Color',[0.8 0.8 0.8 0.2])
end 
   yline(-37.5,'b','LineWidth',2);
   xline(1e6,'k','LineWidth',2)
   xline(5.5e6,'k','LineWidth',2) 
   xlim([0 7.5*1e6]) 

% now lets calc. the MFR in bins of 100ms. 
binSize = 0.1*1e6;  

 for binNum = 1:round(7e6/binSize)-1 
        MFRcont(binNum) = sum(fSpikeTimesRelative(1:37,:)>binNum*binSize & fSpikeTimesRelative(1:37,:)<(binNum*binSize)+binSize,'all');    
 end 

 for binNum = 1:round(7e6/binSize)-1 
        MFRdcz(binNum) = sum(fSpikeTimesRelative(38:end,:)>binNum*binSize & fSpikeTimesRelative(38:end,:)<(binNum*binSize)+binSize,'all');    
 end 

timeVector = 0.1:0.1:7-0.1;

plot(timeVector,MFRcont/37,'k','LineWidth',2); 
hold on; 
plot(timeVector,MFRdcz/32,'b','LineWidth',2); 
xlabel('time (sec)'); ylabel('Spike count'); title('averge spike counts per flight / bin'); 


plot(timeVector,MFRcont/37*10,'Color',[0.2 0.2 0.2],'LineWidth',3); 
hold on; 
plot(timeVector,MFRdcz/32*10,'b','LineWidth',3); 
xlabel('time (sec)'); ylabel('Hz'); title('unit firing rate');
xline(1,'k','LineWidth',2); xline(5.3,'k','LineWidth',2); 



% plot flights of each axis seperatly on the same figure 
figure; set(gcf,'Color','w')
for axis = 1:3
for fnum = 1:69  
    fstartIdx = flightPaths.flight_starts_idx(trajIdx(fnum)); 
    fendIdx = flightPaths.flight_ends_idx(trajIdx(fnum)); 
    if fnum <= 37 
        plot(flightPaths.trajectoriesContinous(axis,fstartIdx:fendIdx),'Color',[0.1 0.8 0.1 0.1],'LineWidth',2)
        hold on;
    else
        plot(flightPaths.trajectoriesContinous(axis,fstartIdx:fendIdx),'Color',[0.7 0.1 0.1 0.1],'LineWidth',2)       
        hold on; 
    end   
end 
end 
