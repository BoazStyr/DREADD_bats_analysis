
function extract_cortex_batch(workingDir)
% extracts the cortex files and clac the global timestamps to use with other data streams.  

c3dList = dir([workingDir filesep '*Cluster.c3d']); % find all the cluster c3d files in the directory 

    if isempty(c3dList) % make sure that it found the files  
        msgbox('No files found to analyze','ERROR', 'error') 
    else 

        for fileNum = 1:length(c3dList)
            disp(['working on file num: ',num2str(fileNum)])
        [Markers,VideoFrameRate,AnalogSignals,AnalogFrameRate,Event,ParameterGroup,CameraInfo,ResidualError]=readC3D_analog([workingDir filesep c3dList(fileNum).name]); %convert file
        
        [CortexTTLtimes_us,Cortex_timeStamps_local_us] = extract_Cortex_TTL_timeStamps(AnalogSignals,AnalogFrameRate); % find local timestmaps and TTL timestmaps
        global_sample_timestamps_usec = local2GlobalTime(CortexTTLtimes_us,Cortex_timeStamps_local_us); % clac. the global timestmaps (this is what we save)
        
        save([workingDir,'\',c3dList(fileNum).name '_track' '.mat'],'AnalogFrameRate','AnalogSignals','Markers','VideoFrameRate','global_sample_timestamps_usec');
        msgbox(['File number: ',num2str(fileNum),' is done.'])
        end 
    end 
end 

