function PlotSpikeCortex(SpikeData,flightPaths,unitNum,trajNum)

% unit4 is the spikes for unit4. interesting that 292 spikes are on the
% same indx of cortex (so happend less then 8.33 ms apart)




 
SpikesXYZ = []; 
SpikeCortexIdxAll = SpikeData.SpikeCortexIdxAll;  
 
    SpikeCortexIdx = SpikeCortexIdxAll{unitNum}; 

    trajIdx = find(flightPaths.id==trajNum);
    
    for fnum = 1:1:length(trajIdx)
    
        fstartIdx = flightPaths.flight_starts_idx(trajIdx(fnum)); 
        fendIdx = flightPaths.flight_ends_idx(trajIdx(fnum)); 
    
    
        fSpikesIdx = SpikeCortexIdx(SpikeCortexIdx>fstartIdx & SpikeCortexIdx < fendIdx); 
        SpikesXYZ(1,:) = flightPaths.trajectoriesContinous(1,fSpikesIdx(:)); 
        SpikesXYZ(2,:) = flightPaths.trajectoriesContinous(2,fSpikesIdx(:)); 
        SpikesXYZ(3,:) = flightPaths.trajectoriesContinous(3,fSpikesIdx(:)); 
        
        if flightPaths.global_ts_Sec(fstartIdx) < SpikeData.global_DCZ_ts_Sec 
        %figure(1); set(gcf,'Position',[509 473 565 826],'Color','w');
        plot3(SpikesXYZ(1,:),SpikesXYZ(2,:),SpikesXYZ(3,:),'o','Color','w','MarkerSize',5,'MarkerFaceColor','r')
        hold on; 
        plot3(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(3,fstartIdx:fendIdx),'Color',[0.5 0.5 0.5 0.2],'LineWidth',2)
       
        xlim([-3 3]); ylim([-3 3]); 
        title('BL flight Num: ',num2str(fnum))
        %hold off;
        
        else 
        %figure(2); set(gcf,'Position',[509 473 565 826],'Color','w');
        plot3(SpikesXYZ(1,:),SpikesXYZ(2,:),SpikesXYZ(3,:),'o','Color','w','MarkerSize',5,'MarkerFaceColor','g')
        hold on; 
        plot3(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(3,fstartIdx:fendIdx),'Color',[0 0 0.8 0.2],'LineWidth',2)
       
        xlim([-3 3]); ylim([-3 3]); 
        title('DCZ flight Num: ',num2str(fnum))
        %hold off;

        end  

        
        %pause()

        SpikesXYZ = [];  
    
    end      

end 