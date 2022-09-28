function  MFR_all = MFRcalc(DataDir,MFRinterval)
% calc the MFR in MFRinterval bins from Spike_arrival_times file (MFRinterval is in sec) 
% input: the folder with the spike sorted .mat files that you got after
% sorting to units uising spikeSorter3d and converting it to mat lab using
% mat2ntt script. and the window to calc. the MFR (in sec)
%output: plot of each unit MFR over time, and a strcuture with the MFR data.  



ClsuterList = dir([DataDir,'\*mat']);  

for ClusterNum = 1:length(ClsuterList) % go cluster file by cluster file  

    % load file with spike times for a cluster 
    load([ClsuterList(ClusterNum).folder,'\',ClsuterList(ClusterNum).name],'Spike_arrival_times');

    % zero to first spike and convert to seconds:
    spikes = (Spike_arrival_times - Spike_arrival_times(1))/1000000; % good
    
    %Check: 
    if isempty(MFRinterval) % if its empty the defult is 1 sec bin
    MFRinterval = 1; 
    end 

    % calc MFR in bins 
        MFR = nan(1,1000); % change later. won't fit with other invercals then 60sec

        for binNum = 1:round(max(spikes)/MFRinterval)-1 
        
        MFR(binNum) = sum(spikes>binNum*MFRinterval & spikes<(binNum*MFRinterval)+MFRinterval);
        MFR(binNum) = MFR(binNum)/MFRinterval; 
        end 

    % plot
    %subplot(length(ClsuterList),1,ClusterNum) 
    figure;
    plot(MFR); title(ClsuterList(ClusterNum).name); 
    xlabel('time(in MFR intervals)'); ylabel('MFR(Hz)')
    set(gcf,'Color','w')
    
    % store data
         
     MFR_all(:,ClusterNum) = MFR; %  
    
     MFR = []; 
end

figure; 
h = heatmap(MFR_all(1:79,:)'); 
h.GridVisible = 'off';  
h.Colormap = 'perula'; 

end 

