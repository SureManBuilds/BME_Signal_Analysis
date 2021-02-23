function [Selection_Content, File_Names] = Select_Specific_Files(File_Type_In, Selection_Type)
[File_Names,Dir_Path] = uigetfile(File_Type_In, char(strcat('Select One or More',Selection_Type',' Files')), 'MultiSelect', 'on');

if isequal(File_Names,0)
  Selection_Content = [];
  File_Names = [];
else
    Selection_Content = cellstr(fullfile(Dir_Path,File_Names));
    File_Names = cellstr(File_Names);
end


end






