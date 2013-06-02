function [header, eegData, eventData, outputLog] = ReadRaw(fileName);

% Reads an EGI epoch-marked simple binary format (epoch-marked raw format) file.
%
% Epoch-marked raw format: Unsegmented simple binary format (raw format,
%                          version # 2, 4 or 6) with event codes <epoc> and <tim0>.
%
% The single sample records (SSR) are extracted to form the eegData matrix, where
% each column of the matrix (array) is one SSR.
% The  corresponding event records, one per SSR, are extracted to form the
% eventData matrix, where each column of the matrix (array) is one event record.
%
% Input Arguments: fileName - Name of the EGI epoch-marked simple binary format
%                             file, without the .raw extension.
%                             It must be a MATLAB string.
%
% Output Arguments: header - MATLAB structure array containing the header info.
% 
%                   eegData - m1 by n array containing the continuous EEG data.
%                             m1 = # of channels, n = # of time samples.
%
%                   eventData - m2 by n array containing the corresponding event info.
%                               m2 = # of event types, n = # of time samples
%
%                   outputLog - Character array of header information.
%

fid = fopen([fileName '.raw'],'r','b');

if (fid == -1)
    
    errorMsg = sprintf('\n!!! File Access Error: %s !!!\n', [fileName '.raw']); error(errorMsg);
    
end

outputLog = ['InputFile = <' fileName '.raw>'];  % Seed the outputLog.

% ----------------- Read the header info into the structure variable 'header'. --------------------

header.versionNumber = fread(fid, 1, 'integer*4');
outputLog = strvcat(outputLog, ['versionNumber = ' int2str(header.versionNumber)]);

switch header.versionNumber
   case {3, 5, 7}
       errorMsg = sprintf...
           ('\n!!! The File %s.raw Must Contain Unsegmented EEG Data !!!\n', fileName);
       error(errorMsg);
end

header.recordingTimeYear = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['recordingTimeYear = ' int2str(header.recordingTimeYear)]);

header.recordingTimeMonth = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['recordingTimeMonth = ' int2str(header.recordingTimeMonth)]);

header.recordingTimeDay = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['recordingTimeDay = ' int2str(header.recordingTimeDay)]);

header.recordingTimeHour = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['recordingTimeHour = ' int2str(header.recordingTimeHour)]);

header.recordingTimeMinute = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['recordingTimeMinute = ' int2str(header.recordingTimeMinute)]);

header.recordingTimeSecond = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['recordingTimeSecond = ' int2str(header.recordingTimeSecond)]);

header.recordingTimeMillisec = fread(fid, 1, 'integer*4');
outputLog = strvcat(outputLog, ['recordingTimeMillisec = ' int2str(header.recordingTimeMillisec)]);

header.samplingRate = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['samplingRate = ' int2str(header.samplingRate)]);

header.numChans = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['numChans = ' int2str(header.numChans)]);

header.boardGain = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['boardGain = ' int2str(header.boardGain)]);

header.numConvBits = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['numConvBits = ' int2str(header.numConvBits)]);

header.ampRange = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['ampRange = ' int2str(header.ampRange)]);

header.numSamples = fread(fid, 1, 'integer*4');
outputLog = strvcat(outputLog, ['numSamples = ' int2str(header.numSamples)]);

header.numEvents = fread(fid, 1, 'integer*2');
outputLog = strvcat(outputLog, ['numEvents = ' int2str(header.numEvents)]);

if (header.numEvents ~= 0)  % File contains event info.
    
    for i = 1:header.numEvents
        
        header.eventCodes(i) = {fread(fid, [1 4], 'uchar')};
        ithEventCode = char(header.eventCodes{i});
        outputLog = strvcat(outputLog, ['eventCode # ' int2str(i) ' = ' ithEventCode]);
        
    end
    
end

% ----------------------------- Finished reading the header. --------------------------------------

switch header.versionNumber
   case 2
       precision = 'integer*2';  % Integer
   case 4
       precision = 'real*4';  % Single Precision Real
   case 6
       precision = 'real*8';  % Double Precision Real
end

% -------- Read SSRs into array eegData and corresponding events into array eventData. -----------

eegDataCount = 0; eventDataCount = 0;
eegData = zeros(header.numChans, header.numSamples);

if (header.numEvents ~= 0)  % File contains event info.
    
    eventData = zeros(header.numEvents, header.numSamples);
    
    for i = 1:header.numSamples
        
        [eegData(:,i), eegTempCount] = fread(fid, header.numChans, precision);
        [eventData(:,i), eventTempCount] = fread(fid, header.numEvents, precision);
        eegDataCount = eegDataCount + eegTempCount;
        eventDataCount = eventDataCount + eventTempCount;
        
    end
    
else  % File does not contain event info.
    
    eventData = [];
    
    [eegData, eegDataCount] = fread(fid, [header.numChans, header.numSamples], precision);
    
end

% ---------------------- Finished reading SSRs and event data. ------------------------

% Verify that all the data was read.

if (header.numEvents ~= 0)  % File contains event info.
    
    if ((eegDataCount ~= header.numChans * header.numSamples) || ...
          (eventDataCount ~= header.numEvents * header.numSamples))
      
       errorMsg = sprintf('\n!!! Data Read Failure: EEG / Event Data Arrays !!!\n');
       error(errorMsg);
       
    end
    
else  % File does not contain event info.
    
    if (eegDataCount ~= header.numChans * header.numSamples)
        
        errorMsg = sprintf('\n!!! Data Read Failure: EEG Data Array !!!\n'); error(errorMsg);

    end
    
end

outputLog = strvcat(outputLog,['Array eegData: ' int2str(header.numChans) ' x ' int2str(header.numSamples)]);

if (header.numEvents ~= 0)  % File contains event info.
    
    outputLog = strvcat(outputLog,['Array eventData: ' int2str(header.numEvents) ' x ' int2str(header.numSamples)]);
    
end

fclose(fid);
