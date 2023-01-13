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
startTime = erase(timeDescrip, 'minutes since '); % strips words
startTime = datetime(startTime);
currentMonth = month(startTime);
currentYear = year(startTime);
adjustedTime = dateshift(startTime, 'start', 'minute', timeData); % calculate dates based on minutes

tt = table(adjustedTime, precipitation); % table with times and salinity values
%precipitationByMonths = struct('month', {}, 'data',{},'average',{});
[h,m,s]= hms(startTime);
if h ~= 0 || m ~=0 || s ~=0
    [y,m,d] = ymd(startTime);
    newStart = datetime(y,m,d+1,0,0,0);
    for i=1:size(tt,1)
        if newStart ~= tt(i,1).adjustedTime
       %     disp('dumb')
       %disp(tt(i,1).adjustedTime)
            tt(1,:)=[];
            disp(tt(1,1));
        else
            break
        end
    end
end
disp('out of loop')
disp(tt(1,1))
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
        fiveDayTable = table([],[],'VariableNames',["days", "precipitation"]);
        precipitationTotal = tt(i,2).precipitation;
        newinterval = false;
    elseif dayCounter < 5 && currentDay == day(tt(i,1).adjustedTime)
      %  fiveDayTable = [fiveDayTable; {tt(i,1).adjustedTime, ];
        precipitationTotal = precipitationTotal + tt(i,2).precipitation;
    elseif dayCounter < 5
        currentDay = day(tt(i,1).adjustedTime);
        dayCounter = dayCounter + 1;
        fiveDayTable = [fiveDayTable; {tt(i-1,1).adjustedTime, precipitationTotal}];
        precipitationTotal = 0;
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

save('rain25s100e_10m.mat', 'fiveDayOld','fiveDayStv');