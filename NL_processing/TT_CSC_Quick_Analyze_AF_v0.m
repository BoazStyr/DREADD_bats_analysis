%%

Fs = Estimated_channelFS_Transceiver(1);                                    % Voltage Sampling Frequency (Hz)
raw_V = double(AD_count_int16*AD_count_to_uV_factor);                       % Raw Voltage Trace
tstamps = Timestamps_of_first_samples_usec(1)+[0:length(raw_V)-1]/Fs*1e6;   % Timestamps (us)
tstamps = tstamps-tstamps(1);                                               % Shift relative to first timestamp
Look_at_Ripples(raw_V,tstamps,Fs,[],[],[],[]);                              % Call the function

function Look_at_Ripples(signal,t_vector,Fs,t,v_abs,a_abs,s)


% for running the code not using the function: 
signal = raw_V; t_vector = tstamps; t = []; v_abs = []; a_abs = []; s = []; 


%=== Look at 60s chunks
figure('units','normalized','outerposition',[0 0.1 1 0.7]);
tiledlayout(6,10,'TileSpacing','none');
chunk_start_smp = round(1:60*Fs:t_vector(end)*Fs-1);

for i=5:numel(chunk_start_smp)-1
   
   
    
    %=== Filter definitions and params
    RP_F_band = [100 200];                  % Ripples frequency band (From MY: [80 160])
    SP_F_band = [600 6000];                 % Spikes frequency band
    passband_norm = SP_F_band./(0.5*Fs);    % Normalize over sampling frequency
    [b,a] = ellip(4,0.1,70,passband_norm);  % Define filter transfer function coefficients
    RP_th = 3;                              % Threshold on zscored Ripple power
    
    %=== Assign zero velocity and acceleration if not provided
    if isempty(t),t=t_vector;end
    if isempty(v_abs),v_abs=zeros(size(t_vector));end
    if isempty(a_abs),a_abs=zeros(size(t_vector));end
    
    %=== Get raw signal, spikes and ripple power
    raw_signal = signal(:,chunk_start_smp(i):chunk_start_smp(i+1)-1);
    hps_signal = filtfilt(b,a,raw_signal);  hps_signal(abs(hps_signal)>500)=0;
    rpl_signal = zscore(abs(hilbert(bandpass(raw_signal,RP_F_band,Fs))));
    time = t_vector(chunk_start_smp(i):chunk_start_smp(i+1)-1);  time = time-time(1);
    spt_signal = raw_signal;
    
    %=== Interpolate the velocity/acceleration signals at the corresponding timestamps
    [~,strt] = min(abs(t-t_vector(chunk_start_smp(i))));
    [~,stop] = min(abs(t-t_vector(chunk_start_smp(i+1)-1)));
    vel_signal = interp1(t(strt:stop),v_abs(strt:stop),t_vector(chunk_start_smp(i):chunk_start_smp(i+1)-1));
    acc_signal = interp1(t(strt:stop),a_abs(strt:stop),t_vector(chunk_start_smp(i):chunk_start_smp(i+1)-1));
    
    %=== Get spike times
    coord_x = [];   coord_y = [];
    if ~isempty(s)
        for nc = 1:size(s,1)
            s{nc} = s{nc}-t_vector(chunk_start_smp(i));
            spikes = s{nc}(s{nc}>0 & s{nc}<time(end));
            coord_x = cat(2,coord_x,[spikes';spikes']);
            coord_y = cat(2,coord_y,[ones(size(spikes'))-nc;zeros(size(spikes'))-nc]);
        end
    end
    
    %=== Plot
    ax(1) = nexttile(1,[1 8]);     plot(time,raw_signal,'k');                                                   xticks([]); ylabel('Raw Voltage (uV)');
    ax(2) = nexttile(11,[1 8]);    plot(coord_x,coord_y,'m-','LineWidth',1);                                    xticks([]); ylabel('Sorted units');
    ax(3) = nexttile(21,[1 8]);    plot(time,hps_signal,'r');                                                   xticks([]); ylabel('High Pass (uV)');
    ax(4) = nexttile(31,[1 8]);    plot(time,rpl_signal,'b');                                                   xticks([]); ylabel('Ripple Power (zscore)');    hold on;    refline(0,RP_th);   hold off;
    ax(5) = nexttile(41,[1 8]);
    yyaxis left;    plot(time,vel_signal,'g','LineWidth',3);   ylabel('velocity (m/s)');    yyaxis left;    ylim([0 10]);
    yyaxis right;   plot(time,acc_signal,'c','LineWidth',1);   ylabel('acceleration (g)');  yyaxis right;   ylim([0 4]);
    ax(6) = nexttile(51,[1 8]);    spectrogram_AF_v0(spt_signal,Fs,0.5,0.05,[70 180]);      xlabel('Time(s)');  ylabel('Frequency (Hz)');
    linkaxes(ax,'x');       xlim([time(1),time(end)]);
    
    %=== Calculate and plot the PSD
    x = raw_signal; n = 2^nextpow2(length(x));
    Y = fft(raw_signal,n);  f = Fs*(0:(n/2))/n; P = abs(Y/n).^2;
    figure; %nexttile(9,[6 2]); % i want to PSD seperatly (Boaz) 
    plot(f,P(1:n/2+1),'-k'); hold on;   plot(f,smoothdata(P(1:n/2+1),'movmedian',3*n/Fs),'r','LineWidth',4);
    xlim([1 180]);    set(gca, 'YScale', 'log');    hold off;   xlabel('Frequency (Hz)');   h = gca;    h.YAxis.Visible = 'off';
     disp(['Chunk ',num2str(i)]);    pause; close all; 
    
end
%what? 
end