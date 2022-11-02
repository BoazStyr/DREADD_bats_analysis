


% user input: 
timeAfterDCZ = 60*30; % here we look 30 min past DCZ. 
timeBeforeDCZ = 60*20; % define how much time before DCZ to clac. in sec
binSize = 60; % time bins to calc MFR in sec
units2skip = []; 


%clear up 
SpikesinBin = []; 
MFRHz = []; 
MFRHz_BLnormed = []; 

% use the DCZ time stamp to determin the total time to calculate MFR 
DCZts = SpikeData.global_DCZ_ts_Sec; 
MFRtotalTime = timeBeforeDCZ + timeAfterDCZ; 



% === go unit by unit and calc the MFR 
for unitNum = 1:length(SpikeData.global_SpikeTimes_Sec_all)

    if isempty(find(units2skip == unitNum)) 
    
spikestimes = SpikeData.global_SpikeTimes_Sec_all{unitNum}; 

    for binNum = 1:round(MFRtotalTime/binSize)-1 
    
      binTime = (binNum*binSize)-binSize; 
      binTime = binTime + DCZts-timeBeforeDCZ; 
     
    
                SpikesinBin(binNum,unitNum) = length(spikestimes(spikestimes>binTime & spikestimes<binTime+binSize)); 
                MFRHz(binNum,unitNum) =  SpikesinBin(binNum,unitNum)/binSize; 
    end 
    else 
    end 
    MFR_BL = mean(MFRHz(1:round(DCZts/binSize)-1,:)); 
    MFRHz_BLnormed = MFRHz ./ MFR_BL; 
    
    
end 

% plot
figure; set(gcf,'Color','w','Position',[776 165 618 1286]); 

subplot(3,1,1)
plot(MFRHz,'LineWidth',2); 
title('MFR of ech unit for date: ',num2str(SpikeData.date))
ylabel('MFR (Hz)'); xlabel('Time (min)'); set(gca,'FontSize',15)
xline(timeBeforeDCZ/binSize,'LineWidth',4,'Color','k',LineStyle='--')
xlim([0 timeBeforeDCZ/binSize+timeAfterDCZ/binSize]); 

subplot(3,1,2)
plot(MFRHz_BLnormed,'LineWidth',2); 
title('baseline nomred MFR of ech unit for date: ',num2str(SpikeData.date))
ylabel('MFR (normed)'); xlabel('Time (min)'); set(gca,'FontSize',15)
xline(timeBeforeDCZ/binSize,'LineWidth',4,'Color','k',LineStyle='--')
xlim([0 timeBeforeDCZ/binSize+timeAfterDCZ/binSize]);

subplot(3,1,3)
plot(MFRHz_BLnormed,'LineWidth',2,'Color',[0.3 0.3 0.3 0.2]); 
hold on; set(gca,'FontSize',15)
plot(mean(MFRHz_BLnormed,2,"omitnan"),'LineWidth',5,'Color','k'); 
title('mean baseline nomred MFR for date: ',num2str(SpikeData.date))
ylabel('MFR (normed)'); xlabel('Time (min)'); 
xline(timeBeforeDCZ/binSize,'LineWidth',4,'Color','k',LineStyle='--')
xlim([0 timeBeforeDCZ/binSize+timeAfterDCZ/binSize]);
