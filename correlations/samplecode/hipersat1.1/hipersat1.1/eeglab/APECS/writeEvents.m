function [eyeCode] = writeEvents(fileName, eventData);

global metaData logFile logFileIx;

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nWriteEvents Log: Writing File < %s >', [fileName '_EC.txt']);

fid = fopen([fileName '_EC.txt'], 'w');

if (fid == -1)
    errMsg = sprintf('\n\nError (File Open): %s\n\n', [fileName '_EC.txt']);
    error(errMsg);
end

deltaT = (1000 / metaData.samplingRate);  % Time in milliseconds, sampling rate in Hz.

for j = 1 : metaData.numSmpl

    eventPntr = find(eventData(:, j) == 1);

    for i = 1 : length(eventPntr)
        fprintf(fid, '%s\t%s\r', num2str((j - 1) * deltaT), char(metaData.eventCodes{eventPntr(i)}));
    end

end

fclose(fid);

if metaData.numEvents

    for i = 1 : metaData.numEvents
        eyeCode(i) = strcmpi('eyeb', char(metaData.eventCodes{i})) | strcmpi('ueye', char(metaData.eventCodes{i}));
    end
    
    eyeCode = find(eyeCode);
    
else

    eyeCode = [];
    
end