ncdisp('rainfiles/rain25s100e_10m.cdf');
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
precipitation = squeeze(precipitationData(:,:,1,:)); % units is mm/hr
fileName = 'rainfiles/rain25s100e_10m.cdf';
timeDescrip = ncreadatt(fileName, 'time','units'); % reads in start time
startTime = erase(timeDescrip, 'minutes since '); % strips words
startTime = datetime(startTime);
currentMonth = month(startTime);
currentYear = year(startTime);
adjustedTime = dateshift(startTime, 'start', 'minute', timeData); % calculate dates based on minutes

tt = table(adjustedTime, precipitation); % table with times and salinity values
%precipitationByMonths = struct('month', {}, 'data',{},'average',{});
fiveDayStv = struct("start", {}, "interval", {},"max", {});
newinterval = true;
dayCounter = 0;
for i=1:size(tt, 1)
    if tt(i,2).precipitation < 0
        tt(i,2).precipitation = 0;
    end
    if newinterval == true
        startDate = tt(i,1).adjustedTime;
        currentDay = day(tt(i,1).adjustedTime);
        fiveDayTable = table([tt(i,1).adjustedTime],[tt(i,2).precipitation],'VariableNames',["days", "precipitation"]);
        newinterval = false;
    elseif dayCounter < 5 && currentDay == day(tt(i,1).adjustedTime)
        fiveDayTable = [fiveDayTable; {tt(i,1).adjustedTime, tt(i,2).precipitation}];
    elseif dayCounter < 5
        currentDay = day(tt(i,1).adjustedTime);
        dayCounter = dayCounter + 1;
        if dayCounter == 5
            dayCounter = 0;
            fiveDayStv(end+1).start = startDate;
            fiveDayStv(end).interval = fiveDayTable;
            fiveDayStv(end).max = max(fiveDayTable.precipitation);
            fiveDayTable = table([tt(i,1).adjustedTime],[tt(i,2).precipitation],'VariableNames',["days", "precipitation"]);
            startDate = tt(i,1).adjustedTime;
        end
    end
end   
% newMonth = true;
% for i=1:size(precipitationValues,1)
%     if currentMonth ~= month(timePrecipitation.date(i)) 
%         currentMonth = month(timePrecipitation.date(i));
%         currentYear = year(timePrecipitation.date(i));
%         newMonth = true;
%         precipitationByMonths(end).data = monthData;
%     else
%         if timePrecipitation.precipitation(i) < 0
%             timePrecipitation.precipitation(i) = 0;
%         end
%         if newMonth == true
%             newMonth = false;
%             precipitationByMonths(end+1).month = timePrecipitation.date(i);
%                 monthData = table([timePrecipitation.date(i)],[timePrecipitation.precipitation(i)],'VariableNames',["times", "precipitation"]);
%         else
%             monthData = [monthData; {timePrecipitation.date(i), timePrecipitation.precipitation(i)}];
%         end
%     end
% end
% precipitationByMonths(end).data = monthData;
% 
% for j = 1:size(precipitationByMonths,2)
%     precipitationByMonths(j).average = mean(precipitationByMonths(j).data.precipitation);
% end
% 
% plot(precipitationByMonths.month, precipitationByMonths.average)
% save('rain25s100e_10m.mat', 'precipitationByMonths')
