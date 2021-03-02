function [Scope_Sheet Osc_Name_Array] = Investigate_Scopes(x_Lower, x_Upper, y_Lower, y_Upper, show_positive, show_negative, show_delay, osc_sampling_rate)

[Selection_Content, File_Names] = Select_Specific_Files('.csv', "Oscilloscope");
if isempty(Selection_Content)
    Scope_Sheet = array2table(zeros(2), 'VariableNames', {'Time (s)','None Selected'});
    Osc_Name_Array = {'None Selected'};
    return
end
All_Scope_Times = [];
All_Scope_Pulses = [];
All_Scope_Params = [];
[~, Selection_Scroll] = size(Selection_Content);
for i = 1:Selection_Scroll
    File_Name_Oscilloscope = char(Selection_Content(:,i));
    Oscilloscope_Matrix = readmatrix(File_Name_Oscilloscope);   
    Oscilloscope_Time = Oscilloscope_Matrix(:,1);
    Oscilloscope_Pulse = Oscilloscope_Matrix(:,2);
    Oscilloscope_Pulse(Oscilloscope_Time<x_Lower) = [];
    Oscilloscope_Time(Oscilloscope_Time<x_Lower) = [];
    Oscilloscope_Pulse(Oscilloscope_Time>x_Upper) = [];
    Oscilloscope_Time(Oscilloscope_Time>x_Upper) = [];
    [Result_Array Name_Array] = Get_Pulse_Parameters_Extractor(Oscilloscope_Pulse, Oscilloscope_Time);
    
    All_Scope_Times = [All_Scope_Times, Oscilloscope_Time];
    All_Scope_Pulses = [All_Scope_Pulses, Oscilloscope_Pulse];  
    All_Scope_Params = [All_Scope_Params, Result_Array'];
end

Mean_All_Pulses = mean(All_Scope_Pulses,2);
Mean_All_Times = mean(All_Scope_Times,2);
Mean_All_Params = mean(All_Scope_Params,2);
Std_All_Pulses = std(All_Scope_Pulses,0,2);
Osc_Name_Array = [];
%Plot Pulses Separately
for i = 1:Selection_Scroll
if ishandle(i)
    close(i)
end
figure(i)
plot(All_Scope_Times(:,i),All_Scope_Pulses(:,i), 'LineWidth',1.6)
if (show_positive == 1)
hold on
plot(All_Scope_Times(All_Scope_Params(7,i),i),All_Scope_Params(3,i),'or','LineWidth',2)
hold off
end
if (show_negative == 1)
hold on
plot(All_Scope_Times(All_Scope_Params(6,i),i),All_Scope_Params(1,i),'ob','LineWidth',2)
hold off
end
if (show_delay == 1)
hold on
plot([All_Scope_Params(8,i) All_Scope_Params(9,i)],[0 0],'*g','LineWidth',2)
hold off
end
xlabel('Time, (ns)','fontweight','bold','fontsize',12)
ylabel('Amplitude, (kV)','fontweight','bold','fontsize',12)
ylim([y_Lower y_Upper])
xlim([x_Lower x_Upper])
txt1 = sprintf('Positive peak: %.2fkV width: %.2fns', All_Scope_Params(3,i), All_Scope_Params(4,i));
txt2 = sprintf('Negative peak: %.2fkV width: %.2fns', All_Scope_Params(1,i), All_Scope_Params(2,i));
txt3 = sprintf('Delay: %.2fns ', All_Scope_Params(5,i));
title({txt1,txt2,txt3});
legend(File_Names(i))
Osc_Name_Array = [Osc_Name_Array, File_Names(i)];
end

%Plot mean of pulses
if ishandle(i+1)
    close(i+1)
end
[Result_Array Name_Array] = Get_Pulse_Parameters_Extractor(Mean_All_Pulses, Mean_All_Times);
figure(i+1)

hold on
for j = 1:width(All_Scope_Pulses)
    plot(All_Scope_Times(:,j),All_Scope_Pulses(:,j), 'LineWidth',0.5,'color',[0.8 0.8 0.8])
end

plot(Mean_All_Times,Mean_All_Pulses, 'LineWidth',1,'color','black')
erro = errorbar(Mean_All_Times(1:osc_sampling_rate:end),Mean_All_Pulses(1:osc_sampling_rate:end),Std_All_Pulses(1:osc_sampling_rate:end)/sqrt(length(File_Names)),'r', 'LineWidth', 1);
erro.LineStyle = 'none';
hold off
xlabel('Time, (ns)','fontweight','bold','fontsize',12)
ylabel('Mean Amplitude, (kV)','fontweight','bold','fontsize',12)
ylim([y_Lower y_Upper])
xlim([x_Lower x_Upper])
txt1 = sprintf('Mean Positive peak: %.2fkV width: %.2fns', Result_Array(3), Result_Array(4));
txt2 = sprintf('Mean Negative peak: %.2fkV width: %.2fns', Result_Array(1), Result_Array(2));
txt3 = sprintf('Mean Delay: %.2fns ', Result_Array(5));
title({txt1,txt2,txt3});
legend('Mean of all',strcat('SEM, n = ',string(length(File_Names))))


if ishandle(i+2)
    close(i+2)
end
figure(i+2)

hold on
for j = 1:width(All_Scope_Pulses)
    plot(All_Scope_Times(:,j),All_Scope_Pulses(:,j))
end
hold off
xlabel('Time, (ns)','fontweight','bold','fontsize',12)
ylabel('Mean Amplitude, (kV)','fontweight','bold','fontsize',12)
ylim([y_Lower y_Upper])
xlim([x_Lower x_Upper])
title('All Pulses');

     
    Scope_Sheet = [Mean_All_Times,All_Scope_Pulses, Mean_All_Pulses,Std_All_Pulses, Std_All_Pulses./sqrt(length(File_Names))];
    %parse names heere too
    Scope_Sheet = array2table(Scope_Sheet, 'VariableNames', ["Time (s)",Osc_Name_Array, "Mean", "STD", "SEM"]);
end