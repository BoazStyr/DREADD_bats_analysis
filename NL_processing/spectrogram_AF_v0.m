function spectrogram_AF_v0(signal,Fs,dt,dt_shift,f_range)
%% Custom made function for plotting spectrogram(AF,2022)

% INPUTS:
% signal:       signal
% Fs:           sampling frequency
% dt:           length (s) of the window for calculating PSD
% dt_shift:     length (s) of the forward movement of the window
% f_range:      frequency range over which the PSD is calculated

% %=== Test
% Fs = 1e3;
% t = [0:1/Fs:100];
% signal = chirp(t,50,100,300,'quadratic');
% spectrogram_AF_v0(signal,Fs,1,0.1,[50 500])

%=== Params
n = 2^nextpow2(Fs*dt);          % Optimal number of samples
closest_dt = n/Fs;              % Closest time window that corresponds to n samples
dn = round(dt_shift*Fs);        % Number of samples to shift
sigma_t = 2;                    % Smoothing over time
sigma_f = 4;                    % Smoothing over frequency

%=== Routine for calculating the PSD
y = signal;
if ~isrow(y),y=y';end           % Make sure y is a row vector
c = 1; PS = []; f = [];
while size(y,2)> n+dn
    
    Y = fft(y(1:n));        % Calculate fft of the first n samples
    P = abs(Y/n).^2;        % Calculate associated power
    PS(c,:) = P(1:n/2+1);    % Keep only positive frequencies
    y = y(dn+1:end);        % Cut dn samples from the trace
    c = c+1;
    
end

%=== Calculate the frequeny values
f = linspace(0,Fs/2,size(PS,2));

%=== Keep custom frequency range
[~,f1] = min(abs(f-f_range(1)));
[~,f2] = min(abs(f-f_range(2)));
f = f(1,f1:f2); PS = PS(:,f1:f2);

%=== Calculate first and last samples of the spectrogram
first_sample = round(n/2);
last_sample = length(signal)-n+round(n/2);
last_sample = first_sample + (size(PS,1)-1)*dn;

%=== Flip PS array: frequency (descending) x time epochs
PS = PS';   %PS = flipud(PS);

%=== Plot
imagesc([first_sample last_sample]/Fs,f_range,imgaussfilt(PS,[sigma_t sigma_f]));
%yticklabels(flip(yticklabels));     title(['Frequency resolution ~ ', num2str(1/closest_dt,2), ' Hz']);
set(gca,'YDir','normal');

end