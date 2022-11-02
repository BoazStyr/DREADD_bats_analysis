function  [corrActivity,diffAbsActivity] = plotUnitFlightActivity(SpikeData,flightPaths,trajNum,showPlot)


% first we clac the spike rate during flight 

[SpikeMatrixAll,SpikesPerFlight] = getFlightPhaseSpikes(SpikeData,flightPaths,0,trajNum);

% now we go unit by unit and see how it fared after DCZ 
for unitNum = 1:size(SpikesPerFlight,1)

    SpikeMatrix = SpikeMatrixAll{unitNum}; 
    DCZf = find(isnan(SpikeMatrix(:,1))) ; % find flight 'border' between control and DCZ flights  (Nan) 

    BLactivity = movmean(mean(SpikeMatrix(1:DCZf-1,:)),5);  
    DCZactivity = movmean(mean(SpikeMatrix(DCZf+1:end,:)),5);
    
    corrActivity(unitNum,1) =  corr(BLactivity',DCZactivity','type','Spearman'); 
    
    
    diffActivity = DCZactivity-BLactivity; 
    diffAbsActivity(unitNum) = sum(abs(diffActivity)); 

   if showPlot == true 
    
    figure; 
    set(gcf,'Color','w','Position', [2180 836 1029 541]) 
    plot(SpikesPerFlight(unitNum,:),'Color',[0.2 0.2 0.2 0.2],LineWidth=4); 
    hold on; 
    plot(movmean(SpikesPerFlight(unitNum,:),5),'k',LineWidth=4);
    box off 
    title('Spikes per flight')



    figure; 
    tiledlayout('flow')
    set(gcf,'Color','w','Position',[3213 82 578 1296])

    nexttile([1 4])
    plot(diffActivity,'Color',[0.7 0.2 0.2],LineWidth=3)
    yline(0,'LineWidth',2,LineStyle='--')
    title('diff after DCZ'); axis off

    nexttile([1 4])
    plot(BLactivity,'Color',[0.5 0.5 0.5],LineWidth=3)
    hold on 
    plot(DCZactivity,'Color',[0.2 0.2 0.7],LineWidth=3)
    yline(0,'LineWidth',2,LineStyle='--')
    axis off;  
    title('mean activity')
    
    nexttile([6 4])
    h = heatmap(SpikeMatrix); 
    grid off
    h.XDisplayLabels = nan(1,100); 
    h.YDisplayLabels = nan(1,size(SpikeMatrix,1));
    colormap('turbo'); 
    title(['Unit: ',num2str(unitNum)]) 
    
    % now we plot the flights and the spikes on them 
 
    figure; 
    t = tiledlayout('flow'); 
     
    set(gcf,'Color','w','Position',[12 84 2164 1294])

    SpikesXYZ = []; 
    SpikeCortexIdxAll = SpikeData.SpikeCortexIdxAll;  
 
    SpikeCortexIdx = SpikeCortexIdxAll{unitNum}; 

    trajIdx = find(flightPaths.id==trajNum);
     
   
    for fnum = 1:1:length(trajIdx)
        nexttile
        fstartIdx = flightPaths.flight_starts_idx(trajIdx(fnum)); 
        fendIdx = flightPaths.flight_ends_idx(trajIdx(fnum)); 
    
    
        fSpikesIdx = SpikeCortexIdx(SpikeCortexIdx>fstartIdx & SpikeCortexIdx < fendIdx); 
        SpikesXYZ(1,:) = flightPaths.trajectoriesContinous(1,fSpikesIdx(:)); 
        SpikesXYZ(2,:) = flightPaths.trajectoriesContinous(2,fSpikesIdx(:)); 
        
        
        if flightPaths.global_ts_Sec(fstartIdx) < SpikeData.global_DCZ_ts_Sec 
     
        plot(SpikesXYZ(1,:),SpikesXYZ(2,:),'o','Color','w','MarkerSize',6,'MarkerFaceColor','r')
        hold on; 
        plot(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),'Color',[0.5 0.5 0.5 0.2],'LineWidth',4)
        axis off 
        xlim([-3 3]); ylim([-3 3]); 
        %title('BL flight Num: ',num2str(fnum))
        %hold off;
        
        else 
       
        plot(SpikesXYZ(1,:),SpikesXYZ(2,:),'o','Color','w','MarkerSize',6,'MarkerFaceColor','r')
        hold on; 
        plot(flightPaths.trajectoriesContinous(1,fstartIdx:fendIdx),flightPaths.trajectoriesContinous(2,fstartIdx:fendIdx),'Color',[0 0 0.8 0.2],'LineWidth',4)
        axis off 
        xlim([-3 3]); ylim([-3 3]); 
        %title('DCZ flight Num: ',num2str(fnum))
        %hold off;

        end  

    

        SpikesXYZ = [];  
    
    end 

    
        t.TileSpacing = 'tight';
        t.Padding = 'tight';
        sgtitle(['Unit ',num2str(unitNum),' date: ',num2str(SpikeData.date)])
        
    figure; 
    PlotSpikeCortex(SpikeData,flightPaths,unitNum,trajNum); 
    set(gcf,'Color','w','Position',[2181 84 1029 659])
    set(gca,'view',[-74.4934  -11.7524])


pause() 
close all 
   end 
end 
