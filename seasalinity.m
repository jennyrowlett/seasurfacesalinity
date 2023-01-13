%rainFiles = openFiles('rain.zip','rainfiles');
sssFiles = openFiles('sss.zip','sssfiles');

%for file = {sssFiles.name}
%   fileName = 'sssfiles\' +string(file{1});
fileName = 'sssFiles\sss0n0e_hr.cdf';
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
currentMonth = startMonth;
currentYear = startYear;
newtable = true;
for i=1:size(fiveDayStv,2)
    if newtable == true
        currentStv = table([fiveDayStv(1,i).start],[fiveDayStv(1,i).stv],'VariableNames',["days", "stv"]);
        newtable = false;
    elseif currentMonth == month(fiveDayStv(i).start)
        currentStv = [currentStv; {fiveDayStv(1,i).start,fiveDayStv(1,i).stv}];
    else
        monthStv(end+1).month = datetime(currentYear,currentMonth,1);
        monthStv(end).stvData = currentStv;
        monthStv(end).median = median(currentStv.stv);
        currentStv = table([fiveDayStv(1,i).start],[fiveDayStv(1,i).stv],'VariableNames',["days", "stv"]);
        currentMonth = month(fiveDayStv(i).start);
        currentYear = year(fiveDayStv(i).start);
    end
end




monthIntervalStv = struct('month',{},'data',{},'interval',{});
newTable = true;
for i=1:12
    for j=1:size(monthStv,2)
        if isnan(monthStv(j).median)
            continue
        end
        if month(monthStv(j).month) == i
            monthIntervalStv(end+1).month = i;
            monthIntervalStv(end).data = monthStv(1,j).median;
            monthIntervalStv(end).interval = monthStv(1,j).month;
%             if newTable == true
%                 currentStv = table([monthStv(1,j).month],[monthStv(1,j).median],'VariableNames',["year", "median"]);
%                 newTable = false;
%             else
%                 currentStv = [currentStv; {monthStv(1,j).month,monthStv(1,j).median}];
%             end
        end
    end
    %monthIntervalStv(end+1).month = i;
   % monthIntervalStv(end).data = currentStv;
 %   newTable = true;
end
%end
plot([monthIntervalStv.month], [monthIntervalStv.data],'.')
xlim([0 13])
% sssgraph = plot([monthStv.month], [monthStv.median]);
% xlabel('time(months)')
% ylabel('median standard deviation of sss')
% graphname = string(extractBetween(fileName,'sssfiles\','.cdf')) + '.fig';
% savefig(graphname);
% fileName = 'output\'+ erase(string(file{1}),'.cdf') + '.mat';
% save(fileName,"fiveDayStv","monthStv")

function fileList = openFiles(folder, targetFolder)
    unzip(folder, targetFolder);
    gunzip(string(targetFolder)+'/*.gz'); % decompress files
    delete(string(targetFolder)+'/*.gz'); % delete compressed files
    fileList = dir(fullfile(targetFolder,'*.cdf'));
end