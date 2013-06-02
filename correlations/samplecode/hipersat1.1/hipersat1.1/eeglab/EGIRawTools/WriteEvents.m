function WriteEvents(fileName, header, eventData)

fid = fopen([fileName '.txt'], 'w');

if (fid == -1)
    errMsg = sprintf('\n!!! File Creation Error: %s !!!\n', [fileName '.txt']); error(errMsg);
end

usrMsg = sprintf('\nWriting NetStation formatted event data to file: %s', [fileName '.txt']);
disp(usrMsg);

deltaT = (1000 / header.samplingRate);  % Time in milliseconds, sampling rate in Hz.

for j = 1:header.numSamples
    eventPntr = find(eventData(:, j) == 1);
    for i = 1:length(eventPntr)
        fprintf(fid, '%s\t%s\r', num2str((j-1)*deltaT), char(header.eventCodes{eventPntr(i)}));
    end
end

usrMsg  = sprintf('\nNetStation formatted event data written to file: %s', [fileName '.txt']);
disp(usrMsg);

fclose(fid);
