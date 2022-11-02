

files = dir('D:\Ephys_1\Analysis_Workspaces\*.mat'); 
 MFRHzAll = []; 

for dayNum = 1:6

  load([files(dayNum).folder,filesep,files(dayNum).name]) 

  MFRcalc_v2

  MFRHzAll = cat(2,MFRHzAll,MFRHz); 

end 

   MFR_BL = mean(MFRHzAll(1:20,:)); % when i input 20 min beofre DCZ into the MFRcalc_v2 
   MFRHzBLnormed = MFRHzAll ./ MFR_BL; 

   