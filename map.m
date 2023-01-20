mymap = [0.7,0.3,0.1
0.7,0.3,0.3
0.7,0.2,0.5
0.7,0.3,0.6
0.6,0.3,0.8
0.4,0.4,0.8
0.3,0.5,0.7
0.2,0.5,0.6
0.1,0.5,0.4
0.2,0.5,0.2
0.4,0.5,0.1
0.6,0.4,0.1];

load coastlines
% worldmap world
% geoshow(coastlat,coastlon,"DisplayType","polygon", ...
%     "FaceColor",[0.9 1 0.9])
% scatterm([mooringValues.lat], [mooringValues.lon],10*[mooringValues.ratio],"filled")

cmap = jet;
load coastlines

ymin = -25; ymax = 25;
xmin = 120; xmax = -60;
latlim = [ymin ymax];
longlim = [xmin xmax];
[polylat1,polylong1] = maptrimp(coastlat,coastlon,latlim,longlim);

axesm('mapprojection','lambcyln','maplatlimit',[ymin ymax],'maplonlimit',[xmin xmax]);
fillm(polylat1,polylong1,[.8 .8 .8]); 
scatterm([mooringValues.lat], [mooringValues.lon],30*[mooringValues.ratio],[mooringValues.maxMonth],"filled")
setm(gca,'mlabelparallel','south','grid','on')
colormap(mymap)
colorbar
mlabel
plabel
title('max/min stv salinity - Pacific moorings') %Atlantic

% Pacific values
scatterm([22 22 22 22],[-165 -155 -145 -135],[30*2 30*4 30*6 30*8],'black','filled');
ht=textm(18,-165.5,'2');
setm(ht);
ht=textm(18,-155.5,'4');
setm(ht);
ht=textm(18,-145.5,'6');
setm(ht);
ht=textm(18,-135.5,'8');
setm(ht);

% Atlantic values
% scatterm([22 22 22 22],[15 25 35 45],[30*2 30*4 30*6 30*8],'black','filled');
% ht=textm(18,14.5,'2');
% setm(ht);
% ht=textm(18,24.5,'4');
% setm(ht);
% ht=textm(18,34.5,'6');
% setm(ht);
% ht=textm(18,44.5,'8');
% setm(ht);

tightmap




