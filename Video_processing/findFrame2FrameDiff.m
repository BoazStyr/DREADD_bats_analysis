
% this code calc the sum of the diff (across the middle raw of the image to
% save compute) of 2 consecutive frames to help detect feeding times. 

%%%  we assume you already read the video as 'v' using ReadVideo %%%

% params: 
startTime =  45; % in sec 
totalTime = 300; % in se
headXY = [530,400]; 
bodyXY = [350,300]; 
headWin = 70; 
bodyWin = 100; 
downSampleFactor = 10; % how many frames to jump to save time and increase diff
fDiff_head = nan(1,round(totalTime*v.FrameRate)); % preallocate 
fDiff_body = nan(1,round(totalTime*v.FrameRate)); % preallocate 
showmovie = 1; % if set to 1, shows the movie as it calc. 

if showmovie == 1 % prep the figure if you want to show it
    close all; 
    figure; 
    set(gcf, 'Color','w','Position',[86	430 1720 831]);
end 

% we pre calc the baseline diff of frame 1 so that we can use it to norm 
v.CurrentTime = startTime; 
f = readFrame(v);
v.CurrentTime  =  v.CurrentTime + (1/v.FrameRate)*downSampleFactor; % get time for next frame
f2 = readFrame(v); % read next frame
%calc the diff for the first one, we use this as "baseline" to norm to. 
fDiff_head_BL = sum(f2(headXY(2)-headWin:headXY(2)+headWin,headXY(1)-headWin:headXY(1)+headWin)-f(headXY(2)-headWin:headXY(2)+headWin,headXY(1)-headWin:headXY(1)+headWin),'all');
fDiff_body_BL = sum(f2(bodyXY(2)-bodyWin*1.5:bodyXY(2)+bodyWin*1.5,bodyXY(1)-bodyWin:bodyXY(1)+bodyWin)-f(bodyXY(2)-bodyWin*1.5:bodyXY(2)+bodyWin*1.5,bodyXY(1)-bodyWin:bodyXY(1)+bodyWin),'all');


%%%%%%% now run thru the frames %%%%
v.CurrentTime = startTime; 
counter = 0;

tic 
while hasFrame(v) 
    if v.CurrentTime < (startTime + totalTime) 
        counter = counter+1; 
        f = readFrame(v); 
        v.CurrentTime  =  v.CurrentTime + (1/v.FrameRate)*downSampleFactor; % get time for next frame
        f2 = readFrame(v); % read next frame 
        
        %calc the diff between the frames
        fDiff_head(counter) = sum(f2(headXY(2)-headWin:headXY(2)+headWin,headXY(1)-headWin:headXY(1)+headWin)-f(headXY(2)-headWin:headXY(2)+headWin,headXY(1)-headWin:headXY(1)+headWin),'all')/fDiff_head_BL;
        fDiff_body(counter) = sum(f2(bodyXY(2)-bodyWin*1.5:bodyXY(2)+bodyWin*1.5,bodyXY(1)-bodyWin:bodyXY(1)+bodyWin)-f(bodyXY(2)-bodyWin*1.5:bodyXY(2)+bodyWin*1.5,bodyXY(1)-bodyWin:bodyXY(1)+bodyWin),'all')/fDiff_body_BL; 
        
        if showmovie == 1 % show the movie: 
        %subplot(2,2,[1,3]); imshow(f); xline([headBbox-diffheadWin,headBbox+diffheadWin],'r','LineWidth',2); xline([bodyDiff-diffbodyWin,bodyDiff+diffbodyWin],'b','LineWidth',2); title(['Time(sec): ',num2str(v.CurrentTime)]);
        subplot(2,2,[1,3]); imshow(f); 
        rectangle('Position',[headXY(1)-headWin,headXY(2)-headWin,headWin*2,headWin*2],'EdgeColor','r');  title(['Time(sec): ',num2str(v.CurrentTime)]);
        rectangle('Position',[bodyXY(1)-bodyWin,bodyXY(2)-bodyWin,bodyWin*2,bodyWin*3],'EdgeColor','b'); 
       
        subplot(2,2,2); plot(fDiff_head(1:counter),'r'); title('diff around head')
        ylim([0,10]); 
        subplot(2,2,4); plot(fDiff_body(1:counter),'b'); title('diff around body')
        ylim([0,10]); 
        else 
        end 
    
    else 
        disp('analysis ended')
        plot(fDiff_head(1:counter),'k')
        break
    end 

end 
toc 



