function [Result_Array Name_Array] = Get_Pulse_Parameters_Extractor(Pulse_In, Time_In)
Interp_Time = Time_In(1):0.01:Time_In(end);
Interp_Pulse = interp1(Time_In,smooth(Pulse_In),Interp_Time);
%Get min/max

[~, MinIndxN] = min(Pulse_In);
[~, MaxIndxN] = max(Pulse_In);

[MinAmp, MinIndx] = min(Interp_Pulse);
[MaxAmp, MaxIndx] = max(Interp_Pulse);
% A better way to calculate: just multiply 
for FixedInterpIndex = 1:length(Interp_Time)
    if Interp_Time(FixedInterpIndex) >= Time_In(MinIndxN)
        break
    end
end
MinIndx = FixedInterpIndex;        
        
if MinIndx <= MaxIndx
    error('The Pulse was flipped');
end
%Get half-widths
for Index_L_Max=MaxIndx:-1:1
    if Interp_Pulse(Index_L_Max) <= MaxAmp/2             
       break
    end
end

for Index_R_Max=MaxIndx:length(Interp_Pulse)
    if Interp_Pulse(Index_R_Max) <= MaxAmp/2             
       break
    end
end    
       
for Index_L_Min=MinIndx:-1:1
    if Interp_Pulse(Index_L_Min) >= MinAmp/2
        break
    end
end
for Index_R_Min=MinIndx:length(Interp_Pulse)
    if Interp_Pulse(Index_R_Min) >= MinAmp/2
        break
    end
end

MaxWid = Interp_Time(Index_R_Max) - Interp_Time(Index_L_Max);
MinWid = Interp_Time(Index_R_Min) - Interp_Time(Index_L_Min);
%Get Delay
for Delay_Start=MaxIndx:length(Interp_Pulse)
   if Interp_Pulse(Delay_Start) <= 0             
      break
   end
end  
%use line equation to estimate delay end
t1 = Index_L_Min;
t2 = t1+1;
m = (Interp_Pulse(t2) - Interp_Pulse(t1))/(Interp_Time(t2)-Interp_Time(t1));
Delay_End = -Interp_Pulse(t1)/m + Interp_Time(t1);
%Delay index calculation, rework this 
for Delay_End_INDX = 1:length(Interp_Time)
    if Interp_Time(Delay_End_INDX) >= Delay_End
        break
    end
end
Delay = Interp_Time(Delay_End_INDX) - Interp_Time(Delay_Start);

Result_Array=[MinAmp MinWid MaxAmp MaxWid Delay MinIndxN MaxIndxN Interp_Time(Delay_Start) Interp_Time(Delay_End_INDX)];
Name_Array=["MinAmp","MinWid","MaxAmp","MaxWid","Delay","MinIndxN","MaxIndxN","Time_R_Max" ," Time_L_Min"];

