rainFiles = openFiles('rain.zip','rainfiles');

for file = {rainFiles.name}
    %fileName = 'rainfiles\rain0n35w_hr.cdf';
    fileName = 'rainfiles\' +string(file{1});
    timeData = ncread(fileName,'time');
    precLon = ncread(fileName,'lon');
    precLat = ncread(fileName,'lat');

    precipitationData = ncread(fileName,'RN_485');
    precipitation = squeeze(precipitationData(:,:,1,:)); % units is mm/hr
    timeDescrip = ncreadatt(fileName, 'time','units'); % reads in start time
    if contains(fileName, '10m')
        startTime = erase(timeDescrip, 'minutes since '); % strips words
        startTime = datetime(startTime);
        adjustedTime = dateshift(startTime, 'start', 'minute', timeData); % calculate dates based on minutes
        numDays = timeData(end)/(24*60);
    else
        startTime = erase(timeDescrip, 'hours since');
        startTime = datetime(startTime);
        adjustedTime = dateshift(startTime, 'start', 'hour', timeData);
        numDays = adjustedTime(end)-adjustedTime(1);
    end
    currentMonth = month(startTime);
    currentYear = year(startTime);

    tt = timetable(adjustedTime, precipitation);

    intervalStart = datetime(year(adjustedTime(1)),month(adjustedTime(1)),day(adjustedTime(1))+1,0,0,0);
    intervals = intervalStart + days(0:5:numDays);

    fiveDayMax = struct("middle", {}, "intervalData",{}, "avgData",{},"max", {},"percmissing", {});

    for m=1:size(intervals,2)-1 % dividing the month up into 5-day intervals
        intervalRange = timerange(intervals(1,m),intervals(1,m+1)-caldays(1),'days');
        fiveDayInterval = tt(intervalRange,:);
        fiveDayInterval.precipitation(fiveDayInterval.precipitation < 0,:) = 0; %Are we setting negative values to 0 or throwing them out? Gives a different mean
        fiveDayMax(end+1).middle = intervals(1,m) + days(2) + hours(12);
        NaNCounter = 0;
        for i=1:size(fiveDayInterval,1)
            if isnan(fiveDayInterval(i,1).precipitation)
                NaNCounter = NaNCounter + 1;
            end
        end
        percNaN = NaNCounter/size(fiveDayInterval,1);
        fiveDayMax(end).percmissing = percNaN;
        if isempty(fiveDayInterval)
            continue
        end
        if percNaN > 0.20
            fiveDayMax(end).intervalData = fiveDayInterval;
            fiveDayMax(end).max = 0;
        else
            fiveDayInterval=rmmissing(fiveDayInterval); %remove missing data
            fiveDayMax(end).intervalData = fiveDayInterval;
            counter = 0;
            currentDay = day(fiveDayInterval(1,1).adjustedTime);
            dayIntervals = fiveDayInterval(1,1).adjustedTime + caldays(0:1:5);
            fiveDayAvg = struct('day',{},'avg',{});
            for j=1:size(dayIntervals, 2)-1
                dayRange = timerange(dayIntervals(1,j),dayIntervals(1,j+1)-caldays(1),'days');
                dayValues = fiveDayInterval(dayRange,:);
                dayAvg = mean(dayValues.precipitation);
                fiveDayAvg(end+1).day = dayIntervals(1,j);
                fiveDayAvg(end).avg = dayAvg;
            end
            fiveDayMax(end).avgData = fiveDayAvg;
            fiveDayMax(end).max= max([fiveDayAvg.avg]);
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
        %  monthData = [monthData; currentMax.max];
        % monthNames = [monthNames; repmat({string(i)},size(currentMax,1),1)];
        newTable = true;
    end
    for i=1:size(mooringValues,2)
        if mooringValues(1,i).lat == precLat && mooringValues(1,i).lon == precLon
            [M, I] = max([monthMax.median]);
            if contains(fileName, '10m')
                mooringValues(i).maxRain_10m= M;
                mooringValues(i).minRain_10m = min([monthMax.median]);
                mooringValues(i).rainRatio_10m = max([monthMax.median])/min([monthMax.median]);
                mooringValues(i).maxrainMonth_10m = I;
            else
                mooringValues(i).maxRain_hr= M;
                mooringValues(i).minRain_hr = min([monthMax.median]);
                mooringValues(i).rainRatio_hr = max([monthMax.median])/min([monthMax.median]);
                mooringValues(i).maxrainMonth_hr = I;
            end
        end
    end
end
%end
%boxplot(monthData, monthNames)
%xticklabels({'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'})
%     graphname = 'graphs2\'+string(extractBetween(fileName,'sssfiles\','.cdf')) + 'months.fig';
%     savefig(graphname);


%save('values2.mat', mooringValues);

function fileList = openFiles(folder, targetFolder)
unzip(folder, targetFolder);
gunzip(string(targetFolder)+'/*.gz'); % decompress files
delete(string(targetFolder)+'/*.gz'); % delete compressed files
fileList = dir(fullfile(targetFolder,'*.cdf'));
end