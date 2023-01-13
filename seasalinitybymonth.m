%rainFiles = openFiles('rain.zip','rainfiles');
sssFiles = openFiles('sss.zip','sssfiles');

%for file = {sssFiles.name}
%fileName = 'sssfiles\' +string(file{1});
fileName = 'sssfiles\sss0n0e_hr.cdf';
timeData = ncread(fileName,'time');
salinityData = ncread(fileName,'S_41');
ssValues = salinityData(:,:,1,:);
salinity = squeeze(ssValues); % puts salinity values in 1-D array

timeDescrip = ncreadatt(fileName, 'time','units'); % reads in start time
startTime = erase(timeDescrip, 'hours since '); % strips words
startTime = datetime(startTime);
startMonth = month(startTime);
startYear = year(startTime);

adjustedTime = dateshift(startTime, 'start', 'hour', timeData); % calculate dates based on hours
tt = timetable(adjustedTime, salinity); % table with times and salinity values

numDays = timeData(end)/24;
intervalStart = datetime(year(startTime),month(startTime),day(startTime)+1,0,0,0);
intervals = intervalStart + caldays(0:5:numDays);

fiveDayStv = struct("start", {}, "intervalData", {},"stv", {},"percmissing", {});

for m=1:size(intervals,2)-1 % dividing the month up into 5-day intervals
    intervalRange = timerange(intervals(1,m),intervals(1,m+1)-caldays(1),'days');
    fiveDayInterval = tt(intervalRange,:);
    fiveDayStv(end+1).start = intervals(1,m) + days(2) + hours(12);
    NaNCounter = 0;
    for i=1:size(fiveDayInterval,1)
        if isnan(fiveDayInterval(i,1).salinity)
            NaNCounter = NaNCounter + 1;
        end
    end
    percNaN = NaNCounter/size(fiveDayInterval,1);
    fiveDayStv(end).percmissing = percNaN;
    if percNaN > 0.20
        fiveDayStv(end).intervalData = fiveDayInterval;
    else
        fiveDayInterval=rmmissing(fiveDayInterval); %remove missing data
        fiveDayStv(end).intervalData = fiveDayInterval;
    end
    fiveDayStv(end).stv = std(fiveDayInterval.salinity);
end

monthStv = struct("month", {}, "stvData", {}, "median", {});

% for i=1:12
%     disp(i)
% end
newTable = true;
for i=1:12
    for j=1:size(fiveDayStv,2)
        if isnan(fiveDayStv(1,j).stv) 
            continue
        elseif month(fiveDayStv(j).start) == i
            if newTable == true
                currentStv = table([fiveDayStv(1,j).start],[fiveDayStv(1,j).stv],'VariableNames',["days", "stv"]);
                newTable = false;
            else
                currentStv = [currentStv; {fiveDayStv(1,j).start,fiveDayStv(1,j).stv}];
            end
        end
    end
    monthStv(end+1).month = datetime(2000,i,1,'format','MMM');
    monthStv(end).stvData = currentStv;
    monthStv(end).median = median(currentStv.stv);
    newTable = true;
end

bar([monthStv.median])
xticklabels({'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'})
xlabel('Time(months)')
ylabel('median sea surface salinity for 5-day intervals')
title('Salinity over months')

graphname = string(extractBetween(fileName,'sssfiles\','.cdf')) + 'months.fig';
savefig(graphname);
fileName = 'output\'+ erase(fileName,'months.cdf') + '.mat';
save(fileName,"fiveDayStv","monthStv")

function fileList = openFiles(folder, targetFolder)
    unzip(folder, targetFolder);
    gunzip(string(targetFolder)+'/*.gz'); % decompress files
    delete(string(targetFolder)+'/*.gz'); % delete compressed files
    fileList = dir(fullfile(targetFolder,'*.cdf'));
end