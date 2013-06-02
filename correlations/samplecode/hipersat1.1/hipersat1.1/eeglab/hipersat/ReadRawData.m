function ReadRawData(fid, precision);

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
%   fid         - EEG data file ID from fopen.
%
%   precision   - Input numeric precision string. 
% 
% Output Arguments:
%
%   x           - (Global Variable) Array of EEG data, channels x samples.
%
%   events      - (Global Variable) Array of event code flags, codes x samples.
%
%   metaData    - (Global Variable) Structure array containing the files meta data.

global metaData x events;

switch precision
    case 'integer*2'
        numByte = 2;
    case 'real*4'
        numByte = 4;
    case 'real*8'
        numByte = 8;
end

% Read SSRs into array x, corresponding events into array eventData. ------------------------------

if metaData.numEvents

    errFlag =  0;

    eventIX = ftell(fileID) + (metaData.numCh * numByte);
    
    [x , numEEG] = fread(fileID, [metaData.numCh, metaData.numSamples], [int2str(metaData.numCh) '*' precision], metaData.numEvents * numByte);
    
    fseek(fileID, eventIX, 'bof');
    
    [events , numEvt] = fread(fileID, [metaData.numEvents, metaData.numSamples], [int2str(metaData.numEvents) '*' precision], metaData.numCh * numByte);
    
    fseek(fileID, 0, 'eof');
    
    if (numEEG ~= metaData.numCh * metaData.numSamples)

        errMsg1 = 'Error (File Read): EEG Data Array';
        errFlag = 1;

    else
        
        errMsg1 = [];
        
    end
    
    if (numEvt ~= metaData.numEvents * metaData.numSamples)
      
        errMsg2 = 'Error (File Read): Event Data Array';
        errFlag = 1;
       
    else
        
        errMsg2 = [];
        
    end
    
    if errFlag
        
        errordlg( strvcat(errMsg1, errMsg2) , 'File Read Error' );
        return;
        
    end
    
    for i = 1 : metaData.numEvents
        
        epoc = strcmpi('epoc', char(metaData.eventCodes{i}));
        
        if epoc
            
            metaData.epocIX = i;
            metaData.numEpoc = sum(events(metaData.epocIX,:));
            break;
            
        end
        
    end
    
else
        
    [x, numEEG] = fread(fid, [metaData.numCh, metaData.numSamples], precision);

    if (numEEG ~= metaData.numCh * metaData.numSamples)

        errordlg( 'Error (File Read): EEG Data Array' , 'File Read Error' );
        return;

    end

end

% Finished reading SSRs. --------------------------------------------------------------------------

fclose(fid);
