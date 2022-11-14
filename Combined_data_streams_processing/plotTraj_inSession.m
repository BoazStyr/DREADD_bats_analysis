

 for fnum = 1:length(flightPaths.id)
        fstartIdx = flightPaths.flight_starts_idx(fnum); 
        fendIdx = flightPaths.flight_ends_idx(fnum); 
    
  
        
        
        if flightPaths.global_ts_Sec(fstartIdx) < SpikeData.global_DCZ_ts_Sec 
     
        figure(1)
        plot(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),'Color',[0.5 0.5 0.5 0.2],'LineWidth',4)
        hold on; 
        axis off 
        xlim([-3 3]); ylim([-3 3]); 
        %title('BL flight Num: ',num2str(fnum))
        %hold off;
        
        else 
        figure(2)
        plot(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),'Color',[0 0 0.8 0.2],'LineWidth',4)
        hold on; axis off 
        xlim([-3 3]); ylim([-3 3]); 
        %title('DCZ flight Num: ',num2str(fnum))
        %hold off;

        end  

 end 