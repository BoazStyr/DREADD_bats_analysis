function [map,SI,SP] = RateMap_AF_v2(pos_spk,pos_all,plot_flag,dim,bin_size,min_time)
%% Function for calculating occupancy normalized rate maps and associated spatial information
% References for parameters are indicated below
% Additinal Reference for Spatial Information: Souze et al., On Information metrics for spatial coding, 2018.

% INPUTS
% pos_spk:      n x 3 (or n x 1) matrix containing the 3d (1d) position of the n spikes
% pos_all:      m x 3 (or m x 1) matrix containing the 3d (1d) position of the m flight samples
% plot_flag:    if plotting or not
% dim:          1d or 2d analysis
% bin_size:     size of the spatial bins
% min_time;     minimum time spent on a bin to validate it (0.15s during flight, 5s during rest)


% OUTPUTS
% map:          matrix of x by y bins and the associated occupancy-normalized firing rate
% SI:           Spatial Information in bits/spike:  

% References for parameter choice
%                   Bin (cm)   sigma   min_time Comment          
% Yartsev    2011      5.8     1.5     0.3     Crawling
% Geva-Sagiv 2016      10      1.5     0.15    Remove 10 cm tails
% Omer       2018      10      1.5     0.1     Only steretyped trajectories, remove 10 cm tails 
% Dotson     2021      20      1       0.05    >0.3 Hz ave firing 

%=== Parameters
Fs = 100;                               % Sampling Rate for position
r_lim = [-2.9 2.9; -2.6 2.6; 0 2.30];   % Room boundaries
n_bins = 30;                            % Number of bins for the 1D-spatial maps
x_bin_size = bin_size;                  % Bin size along x dimension
y_bin_size = bin_size;                  % Bin size along y dimension
sigma_m = 0.225;                        % Sigma of the smoothing Gaussian kernel (m)                       
sigma = sigma_m/bin_size;               % Sigma of the smoothing Gaussian kernel (px)

%Michael's version of the gaussian kernel (giving similar/identical results)
hsize = 5*round(sigma)+1;
gaussian_kernel = fspecial('gaussian',hsize,sigma);

%Matrix for 2D convolution with the 8 nnb pixels
nnb_kernel = ones(3,3);
%nnb_kernel(2,2)=0;

if ~strcmp(dim,'1d')
    
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
    field_map_MY = imfilter(spike_counts,gaussian_kernel)./imfilter(times_counts,gaussian_kernel);
    
    %=== FORCE UNVISITED-&-ISOLATED BINS TO NaN
    %=== As a consequence of smoothing, occupancy-normalized firing rate is calculated on bins that were not visited
    %=== Unvisited bins are kept only if the bat visited any of the bin's 8 closest neighbours:
    nnb_matrix = conv2(times_counts,nnb_kernel,'same')>0;
    field_map_MY(~nnb_matrix)=nan;
    field_map_sm(~nnb_matrix)=nan;
    
    %=== ROTATE THE MAP, IN ORDER TO HAVE DOOR ON THE BOTTOM LEFT
    map = rot90(field_map_sm);
    
    %=== CALCULATE SPATIAL INFORMATION (SUMMING ACROSS VALID BINS)
    firing_rate = field_map_sm(~isnan(field_map_sm));
    ocp_probability = occup_counts(~isnan(field_map_sm))./sum(occup_counts(~isnan(field_map_sm)));
    ave_rate = firing_rate'*ocp_probability;
    SI = sum((ocp_probability.*firing_rate).*log2(firing_rate./ave_rate),'omitnan')/ave_rate;
    
    %=== CALCULATE SPARSITY
    SP = (ave_rate^2)/((firing_rate.^2)'*ocp_probability);
    
    %=== SPATIAL INFORMATION IS ZERO IF THE NEURON IS NOT FIRING
    if ave_rate == 0
        SI = 0;
        SP = 0;
    end
else
    
    %% 1D PLACE CELL ANALYSIS

    %=== SMOOTHING KERNEL FOR SPIKE COUNTS
    w = gausswin(7);   
    
    %=== BINNING OF 1D-SPACE (trajectory is normalized between 0 and 1)
    x_edges = [0:x_bin_size:1];
    
    %=== POPULATE MATRICES BY COUNTING SPIKES AND SAMPLES
    [spike_counts,~,~] = histcounts(pos_spk,x_edges);    %Spike Counts
    [occup_counts,~,~] = histcounts(pos_all,x_edges);    %Occupancy Counts (samples)
    
    %=== CALCULATE SMOOTHED FIELD
    map = conv(spike_counts, w,'same')./occup_counts*Fs;
    
    %==== CALCULATE SPATIAL INFORMATION (SUMMING ACROSS VALID BINS)
    firing_rate = map';
    ocp_probability = occup_counts'./sum(occup_counts);
    ave_rate = firing_rate'*ocp_probability;
    SI = sum((ocp_probability.*firing_rate).*log2(firing_rate./ave_rate),'omitnan')/ave_rate;
    
    %=== CALCULATE SPARSITY 
    SP = (ave_rate^2)/((firing_rate.^2)'*ocp_probability);
    
    %=== CALCULATE RELIABILITY (fraction of the total firing that happens around the maximum)
    SP = sum(map(map>max(map)/2))/sum(map); 
    
    if isnan(SI)
        SI = 0;
        SP = 0;
    end
    
end

if plot_flag
    colormap jet;
    imagesc(map,'AlphaData',~isnan(map),[0 max(map,[],'all')]);
    colorbar
end

end



