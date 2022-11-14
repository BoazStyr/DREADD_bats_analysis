
% This script clac the effect of DCZ on Spikes per flight 

%load the workspace of SpikeData and flightpaths 



% get the time to start looking at SPF 
timeAfterDCZ = 5 ; % in min 
SPF_DCZ_start = SpikeData.global_DCZ_ts_Sec+60*timeAfterDCZ; % take 15min after DCZ only 
traj = 2; 
% find the # of flights after DCZ you want to calcaulate; 

fTimes = flightPaths.global_ts_Sec(flightPaths.flight_starts_idx(flightPaths.id ==traj)); 

fTimesBeforeDCZ = length(fTimes(fTimes<SpikeData.global_DCZ_ts_Sec)); 
fTimes_DCZ_Fullonset = length(fTimes(fTimes>SPF_DCZ_start)); % take only the last! flights (this number from the end backwrads)


% get SPF 
[SpikeMatrixAll,SpikesPerFlight] = getFlightPhaseSpikes(SpikeData,flightPaths,0,2); % get the SPF 

SPF_beforeDCZ = SpikesPerFlight(:,1:fTimesBeforeDCZ-1); 

SPF_afterDCZfullOnset = SpikesPerFlight(:,fTimes_DCZ_Fullonset+1:end); 



% plot hists 
figure; set(gcf,'Color','w','Position',[921 230 855 1214]); 
tiledlayout('flow');
for unitNum  =1:size(SPF_afterDCZfullOnset,1)
nexttile
histogram(SPF_beforeDCZ(unitNum,:),'BinWidth',min(SPF_beforeDCZ(unitNum,:))/3+1,'FaceColor',[0.5 0.5 0.5],'Normalization','probability'); 
hold on;
histogram(SPF_afterDCZfullOnset(unitNum,:),'BinWidth',min(SPF_beforeDCZ(unitNum,:))/3+1,'FaceColor',[0.2 0.2 0.7],'Normalization','probability'); 
title(['unit#: ',num2str(unitNum)])
end


% plot the as groups 


figure; set(gcf,'Color','w','Position',[47 111 795 1321]) 
tiledlayout('flow');
for unitNum  =1:size(SPF_afterDCZfullOnset,1)
nexttile
unitBL = mean(SPF_beforeDCZ(unitNum,:)); 
SPF_beforeDCZ_normed = SPF_beforeDCZ(unitNum,:)/unitBL; 
SPF_afterDCZfullOnset_normed = SPF_afterDCZfullOnset(unitNum,:)/unitBL; 
plot(ones(length(SPF_beforeDCZ_normed)),SPF_beforeDCZ_normed,'*k',MarkerSize=5); 
hold on; 
plot(1,mean(SPF_beforeDCZ_normed),'ok',MarkerSize=10,MarkerFaceColor='k');

plot(ones(length(SPF_afterDCZfullOnset_normed))*2,SPF_afterDCZfullOnset_normed,'*b',MarkerSize=5); 
plot(2,mean(SPF_afterDCZfullOnset_normed),'ob',MarkerSize=10,MarkerFaceColor='b');

xlim([0 3])
title(['unit#: ',num2str(unitNum)])
end


SPFbeforeAll = []; 
SPFAfterAll = []; 

for unitNum  =1:size(SPF_afterDCZfullOnset,1)

unitBL = mean(SPF_beforeDCZ(unitNum,:)); 
SPF_beforeDCZ_normed = SPF_beforeDCZ(unitNum,:)/unitBL; 
SPF_afterDCZfullOnset_normed = SPF_afterDCZfullOnset(unitNum,:)/unitBL; 

SPFbeforeAll = cat(1,SPFbeforeAll,SPF_beforeDCZ_normed); 
SPFAfterAll = cat(1,SPFAfterAll,SPF_afterDCZfullOnset_normed); 

end

figure; set(gcf,'Color','w','Position',[2256 831 828 663]); 
histogram(SPFbeforeAll,'BinWidth',0.2,'FaceColor',[0.5 0.5 0.5],'Normalization','probability'); 
hold on; 
histogram(SPFAfterAll,'BinWidth',0.2,'FaceColor',[0.2 0.2 0.7],'Normalization','probability');
title('BL nomred spikes per flight'); xlabel('normed SPF'); ylabel('prob of flight having BL relative SPF')


