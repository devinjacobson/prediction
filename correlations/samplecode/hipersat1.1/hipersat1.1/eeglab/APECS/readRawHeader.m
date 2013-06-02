function [fileID, firstByte, precision] =  readRawHeader(fileName);

% readRawHeader reads an EGI epoch-marked raw format file. 
%
% Epoch-marked raw format: Unsegmented simple binary format, version # 2, 4 or 6.
%
% Input Arguments:
%
%   fileName    - Name of EGI raw format file, sans extension (string).
%
% Output Arguments:
%
%   metaData    - (Global Variable) Structure array containing the files meta data.
% 
%   logFile     - (Global Variable) Cell array of program and data information.
%
%   logFileIx   - (Global Variable) Pointer into logFile.
%
%   fileID      - EEG data file ID from fopen.
%
%   firstByte   - File position indicator for 1st EEG data byte.
%
%   precision   - Numeric precision string. 

global metaData logFile logFileIx;

logFile = {};
logFileIx = 0;

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nInput (.raw) File Meta-Data ----------------------------------------------------');

% Open the data file. ----------------------------------------------------------------------------------

fileID = fopen([fileName '.raw'], 'r', 'b');

if (fileID == -1)
    
    error(sprintf('\n\nError (File Open): %s\n\n', [fileName '.raw']));

end

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nReadRawHeader Input File: %s', [fileName '.raw']);

% Read the header info into the structure variable 'metaData'. -----------------------------------------

metaData.versionNumber = fread(fileID, 1, 'integer*4');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('VersionNumber = %d', metaData.versionNumber);

switch metaData.versionNumber

   case {3, 5, 7}
       error(sprintf('\n\nError (File Type): Epoc-Marked Raw Format Only\n\n'));

end

metaData.recordingTimeYear = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('RecordingTimeYear = %d', metaData.recordingTimeYear);

metaData.recordingTimeMonth = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('RecordingTimeMonth = %d', metaData.recordingTimeMonth);

metaData.recordingTimeDay = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('RecordingTimeDay = %d', metaData.recordingTimeDay);

metaData.recordingTimeHour = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('RecordingTimeHour = %d', metaData.recordingTimeHour);

metaData.recordingTimeMinute = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('RecordingTimeMinute = %d', metaData.recordingTimeMinute);

metaData.recordingTimeSecond = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('RecordingTimeSecond = %d', metaData.recordingTimeSecond);

metaData.recordingTimeMillisec = fread(fileID, 1, 'integer*4');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('RecordingTimeMillisec = %d', metaData.recordingTimeMillisec);

metaData.samplingRate = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('SamplingRate = %d', metaData.samplingRate);

metaData.numCh = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('NumberOfChannels = %d', metaData.numCh);

metaData.boardGain = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('BoardGain = %d', metaData.boardGain);

metaData.numConvBits = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('NumberOfConvBits = %d', metaData.numConvBits);

metaData.ampRange = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('AmpRange = %d', metaData.ampRange);

metaData.numSmpl = fread(fileID, 1, 'integer*4');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('NumberOfSamples = %d', metaData.numSmpl);

metaData.numEvents = fread(fileID, 1, 'integer*2');
logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('NumberOfEvents = %d', metaData.numEvents);

for i = 1:metaData.numEvents

    metaData.eventCodes{i} = fread(fileID, [1, 4], 'uchar');
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = sprintf('EventCode #%d = %s', i, char(metaData.eventCodes{i}));

end

firstByte = ftell(fileID);
    
% Finished reading the header. -------------------------------------------------------------------------

switch metaData.versionNumber

   case 2
       precision = 'integer*2';
   case 4
       precision = 'real*4';
   case 6
       precision = 'real*8';

end
