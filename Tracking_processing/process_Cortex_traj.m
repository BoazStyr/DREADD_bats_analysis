function [flightPaths,Flights,AllFlights] = process_Cortex_traj(CortexDir,date,batID)
% This script processes the Cortex tracking data to get flightPaths and
% other related data, and also give the global ts for the tracking data. 


% == user input example: 
% CortexDir = 'D:\Ephys_1\Cortex\extracted_cortex_29953'; 
% date = '20221001'; 
% batID = 29953; 


% load the cortex extracted data 
FileName = dir([CortexDir,filesep,'*',date,'*.mat']); 
load([FileName(1).folder,filesep,FileName(1).name]); 

% get the global ts for this day: 
[CortexTTLtimes_us,Cortex_timeStamps_local_us] = extract_Cortex_TTL_timeStamps(AnalogSignals,AnalogFrameRate); 
global_Cortex_ts_usec = local2GlobalTime(CortexTTLtimes_us,Cortex_timeStamps_local_us);
global_Cortex_ts_Sec = global_Cortex_ts_usec/1e6; 

% now segement flights 

Flights = FlightSegment(Markers,batID,1,0); % go to the script that segements the flights.  
Flights.date = date; % store the date of this expriment day
AllFlights = []; 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % === now we run the script for getting flight traj (from lab- Angelo version). depends on imBat reop   
     
     M = Flights.M*1000; 
     AllFlights = cat(1,AllFlights,M'); % i do *1000 becaue in Angelo code its going to redo the /1000 
     DayIndex = ones(1,length(Flights.M')); 
     FlightsTime = ((1:length(AllFlights))*1/120)';
                           
     flightPaths = ImBat_flightsAngelo(AllFlights,FlightsTime,'fs',30,'n_splines',30,'dist',2,'day_index',DayIndex);
     flightPaths.global_ts_Sec = global_Cortex_ts_Sec; 
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


