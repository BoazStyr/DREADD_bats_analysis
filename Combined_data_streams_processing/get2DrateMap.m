
% This script gets the 2D rate mapes for a neuron 
% this assumes you loaded the worksapce (SpikeData and flightPaths)


%close all;  
%=== user inputs:
bin_size = 0.08; 
min_time = 0.05; 
minAfterDCZ = 10; % how long after DCZ to pull flights in min (10 min to full effec is noraml); 

%=== Parameters
Fs = 120;                               % Sampling Rate for position
r_lim = [-2.9 2.9; -2.6 2.6; 0 2.30];   % Room boundaries
x_bin_size = bin_size;                  % Bin size along x dimension
y_bin_size = bin_size;                  % Bin size along y dimension
sigma_m = 0.225;                        % Sigma of the smoothing Gaussian kernel (m)                       
sigma = sigma_m/bin_size;               % Sigma of the smoothing Gaussian kernel (px)


figure; 
tiledlayout('flow'); 
set(gcf,'Color','w','Position',[244 78 1940 1294]); 



% first we get the positions of all flights 
fstartstime = flightPaths.global_ts_Sec(flightPaths.flight_starts_idx); 

fstartstimeBL = fstartstime<SpikeData.global_DCZ_ts_Sec; 
posBL = flightPaths.pos(:,:,fstartstimeBL); 
pos_BL(:,1) = reshape(posBL(1,:,:),[1,numel(posBL(1,:,:))])';
pos_BL(:,2) = reshape(posBL(2,:,:),[1,numel(posBL(2,:,:))])';

fstartstimeDCZ = fstartstime>SpikeData.global_DCZ_ts_Sec+60*minAfterDCZ; 
posDCZ = flightPaths.pos(:,:,fstartstimeDCZ); 
pos_DCZ(:,1) = reshape(posDCZ(1,:,:),[1,numel(posDCZ(1,:,:))])';
pos_DCZ(:,2) = reshape(posDCZ(2,:,:),[1,numel(posDCZ(2,:,:))])';


DCZCortexIdx = find(flightPaths.global_ts_Sec>SpikeData.global_DCZ_ts_Sec,1); 

% now we run unit by unit for the locations of each spike for a unit 
for unitNum = 1:length(SpikeData.SpikeCortexIdxAll)  
  for treat = 1:2 
    spk_pos = [];
   UnitSpikCorextIdx = SpikeData.SpikeCortexIdxAll{unitNum}; 
   
       if treat == 1 % here we get the separated spikes and pos depending on the treat ts. 
        UnitSpikCorextIdx = UnitSpikCorextIdx(UnitSpikCorextIdx<DCZCortexIdx);
        pos_all = pos_BL; 
       elseif treat == 2 
        UnitSpikCorextIdx = UnitSpikCorextIdx(UnitSpikCorextIdx>DCZCortexIdx+minAfterDCZ);
        pos_all = pos_DCZ;
       end 
   
   for spikeNum = 1:length(UnitSpikCorextIdx)
       v = flightPaths.batSpeed(UnitSpikCorextIdx(spikeNum)); 
       if v > 0.8
           spk_pos_unit = flightPaths.trajectoriesContinous(:,UnitSpikCorextIdx(spikeNum)); 
           spk_pos = cat(2,spk_pos,spk_pos_unit); 
       end 
   end 
pos_spk = spk_pos'; 

%Matrix for 2D convolution with the 8 nnb pixels
nnb_kernel = ones(3,3);

 %=== GET RID OF NAN DATA
    pos_spk = pos_spk(all(~isnan(pos_spk),2),:);
    
    %=== BINNING OF 2D-SPACE
    x_edges = [r_lim(1,1):x_bin_size:r_lim(1,2)];
    y_edges = [r_lim(2,1):y_bin_size:r_lim(2,2)];
    
    %=== POPULATE MATRICES BY COUNTING SPIKES AND SAMPLES
    [spike_counts,~,~] = histcounts2(pos_spk(:,1),pos_spk(:,2),x_edges,y_edges);    %Spike Counts
    [occup_counts,~,~] = histcounts2(pos_all(:,1),pos_all(:,2),x_edges,y_edges);    %Occupancy Counts (samples)
    times_counts = occup_counts/Fs;                                                 %Occupancy Counts (time)
    
    %=== EXCLUDE BINS WITH LOWER THAN min_time OCCUPANCY
    times_counts(times_counts<min_time)=0;
    occup_counts(times_counts<min_time)=0;
    spike_counts(times_counts<min_time)=0;
    
    %=== CALCULATE RAW AND SMOOTHED FIELDS
    field_map_rw = spike_counts./times_counts;
    field_map_sm = imgaussfilt(spike_counts,sigma)./imgaussfilt(times_counts,sigma);

    %=== FORCE UNVISITED-&-ISOLATED BINS TO NaN
    %=== As a consequence of smoothing, occupancy-normalized firing rate is calculated on bins that were not visited
    %=== Unvisited bins are kept only if the bat visited any of the bin's 8 closest neighbours:
    nnb_matrix = conv2(times_counts,nnb_kernel,'same')>0;
    field_map_sm(~nnb_matrix)=nan;


    %=== ROTATE THE MAP, IN ORDER TO HAVE DOOR ON THE BOTTOM LEFT
    map = rot90(field_map_sm);
    
    % plot 
    nexttile 
    plot(pos_spk(:,1),pos_spk(:,2),'ok','MarkerSize',1);
    xlim([-2.9 2.9]); ylim([-2.6 2.6]);  axis off
     if treat == 1 
    title(['unit#:',num2str(unitNum),' BL '])
    else
    title(['unit#:',num2str(unitNum),' DCZ '])  
     end 

    nexttile
    colormap jet;
    imagesc(map,'AlphaData',~isnan(map),[0 max(map,[],'all')]);
    axis off
    %colorbar
    if treat == 1 
    title(['unit#:',num2str(unitNum),' BL '])
    else
    title(['unit#:',num2str(unitNum),' DCZ '])  
    end 
  end

end 
