% open all the files from directory 
file_names = dir('sssfigures\*.fig');

% Now we have all the information about files such as filenames,date,size...
% Let us grab the filenames by using (.name) one by one by looping over all
% the file information
% Next using openfig() function open all the figures one by one
% Then lets create a new name for our fig (here I have choosen the same name with .jpg extension)
% Finally, save all the figures

for k=1:length(file_names)
   every_fig_name= 'sssfigures\' + string(file_names(k).name);
   fig(k) = openfig(every_fig_name);
   new_file_name = sprintf('%s.jpg', 'sssjpg\'+ extractBetween(every_fig_name,'sssfigures\','.fig'));
   saveas(fig(k), new_file_name);
end