%ncdisp('rainfiles/rain25s100e_10m.cdf');
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
if contains(fileName, '10m')
    startTime = erase(timeDescrip, 'minutes since '); % strips words
    startTime = datetime(startTime);
    adjustedTime = dateshift(startTime, 'start', 'minute', timeData); % calculate dates based on minutes

else
    startTime = erase(timeDescrip, 'hours since');
    startTime = datetime(startTime);
    adjustedTime = dateshift(startTime, 'start', 'hour', timeData); % calculate dates based on minutes
end
currentMonth = month(startTime);
currentYear = year(startTime);

tt = table(adjustedTime, precipitation); % table with times and salinity values
[h,m,s]= hms(startTime);
if h ~= 0 || m ~=0 || s ~=0
    [y,m,d] = ymd(startTime);
    newStart = datetime(y,m,d+1,0,0,0);
    for i=1:size(tt,1)
        if newStart ~= tt(1,1).adjustedTime
            tt(1,:)=[];
        else
            break
        end
    end
end
fiveDayMax = struct("middle", {}, "interval", {},"max", {});
newinterval = true;
dayCounter = 0;
for i=1:size(tt, 1)
    if tt(i,2).precipitation < 0
        tt(i,2).precipitation = 0;
    end
    if newinterval == true
        startDate = tt(i,1).adjustedTime;
        currentDay = day(tt(i,1).adjustedTime);
        fiveDayTable = table([],[],'VariableNames',["days", "precipitation"]);
        precipitationTotal = tt(i,2).precipitation;
        newinterval = false;
    elseif dayCounter < 5 && currentDay == day(tt(i,1).adjustedTime)
        precipitationTotal = precipitationTotal + tt(i,2).precipitation;
    elseif dayCounter < 5
        currentDay = day(tt(i,1).adjustedTime);
        dayCounter = dayCounter + 1;
        fiveDayTable = [fiveDayTable; {tt(i,1).adjustedTime-days(1), precipitationTotal}];
        precipitationTotal = 0;
    elseif dayCounter == 5
        dayCounter = 0;
        fiveDayMax(end+1).middle = startDate+days(2);
        fiveDayMax(end).interval = fiveDayTable;
        fiveDayMax(end).max = max(fiveDayTable.precipitation);
        precipitationTotal = precipitationTotal+ tt(i,2).precipitation;
        fiveDayTable = table([],[],'VariableNames',["days", "precipitation"]);
        startDate = tt(i-1,1).adjustedTime;
    end
end

monthMax = struct("month", {}, "maxData", {}, "median", {});
monthData = [];
monthNames = [];
newTable = true;
for i=1:12
    for j=1:size(fiveDayMax,2)
        if isnan(fiveDayMax(1,j).max)
            continue
        elseif month(fiveDayMax(j).middle) == i
            if newTable == true
                currentMax = table([fiveDayMax(1,j).middle],[fiveDayMax(1,j).max],'VariableNames',["days", "max"]);
                newTable = false;
            else
                currentMax = [currentMax; {fiveDayMax(1,j).middle,fiveDayMax(1,j).max}];
            end
        end
    end
    monthMax(end+1).month = datetime(2000,i,1,'format','MMM');
    monthMax(end).maxData = currentMax;
    monthMax(end).median = median(currentMax.max);
    monthData = [monthData; currentMax.max];
    monthNames = [monthNames; repmat({string(i)},size(currentMax,1),1)];
    newTable = true;
end

boxplot(monthData, monthNames)
xticklabels({'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'})
graphname = 'graphs2\'+string(extractBetween(fileName,'sssfiles\','.cdf')) + 'months.fig';
savefig(graphname);

