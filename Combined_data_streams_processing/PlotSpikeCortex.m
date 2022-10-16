

% unit4 is the spikes for unit4. interesting that 292 spikes are on the
% same indx of cortex (so happend less then 8.33 ms apart)



% for unitNum = 4:9
%     unitSpikes = SpikeData.global_SpikeTimes_Sec_all{unitNum};
%     SpikeCortexIdx = []; 
% 
%     for spikeNum = 1:length(unitSpikes)
%         SpikeCortexIdx(spikeNum) = find(flightPaths.global_ts_Sec>unitSpikes(spikeNum),1,'first');
%     end 
% 
%     SpikeCortexIdxAll{unitNum}= SpikeCortexIdx;  
%     SpikeCortexIdx = [];
% end 
% 

 
SpikesXYZ = []; 
SpikeCortexIdxAll = SpikeData.SpikeCortexIdxAll;  
 
for unitNum = 2     %:9
   figure; set(gcf,'Position',[509 473 565 826],'Color','w');
    SpikeCortexIdx = SpikeCortexIdxAll{unitNum}; 

    % look at traj 2
    trajIdx = find(flightPaths.id==2);
    
    for fnum = 1:1:length(trajIdx)
    
        fstartIdx = flightPaths.flight_starts_idx(trajIdx(fnum)); 
        fendIdx = flightPaths.flight_ends_idx(trajIdx(fnum)); 
    
    
        fSpikesIdx = SpikeCortexIdx(SpikeCortexIdx>fstartIdx & SpikeCortexIdx < fendIdx); 
        SpikesXYZ(1,:) = flightPaths.trajectoriesContinous(1,fSpikesIdx(:)); 
        SpikesXYZ(2,:) = flightPaths.trajectoriesContinous(2,fSpikesIdx(:)); 
        SpikesXYZ(3,:) = flightPaths.trajectoriesContinous(3,fSpikesIdx(:)); 
        
        if flightPaths.global_ts_Sec(fstartIdx) < SpikeData.global_DCZ_ts_Sec 
      
        plot3(SpikesXYZ(1,:),SpikesXYZ(2,:),SpikesXYZ(3,:),'o','Color','w','MarkerSize',5,'MarkerFaceColor','r')
        hold on; 
        plot3(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(3,fstartIdx:fendIdx),'Color',[0.5 0.5 0.5 0.2],'LineWidth',2)
       
        xlim([-3 3]); ylim([-3 3]); 
        title('BL flight Num: ',num2str(fnum))
        %hold off;
        
        else 
        
        plot3(SpikesXYZ(1,:),SpikesXYZ(2,:),SpikesXYZ(3,:),'o','Color','w','MarkerSize',5,'MarkerFaceColor','g')
        hold on; 
        plot3(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(3,fstartIdx:fendIdx),'Color',[0 0 0.8 0.4],'LineWidth',2)
       
        xlim([-3 3]); ylim([-3 3]); 
        title('DCZ flight Num: ',num2str(fnum))
        %hold off;

        end  

        
        pause()

        SpikesXYZ = [];  
    end 
     

end 