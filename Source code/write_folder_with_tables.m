function write_folder_with_tables(Folder_Name,...
               ItemsBox_Scope,ItemsBox_Flur,Fluorescence_Sheet,...
               Scope_Sheet,...
               All_Scope_Params,All_Raw_Scope_Times,...                 
               All_Raw_Scope_Pulses,All_Flur_Times,All_Flur_Pulses,...
               All_Flur_Backgrounds, Tags, Comments)
           %should be remade into a better function, but i am lazy rn
           mkdir(Folder_Name);

           filename = strcat(Folder_Name,'\Selected_Scope_Files.csv');         
           writecell(ItemsBox_Scope,filename, 'QuoteStrings',false);

           filename = strcat(Folder_Name,'\Selected_Flur_Files.csv');         
           writematrix(ItemsBox_Flur,filename, 'QuoteStrings',false);  
           
           filename = strcat(Folder_Name,'\Fluorescence_Sheet.csv');         
           writetable(Fluorescence_Sheet,filename);
           
           filename = strcat(Folder_Name,'\Scope_Sheet.csv');         
           writetable(Scope_Sheet,filename);  
           
           filename = strcat(Folder_Name,'\Raw_Scope_Params.csv');         
           writematrix(All_Scope_Params,filename);  
           
           filename = strcat(Folder_Name,'\Raw_Scope_Times.csv');         
           writematrix(All_Raw_Scope_Times,filename);  
           
           filename = strcat(Folder_Name,'\Raw_Scope_Pulses.csv');         
           writematrix(All_Raw_Scope_Pulses,filename); 
           
           filename = strcat(Folder_Name,'\Raw_Flur_Times.csv');         
           writematrix(All_Flur_Times,filename);  
           
           filename = strcat(Folder_Name,'\Raw_Flur_Pulses.csv');         
           writematrix(All_Flur_Pulses,filename);  
           
           filename = strcat(Folder_Name,'\Raw_Flur_Backgrounds.csv');         
           writematrix(All_Flur_Backgrounds,filename);  
            
           filename = strcat(Folder_Name,'\Tags.txt');         
           writecell(Tags,filename, 'QuoteStrings',false);  
           
           filename = strcat(Folder_Name,'\Comments.txt');         
           writecell(Comments,filename, 'QuoteStrings',false);
end