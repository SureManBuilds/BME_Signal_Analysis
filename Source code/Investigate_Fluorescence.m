function [Fluorescence_Sheet, All_Flur_Names] = Investigate_Fluorescence(x_Lower, x_Upper, y_Lower, y_Upper, F_Sampling_Rate, F_Search_Low, F_Search_High, Show_Bounds_Flag, Show_BG_Flag)

Crop_To_Time = x_Upper;

Time_Step_Threshold = 0.01; %Set as constant, to declutter menu. Change this to change Threshold for time sampling differences between sheets.
Frames_Before_Peak = 10; %Same problem. Change this to average more points.
[Selection_Content, File_Names] = Select_Specific_Files('.csv', "Fluorescence");
if isempty(Selection_Content)
    Fluorescence_Sheet = array2table(zeros(5), 'VariableNames', {'Time (s)','None Selected','Mean', 'STD', 'SEM'});
    All_Flur_Names = {'None Selected'};
    return
end
All_Flur_Times = [];
All_Flur_Pulses_Norm = [];
All_Flur_Pulses = [];
All_Flur_Params = [];
All_Flur_Names = [];
All_Flur_Peak_Locs = [];
All_Flur_Backgrounds = [];
for i = 1:length(Selection_Content)
    File_Name_Flur = char(Selection_Content(i));
    Flur_Matrix = readmatrix(File_Name_Flur);    
    Flur_Time = Flur_Matrix(:,1);   
    Flur_Matrix(Flur_Time > Crop_To_Time,:) = [];
    Flur_Time(Flur_Time > Crop_To_Time) = [];
    Flur_Pulse = Flur_Matrix(:,2:end-1);
    Flur_Background = Flur_Matrix(:,end);   
    [row, col] = size(Flur_Pulse);
    All_Flur_Pulses = [All_Flur_Pulses, Flur_Pulse];
    Flur_Background_Multiple = ones(row,col).*Flur_Background;
    All_Flur_Backgrounds = [All_Flur_Backgrounds, Flur_Background_Multiple]; %Sloppy way of making backgrounds match pulses for more than one cell in recording.
    
   %Normalize
    for Peak_Low_Index = 1:length(Flur_Time)
       if Flur_Time(Peak_Low_Index) >= F_Search_Low
         break
       end
    end
    for Peak_High_Index = Peak_Low_Index:length(Flur_Time)
      if Flur_Time(Peak_High_Index) >= F_Search_High
         break
      end
    end
    for jk = 1:col      
        Flur_Pulse(:,jk) = Flur_Pulse(:,jk) - Flur_Background;
        Normalizing_Factor = mean(Flur_Pulse(Peak_Low_Index-10:Peak_Low_Index,jk));
        Flur_Pulse(:,jk) = Flur_Pulse(:,jk) ./   Normalizing_Factor;     
        [MainPeak MainPeakLoc] = max(diff(Flur_Pulse(Peak_Low_Index:Peak_High_Index,jk)));
        MainPeakLoc = MainPeakLoc + Peak_Low_Index - 1;
        All_Flur_Params = [All_Flur_Params, MainPeak];
        All_Flur_Peak_Locs = [All_Flur_Peak_Locs, MainPeakLoc];
        All_Flur_Names = [All_Flur_Names, strcat(char(File_Names(i))," Cell: ",string(jk))];
        All_Flur_Times = [All_Flur_Times, Flur_Time];
    end
   
    All_Flur_Pulses_Norm = [All_Flur_Pulses_Norm, Flur_Pulse];  
end







Mean_All_Pulses = mean(All_Flur_Pulses_Norm,2);
Mean_All_Times = mean(All_Flur_Times,2);
Mean_All_Params = mean(All_Flur_Params,2);
Std_All_Pulses = std(All_Flur_Pulses_Norm,0,2);

cell_time_difference = diff(Mean_All_Times); 
cell_time_average = mean(cell_time_difference);
cell_time_vector_check = diff(cell_time_average');
if (any(cell_time_vector_check >= Time_Step_Threshold))
     error('Your fluorescence sampling rate was not consistent, check your traces.\n Increasing Time_Step_Threshold in the script that produced this error can also help(Not recommended)');
end




%Plot Pulses Separately
for i = 1:width(All_Flur_Pulses_Norm)
if ishandle(i+1000)
    close(i+1000)
end
figure(i+1000)
plot(All_Flur_Times(:,i),All_Flur_Pulses_Norm(:,i), 'LineWidth',1.2 )
hold on
ta = annotation('textarrow',[234/900 235/900],[0.15 0.25],'Color', 'black') ;
 s= ta.LineWidth;
 ta.LineWidth = 2;
 if Show_Bounds_Flag
red_line = 0.8:0.01:1.2;
red_line_time = ones(1,length(red_line));
plot(F_Search_Low*red_line_time, red_line , 'r','LineWidth',1.6)
plot(F_Search_High*red_line_time, red_line , 'r','LineWidth',1.6)
plot(All_Flur_Times(All_Flur_Peak_Locs(i),i)*red_line_time, red_line , 'b','LineWidth',1.6)
 end
hold off
xlabel('Time, (s)','fontweight','bold','fontsize',12)
ylabel('F/F_0','fontweight','bold','fontsize',12)
ylim([y_Lower y_Upper])
xlim([x_Lower x_Upper])
txt1 = sprintf('Ca2+ Peak: %.2f', All_Flur_Params(i));
title({txt1});
legend(All_Flur_Names(i))
if Show_BG_Flag
 axes('Position',[.635 .63 .25 .2])
 box on
plot(All_Flur_Times(:,i),All_Flur_Pulses(:,i), 'LineWidth',1.2 )
hold on
plot(All_Flur_Times(:,i),All_Flur_Backgrounds(:,i), 'LineWidth',1.2 )
hold off

xlim([x_Lower x_Upper])
end
end

%Plot mean of pulses
if ishandle(i+1+1000)
    close(i+1+1000)
end

figure(i+1+1000)
hold on
for j = 1:width(All_Flur_Pulses_Norm)
plot(All_Flur_Times(:,j),All_Flur_Pulses_Norm(:,j), 'LineWidth',1.2, 'color' , [0.8 0.8 0.8], 'HandleVisibility','off')
end
plot(Mean_All_Times,Mean_All_Pulses, 'LineWidth',1,'color','black')
erro = errorbar(Mean_All_Times(1:F_Sampling_Rate:end),Mean_All_Pulses(1:F_Sampling_Rate:end),Std_All_Pulses(1:F_Sampling_Rate:end)/sqrt(length(All_Flur_Names)),'r', 'LineWidth', 1);
erro.LineStyle = 'none';
hold off
xlabel('Time, (s)','fontweight','bold','fontsize',12)
ylabel('F/F_0','fontweight','bold','fontsize',12)
ylim([y_Lower y_Upper])
xlim([x_Lower x_Upper])
txt1 = sprintf('Mean Ca2+ Peak: %.2f', All_Flur_Params(j));
title({txt1});
legend('Mean of all',strcat('SEM, n = ',string(length(All_Flur_Names))))

if ishandle(i+2+1000)
    close(i+2+1000)
end
figure(i+2+1000)
hold on
for j = 1:width(All_Flur_Pulses_Norm)
plot(All_Flur_Times(:,j),All_Flur_Pulses_Norm(:,j))
end
hold off
xlabel('Time, (s)','fontweight','bold','fontsize',12)
ylabel('F/F_0','fontweight','bold','fontsize',12)
ylim([y_Lower y_Upper])
xlim([x_Lower x_Upper])
txt1 = sprintf('Ca2+ Peak: %.2f', All_Flur_Params(j));
title('All Recordings');


    Fluorescence_Sheet = [Mean_All_Times,All_Flur_Pulses_Norm, Mean_All_Pulses,Std_All_Pulses, Std_All_Pulses./sqrt(length(All_Flur_Names))];
    %parse names heere too
     Fluorescence_Sheet = array2table(Fluorescence_Sheet, 'VariableNames', ["Time (s)",All_Flur_Names, "Mean", "STD", "SEM"]); 
end


 

