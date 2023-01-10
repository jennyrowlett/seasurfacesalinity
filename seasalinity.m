%rainFiles = openFiles('rain.zip','rainfiles');
sssFiles = openFiles('sss.zip','sssfiles');

for file = {sssFiles.name}
    fileName =  'sssfiles\' + string(file{1});
    timeData = ncread(fileName,'time');
    salinityData = ncread(fileName,'S_41');
    ssValues = salinityData(:,:,1,:); 
    salinityValues = squeeze(ssValues); % puts salinity values in 1-D array
    
    timeDescrip = ncreadatt(fileName, 'time','units'); % reads in start time
    startTime = erase(timeDescrip, 'hours since '); % strips words
    startTime = datetime(startTime);
    startMonth = month(startTime);
    startYear = year(startTime);
    adjustedTime = dateshift(startTime, 'start', 'hour', timeData); % calculate dates based on hours
    tt = timetable(adjustedTime, salinityValues); % table with times and salinity values
    timeBetween = between(startTime,adjustedTime(end));

    M = datetime(startYear,startMonth,1) + calmonths(0:calmonths(timeBetween)+1); % months array that starts with starting month
    stv = struct("date",{},"stv",{}, 'interval',{});
    salinitiesBy5Days = struct("salinities",{},'stv',{});
    salinitiesByMonth = struct("salinities",{});
    
    for c=1:size(M,2)-1
        y = year(M(1,c));
        stringM = month(M(1,c),'name');
        currentMonth = timerange(M(1,c),M(1,c+1)-caldays(1),'days'); % separates days into the correct month 
        monthSalinity = tt(currentMonth,:); % makes a table with the salinity values from 'currentMonth
        salinitiesByMonth(c).salinities = monthSalinity;
        intervals = M(1,c) + caldays(0:5:30); % creates intervals
        stvMonth = struct('date',{},'stv', {}); % cell array to hold standard deviations
        counter = 1;
        for m=1:size(intervals,2)-1 % dividing the month up into 5-day intervals
            dayRange = timerange(intervals(1,m),intervals(1,m+1)-hours(1),'hours');
            fiveDayInterval = monthSalinity(dayRange,:);
            salinitiesBy5Days(end+1).salinities = fiveDayInterval;
            if ~isnan(fiveDayInterval.salinityValues)
                S = std(fiveDayInterval.salinityValues);
                stvMonth(counter).stv = S;
                stvMonth(counter).date = string(intervals(1,m)) + '-' + string(intervals(1, m+1)-days(1));
                counter = counter + 1;
                salinitiesBy5Days(end).stv = S;
            end
        end
        average = mean([stvMonth.stv]);
        stv(c).date = string(stringM) +' ' + y;
        stv(c).stv = average;
        stv(c).interval = stvMonth;
    end
    fileName = 'output\'+ erase(string(file{1}),'.cdf') + '.mat';
    save(fileName, 'stv', 'tt','salinitiesBy5Days','salinitiesByMonth')
end


function fileList = openFiles(folder, targetFolder)
    disp(targetFolder)
    unzip(folder, targetFolder);
    gunzip(string(targetFolder)+'/*.gz'); % decompress files
    delete(string(targetFolder)+'/*.gz'); % delete compressed files
    fileList = dir(fullfile(targetFolder,'*.cdf'));
end