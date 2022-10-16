
%Testing audio recording 
% 2022 09 04 - Boaz 

%load data 
Audiodir = dir('F:\Ephys_1\Audio\220929\29953\094333\*.mat'); % change according to rec
audioFileAll = []; 


% creat on file out of all the files

% NEED to find the shared peak (all files have a ~3 sec overlap, and conc over the peak from both sides (find first peak and last peak in consecative))

for fileNum = 1:10 %length(Audiodir)
load([Audiodir(fileNum).folder,'\',Audiodir(fileNum).name],'recbuf');
audioFile = recbuf(:,8); 

audioFileAll = cat(1,audioFileAll,audioFile); 
disp(['combining file num: ',num2str(fileNum)])
end




% channel mapping:
% ch2 = mic near F2 (top right). set gain lower then most ch on red dot
% so that it does not saturate the sounds from close distance (we want sound on feeder not in the room)



% play a selected channel: 
chan = 2;
Playerobj = audioplayer(audioFileAll(:,chan)*10,192000);
play(Playerobj)

