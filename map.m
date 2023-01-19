load coastlines
% worldmap world
% geoshow(coastlat,coastlon,"DisplayType","polygon", ...
%     "FaceColor",[0.9 1 0.9])
% scatterm([mooringValues.lat], [mooringValues.lon],10*[mooringValues.ratio],"filled")

% cmap = jet;
% load coastlines
% ymin = -25; ymax = 25;
% xmin = -60; xmax = 120;
% latlim = [ymin ymax];
% longlim = [xmin xmax];
% [polylat1,polylong1] = maptrimp(coastlat,coastlon,latlim,longlim);
% 
% axesm('mapprojection','lambcyln','maplatlimit',[ymin ymax],'maplonlimit',[xmin xmax]);
% fillm(polylat1,polylong1,[.8 .8 .8]); 
% scatterm([mooringValues.lat], [mooringValues.lon],30*[mooringValues.ratio],[mooringValues.maxMonth],"filled")
% %hold o
% %setm(gca,'plabellocation',[-60:1:60],'frame','on','grid','on','mlabelparallel','south')
% %setm(gca,'MLabelLocation',1)
% setm(gca,'mlabelparallel','south','grid','on')
% colormap(CustomColormap1)
% colorbar
% mlabel
% plabel
% title('max/min std salinity - Atlantic moorings')
% scatterm([22 22 22 22],[0 15 30 45],[30*2 30*4 30*6 30*8],'black','filled');
% ht=textm(18,-0.5,'2');
% setm(ht);
% ht=textm(18,14.5,'4');
% setm(ht);
% ht=textm(18,29.5,'6');
% setm(ht);
% ht=textm(18,44.5,'8');
% setm(ht);
% tightmap

% worldmap([-25 25],[-60 120])
% geoshow(coastlat,coastlon,"DisplayType","polygon", ...
%     "FaceColor",[0.7 0.7 0.7])
% scatterm([mooringValues.lat], [mooringValues.lon],30*[mooringValues.ratio],[mooringValues.maxMonth],"filled")
% 
% scatterm([20 20 20 20],[0 15 30 45],[30*2 30*4 30*6 30*8],'red','filled');
% ht=textm(16,0,'2');
% setm(ht);
% ht=textm(16,15,'4');
% setm(ht);
% ht=textm(16,30,'6');
% setm(ht);
% ht=textm(16,45,'8');
% setm(ht);

%setm(gca,'plabellocation',[-60:1:60],'frame','on','grid','on','mlabelparallel','south')
%setm(gca,'MLabelLocation',1)
% worldmap([-25 25], [120 -60]);
% geoshow(coastlat,coastlon,"DisplayType","polygon", ...
%     "FaceColor",[0.7 0.7 0.7])
% scatterm([mooringValues.lat], [mooringValues.lon],30*[mooringValues.ratio],"filled");
% 
% scatterm([20 20 20 20],[-180 -165 -150 -135],[30*2 30*4 30*6 30*8],'red','filled');
% ht=textm(16,-180,'2');
% setm(ht);
% ht=textm(16,-165,'4');
% setm(ht);
% ht=textm(16,-150,'6');
% setm(ht);
% ht=textm(16,-135,'8');
% setm(ht);


