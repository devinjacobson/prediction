function [eventData] = readRawData(fileID, precision, oPrecision, segSize, segNum, numSeg, ...
                                   firstByte, gotoBOF, readEvents, verbose);

% readRawData reads an EGI epoch-marked raw format file.
%
% Epoch-marked raw format: Unsegmented simple binary format, version # 2, 4 or 6.
%
% The single sample records (SSR) are extracted to form the x matrix,
% with one SSR per column.
%
% The corresponding event records, one per SSR, are extracted to form the
% eventData matrix, with one event record per column.
%
% Input Arguments: 
%
%   fileID      - EEG data file ID from fopen.
%
%   precision   - Input numeric precision string. 
% 
%   oPrecision  - Output numeric precision string. 
% 
%   firstByte   - File position indicator for 1st EEG data byte.
%
%   readEvents  - Logical 1 => read event data.
%
%   gotoBOF     - Logical 1 => rewind file pointer to 1st EEG data byte.
%
%   segNum      - Current segment (segment #1, segment #2, ...).
%
%   numSeg      - # of data segments.
%
%   segSize     - # of samples in current segment.
%
%   verbose     - Generate information for log file.
%
% Output Arguments:
%
%   x           - (Global Variable) Array of EEG data, channels x samples.
%
%   eventData   - Array of corresponding event data codes.
% 
%   logFile     - (Global Variable) Cell array of program and data information.
%
%   logFileIx   - (Global Variable) Pointer into logFile.
%
%   metaData    - (Global Variable) Structure array containing the files meta data.

global x metaData logFile logFileIx;

switch precision
    case 'integer*2'
        numBytes = 2;
    case 'real*4'
        numBytes = 4;
    case 'real*8'
        numBytes = 8;
end

% Read SSRs into array x, corresponding events into array eventData. -------------------------------------------------

if readEvents
    
    if (metaData.numEvents == 0)
        
        errMsg = sprintf('\n\nError (File Read): No Event Data\n\n');
        error(errMsg);
        
    end
    
    numRead = 0;
    eventData = zeros(metaData.numEvents, segSize, 'uint8');

    if gotoBOF
       fseek(fileID, firstByte, 'bof');
    end

    for j = 1 : segSize

        fseek(fileID, metaData.numCh * numBytes, 'cof');
        [eventData(:,j), tempCntr] = fread(fileID, metaData.numEvents, [precision '=>' oPrecision]);
        numRead = numRead + tempCntr;

    end
    
    if numRead ~= (metaData.numEvents * segSize)
      
        errMsg = sprintf('\n\nError (File Read): Event Data Array\n\n');
        error(errMsg);
       
    end
    
    if verbose
        
        logFileIx = logFileIx + 1;
        
        logFile{logFileIx} = ...
            sprintf('\nEvent Data Segment # %d of %d: %d x %d', segNum, numSeg, metaData.numEvents, segSize);
        
    end

else

    x = zeros(metaData.numCh, segSize);

    if gotoBOF
       fseek(fileID, firstByte, 'bof');
    end

    if (metaData.numEvents ~= 0)

        numRead = 0;

        for j = 1 : segSize

            [x(:,j), tempCntr] = fread(fileID, metaData.numCh, [precision '=>' oPrecision]);
            fseek(fileID, metaData.numEvents * numBytes, 'cof');
            numRead = numRead + tempCntr;

        end

    else
        
        [x, numRead] = fread(fileID, [metaData.numCh, segSize], [precision '=>' oPrecision]);

    end

    if (numRead ~= metaData.numCh * segSize)

        errMsg = sprintf('\n\nError (File Read): EEG Data Array\n\n');
        error(errMsg);

    end

    if verbose
        
        logFileIx = logFileIx + 1;
        
        logFile{logFileIx} = ...
            sprintf('\nEEG Data Segment # %d of %d: %d x %d', segNum, numSeg, metaData.numCh, segSize);
        
    end

end

% Finished reading SSRs and event data. ------------------------------------------------------------------------------------
