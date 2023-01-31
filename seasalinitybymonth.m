sssFiles = openFiles('sss.zip','sssfiles');

mooringValues = struct('lat',{},'lon',{},'maximum',{},'minimum',{},'ratio',{});

for file = {sssFiles.name}
    fileName = 'sssfiles\' +string(file{1});
    %fileName = 'sssfiles\sss2n137e_hr.cdf';
    timeData = ncread(fileName,'time');
    salinityData = ncread(fileName,'S_41');
    mooringValues(end+1).lat = ncread(fileName,'lat');
    mooringValues(end).lon = ncread(fileName,'lon');
    sssValues = salinityData(:,:,1,:);
    salinity = squeeze(sssValues); % puts salinity values in 1-D array

    timeDescrip = ncreadatt(fileName, 'time','units'); % reads in start time
    startTime = erase(timeDescrip, 'hours since '); % strips words
    %startTime = datetime(startTime);
    startTime = datetime(2007,1,5);
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
    monthData = [];
    monthNames = [];
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
        monthData = [monthData; currentStv.stv];
        monthNames = [monthNames; repmat({string(i)},size(currentStv,1),1)];
        newTable = true;
    end
    boxplot(monthData, monthNames)
    xticklabels({'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'})
    graphname = 'graphs2\'+string(extractBetween(fileName,'sssfiles\','.cdf')) + 'months.fig';
    xlabel('Time (months)')
    ylabel('sss')
    title('Mooring location '+ string(extractBetween(fileName,'sssfiles\sss','_hr.cdf')));
    savefig(graphname);
    [M, I] = max([monthStv.median]);
    mooringValues(end).maximum= M;
    mooringValues(end).minimum = min([monthStv.median]);
    mooringValues(end).ratio = max([monthStv.median])/min([monthStv.median]);
    mooringValues(end).maxMonth = I;

end
% bar([monthStv.median])
% xticklabels({'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'})
% xlabel('Time(months)')
% ylabel('Median std sea surface salinity for 5-day intervals')
% title('Salinity over months')


% fileName = 'output\'+ erase(fileName,'months.cdf') + '.mat';
% save(fileName,"fiveDayStv","monthStv")

function fileList = openFiles(folder, targetFolder)
    unzip(folder, targetFolder);
    gunzip(string(targetFolder)+'/*.gz'); % decompress files
    delete(string(targetFolder)+'/*.gz'); % delete compressed files
    fileList = dir(fullfile(targetFolder,'*.cdf'));
end