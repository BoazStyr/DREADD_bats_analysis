

%%%  we assume you already read the video as 'v' using ReadVideo and the
%%%  time corrected spike times for a unit

% params: 
startTime =  60*40+12; % in sec 
totalTime = 30; % in se
downSampleFactor = 10; % how many frames to jump to save time and increase diff
SpikeTimesSec_all  = SpikeData.global_SpikeTimes_Sec_all; 

% %create color for each unit
% for ColorNum = 1:length(SpikeTimesSec_all)
% 
% Unit_Colors{ColorNum} = [rand rand rand]; 
% 
% end 

 close all; 
 
figure(1); 
set(gcf, 'Color','w','Position',[86 430 1720 831]);
%%%%%%% now run thru the frames %%%%


writerObj = VideoWriter('SideVidAndSpikes20220930_DCZ.avi');
writerObj.FrameRate = 10; 
open(writerObj);

v.CurrentTime = startTime; 
counter = 2;
tic 
while hasFrame(v) 

    if v.CurrentTime < (startTime + totalTime) 
        counter = counter+1; 
        f = readFrame(v); 
        imshow(f)
        title(['Time(sec): ',num2str(v.CurrentTime)])
        % count spikes in frame bin
        SpikeBinStart = v.CurrentTime; 
        SpikeBinend =  v.CurrentTime + (1/v.FrameRate)*downSampleFactor;
        for unit = 1:length(SpikeTimesSec_all)

                hold on;
                plot(800-(unit*65), 50,'*','Color',Unit_Colors{unit},'MarkerSize',20); % put the unit color for ref on the image
  
                SpikeTimesSec = SpikeTimesSec_all{unit}; 
                SpikesinBin = SpikeTimesSec(SpikeTimesSec>= SpikeBinStart & SpikeTimesSec <= SpikeBinend); 
    
            if ~isempty(SpikesinBin) 
                hold on;
                plot(800-(unit*65), 50,'o','Color','w','MarkerFaceColor',Unit_Colors{unit},'MarkerSize',10+10*length(SpikesinBin)); 
                hold off; 
            end 
        end    
        frame = getframe; 
        writeVideo(writerObj, frame);

        %pause(0.01)
        %disp(['time: ',num2str(v.CurrentTime)])
        
        v.CurrentTime  =  v.CurrentTime + (1/v.FrameRate)*downSampleFactor; % move to next time according to sampling factor
        SpikesinBin = []; 
    else 
        disp('analysis ended')
        close(writerObj);
        break
    end 
end 
toc 



