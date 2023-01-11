%rainFiles = openFiles('rain.zip','rainfiles');
%sssFiles = openFiles('sss.zip','sssfiles');

%for file = {sssFiles.name}
fileName =  'sssfiles\sss21n23w_hr.cdf'; %+string(file{1})
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
tt = table(adjustedTime, salinity); % table with times and salinity values
fiveDayStv = struct("start", {}, "interval", {},"stv", {});
dayCounter = mod(day(tt(1,1).adjustedTime),5);
newinterval = true;
intervalCounter = 0;

for i=1:size(tt, 1)
    if newinterval == true
        startDate = tt(i,1).adjustedTime + days(2);
        currentDay = day(tt(i,1).adjustedTime);
        fiveDayTable = table([tt(i,1).adjustedTime],[tt(i,2).salinity],'VariableNames',["days", "salinity"]);
        newinterval = false;
    elseif dayCounter < 5 && currentDay == day(tt(i,1).adjustedTime)
        fiveDayTable = [fiveDayTable; {tt(i,1).adjustedTime, tt(i,2).salinity}];
    elseif dayCounter < 5
        currentDay = day(tt(i,1).adjustedTime);
        dayCounter = dayCounter + 1;
        if dayCounter == 5
            dayCounter = 0;
            fiveDayStv(end+1).start = startDate;
           % fiveDayStv(end).end = tt(i,1).adjustedTime;
            NaNcount = 0;
            for j=1:size(fiveDayTable,1)
                if isnan(fiveDayTable(j,2).salinity)
                    NaNcount = NaNcount + 1;
                end
            end
            percNaN = NaNcount/size(fiveDayTable,1);
            if percNaN > 0.20
                fiveDayStv(end).interval = fiveDayTable;
            else
                fiveDayTable=fiveDayTable(~any(ismissing(fiveDayTable),2),:); %remove missing data
                fiveDayStv(end).interval = fiveDayTable;
            end
            fiveDayStv(end).stv = std(fiveDayTable.salinity);
            fiveDayTable = table([tt(i,1).adjustedTime],[tt(i,2).salinity],'VariableNames',["days", "salinity"]);
            startDate = tt(i,1).adjustedTime;
        else
            fiveDayTable = [fiveDayTable; {tt(i,1).adjustedTime, tt(i,2).salinity}];
        end
    end
end    

plot([fiveDayStv.start], [fiveDayStv.stv])

save("output\sss21n23w_hr.mat","fiveDayStv")

function fileList = openFiles(folder, targetFolder)
    disp(targetFolder)
    unzip(folder, targetFolder);
    gunzip(string(targetFolder)+'/*.gz'); % decompress files
    delete(string(targetFolder)+'/*.gz'); % delete compressed files
    fileList = dir(fullfile(targetFolder,'*.cdf'));
end