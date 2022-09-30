
function extract_cortex_batch(workingDir)
% extracts the cortex files  

c3dList = dir([workingDir filesep '*Cluster.c3d']); % find all the cluster c3d files in the directory 

    if isempty(c3dList) % make sure that it found the files  
        msgbox('No files found to analyze','ERROR', 'error') 
    else 

        for fileNum = 1:length(c3dList)
            
        [Markers,VideoFrameRate,AnalogSignals,AnalogFrameRate,Event,ParameterGroup,CameraInfo,ResidualError]=readC3D_analog([workingDir filesep c3dList(fileNum).name]); %convert file
        CortexTTLtimes = extract_TTL_timeStamps(AnalogSignals,AnalogFrameRate);

        save([workingDir,'\',c3dList(fileNum).name '_track' '.mat'],'AnalogFrameRate','AnalogSignals','Markers','VideoFrameRate','CortexTTLtimes');
        
        end 
    end 
end 

