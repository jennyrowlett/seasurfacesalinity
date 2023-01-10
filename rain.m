ncdisp('rainfiles/rain25s100e_10m.cdf')
timeData = ncread('rainfiles/rain25s100e_10m.cdf','time');
precLon = ncread('rainfiles/rain25s100e_10m.cdf','lon');
precLat = ncread('rainfiles/rain25s100e_10m.cdf','lat');
precLocation = [precLon, precLat];
% for file = {sssFiles.name}
%     fileName =  'sssfiles\' + string(file{1});
%     sssLon = ncread(fileName, 'lon');
%     sssLat = ncread(fileName, 'lat');
%     sssLocation = [sssLon, sssLat];
%     if sssLocation == precLocation
%         disp(fileName)
%     end
% end
precipitationData = ncread('rainfiles/rain25s100e_10m.cdf','RN_485');
precipitationValues = squeeze(precipitationData(:,:,1,:)); % units is mm/hr
fileName = 'rainfiles/rain25s100e_10m.cdf';
timeDescrip = ncreadatt(fileName, 'time','units'); % reads in start time
startTime = erase(timeDescrip, 'minutes since '); % strips words
startTime = datetime(startTime);
currentMonth = month(startTime);
currentYear = year(startTime);
adjustedTime = dateshift(startTime, 'start', 'minute', timeData); % calculate dates based on minutes

timePrecipitation = struct('date', adjustedTime, 'precipitation', precipitationValues);
precipitationByMonths = struct('month', {}, 'data',{},'average',{});

newMonth = true;
for i=1:size(precipitationValues,1)
    if currentMonth ~= month(timePrecipitation.date(i)) 
        currentMonth = month(timePrecipitation.date(i));
        currentYear = year(timePrecipitation.date(i));
        newMonth = true;
        precipitationByMonths(end).data = monthData;
    else
        if newMonth == true
            newMonth = false;
            precipitationByMonths(end+1).month = string(month(timePrecipitation.date(i), 'shortname')) + '-' + string(year(timePrecipitation.date(i)));
            monthData = table([timePrecipitation.date(i)],[timePrecipitation.precipitation(i)],'VariableNames',["times", "precipitation"]);
        else
            monthData = [monthData; {timePrecipitation.date(i), timePrecipitation.precipitation(i)}];
        end
    end
end
precipitationByMonths(end).data = monthData;

for j = 1:size(precipitationByMonths,2)
    precipitationByMonths(j).average = mean(precipitationByMonths(j).data.precipitation);
end

save('rain25s100e_10m.mat', 'precipitationByMonths')
