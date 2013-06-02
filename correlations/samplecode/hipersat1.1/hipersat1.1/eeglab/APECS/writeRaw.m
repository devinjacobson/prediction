function writeRaw(fileName, precision, data, eventData, segSize, ...
                  headerSegSize, writeHeader, writeEventData, appendData);

% writeRaw writes data, stored in the array data, to the file <fileName.raw>, 
% along with its corresponding meta data and event information, if any.
%
% <fileName.raw> will be an epoch-marked raw format file.
%
% Epoch-marked raw format: Unsegmented simple binary format, version # 2, 4 or 6.
%
% Input Arguments:
%
%   fileName        - Name of EGI raw format file, sans extension (string).
%
%   metaData        - (Global Variable) MATLAB structure containing the meta data.
%
%   precision       - Output precision (integer, single, double).
%
%   data            - Array containing the data to be written.
%       
%   eventData       - Array containing the corresponding event info.
%
%   writeEventData  - Write out event data array, if present (T or F).
%
%   appendData      - Append data to file (T) or overwrite (F).
%
%   writeHeader     - Prepend simple-binary raw format header (T or F).
%
%   segSize         - # of samples in current segment.
%
%   headerSegSize   - # of samples to write into header.
%
% Output Arguments:
%
%   logFile         - (Global Variable) Text log of runtime information.

global metaData logFile logFileIx;

% Create the EGI epoch-marked raw format data file: <fileName.raw>. ---------------------------------------------------------

if appendData
    fid = fopen([fileName '.raw'],'a','b');
else
    fid = fopen([fileName '.raw'],'w','b');
end

if (fid == -1)
    errMsg = sprintf('\n\nError (File Open): %s\n\n', [fileName '.raw']);
    error(errMsg);
end

% Write the MetaData information to the file. ---------------------------------------------------------------------------------

if writeHeader
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = sprintf('\nWriteRaw Log: Writing File < %s >', [fileName '.raw']);

    fwrite(fid, metaData.versionNumber, 'integer*4');
    fwrite(fid, metaData.recordingTimeYear, 'integer*2');
    fwrite(fid, metaData.recordingTimeMonth, 'integer*2');
    fwrite(fid, metaData.recordingTimeDay, 'integer*2');
    fwrite(fid, metaData.recordingTimeHour, 'integer*2');
    fwrite(fid, metaData.recordingTimeMinute, 'integer*2');
    fwrite(fid, metaData.recordingTimeSecond, 'integer*2');
    fwrite(fid, metaData.recordingTimeMillisec, 'integer*4');
    fwrite(fid, metaData.samplingRate, 'integer*2');
    fwrite(fid, metaData.numCh, 'integer*2');
    fwrite(fid, metaData.boardGain, 'integer*2');
    fwrite(fid, metaData.numConvBits, 'integer*2');
    fwrite(fid, metaData.ampRange, 'integer*2');
    fwrite(fid, headerSegSize, 'integer*4');
    
    if writeEventData && metaData.numEvents
        
        fwrite(fid, metaData.numEvents, 'integer*2');
        
        for  i = 1 : metaData.numEvents
            
            fwrite(fid, metaData.eventCodes{i}, 'uchar');
            
        end
        
    else
        
        fwrite(fid, 0.0, 'integer*2');
        
    end
    

end

% Write SSR's and corresponding event records to the file. --------------------------------------------------------------------

if writeEventData && metaData.numEvents
    
    for i = 1 : segSize
        
        fwrite(fid, data(:,i), precision);
        fwrite(fid, eventData(:,i), precision);
        
    end
    
else
    
    fwrite(fid, data, precision);
    
end

% Close the file. -----------------------------------------------------------------------------------------------------------

fclose(fid);

