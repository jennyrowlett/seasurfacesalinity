% open all the files from directory 
file_names = dir('sssfigures\*.fig');

for k=1:length(file_names)
   every_fig_name= 'sssfigures\' + string(file_names(k).name);
   fig(k) = openfig(every_fig_name);
   new_file_name = sprintf('%s.jpg', 'sssjpg\'+ extractBetween(every_fig_name,'sssfigures\','.fig'));
   saveas(fig(k), new_file_name);
end