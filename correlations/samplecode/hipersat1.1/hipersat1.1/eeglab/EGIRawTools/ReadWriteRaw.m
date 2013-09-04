% ReadWriteRaw.m: Script M-file to automate reading & writing of EGI epoch-marked raw format files.

% Epoch-marked raw format: Unsegmented simple binary format (raw format,
%                          version # 2, 4 or 6) with event codes <epoc> and <tim0>.

clc;

readWrite = input('\nDo you wish to read (R) from or write (W) to a ''.raw'' format file? ','s');

if ~((readWrite == 'R') | (readWrite == 'r') | (readWrite == 'W') | (readWrite == 'w'))
    
    errMsg = sprintf...
        ('\n!!! Next Time, Please Type One Of The Following: R, r, W, or w !!!\n');
    error(errMsg);
    
end

fileName = input('\nEnter the ''.raw'' format file name, without the extension: ', 's');

whosThere = who;
gotHeader = sum(strcmp(whosThere, {'header'}));
gotEegData = sum(strcmp(whosThere, {'eegData'}));
gotEvents = sum(strcmp(whosThere, {'eventData'}));

if ((readWrite == 'W') | (readWrite == 'w'))
    
    if ~gotEegData  % EEG data is not in the array <eegData>.
        
        errMsg = sprintf...
            ('\n!!! The EEG Data Must Be In An Array Named <eegData> !!!\n');
        error(errMsg);
        
    end
    
    if gotHeader % You've got a header for your EEG data.
        
       if ~isa(header, 'struct')
        
           errMsg = sprintf('\n!!!The Header Data Must Be A MATLAB Structure !!!\n');
           error(errMsg);
        
       end
       
       usrMsg = sprintf('\nThe raw format header IS present in the MATLAB workspace.');
       disp(usrMsg);

       if (header.numEvents ~= 0)  % There must be event markers accompanying EEG data.
           
           if ~gotEvents
               
               errMsg = sprintf...
                   ('\n!!! The Event Data Must Be In An Array Named <eventData> !!!\n');
               error(errMsg);
               
           end
           
           usrMsg = sprintf('\nThe event data IS present in the MATLAB workspace.');
           disp(usrMsg);

           [outputLog] = WriteRaw(fileName, header, eegData, eventData);
           
           usrMsg = sprintf('\nRun-Time Information:');  disp(usrMsg);  disp(outputLog);

       else % There are no events with this EEG data.
           
           usrMsg = sprintf('\nThere are no event data corresponding to this EEG data.');
           disp(usrMsg);
           
           eventData = [];
           
           [outputLog] = WriteRaw(fileName, header, eegData, eventData);
           
           usrMsg = sprintf('\nRun-Time Information:');  disp(usrMsg);  disp(outputLog);

       end
   
    else  % Header structure NOT present.
        
       usrMsg = sprintf(['\nThe raw format header is NOT present in the MATLAB workspace.' ...
                         '\nThe program will now assume that the # of event codes = 0.']);
       disp(usrMsg);
        
       header = struct('versionNumber', 0, 'recordingTimeYear', 0, 'recordingTimeMonth', 0, ...
           'recordingTimeDay', 0, 'recordingTimeHour', 0, 'recordingTimeMinute', 0, ...
           'recordingTimeSecond', 0, 'recordingTimeMillisec', 0, 'samplingRate', 0, ...
           'numChans', 0, 'boardGain', 0, 'numConvBits', 0, 'ampRange', 0, ...
           'numSamples', 0, 'numEvents', 0);  eventData = [];
       
       [numChans, numSamples] = size(eegData);
       
       usrMsg = sprintf('\nNumber of Channels = %d; Number of Time Samples = %d', numChans, numSamples);
       disp(usrMsg);
       
       Ok = input('\nIs this correct (Y/N) ? ', 's');
       
       if ((Ok == 'n') | (Ok == 'N'))
           
           errMsg = sprintf...
               ('\n!!! Size Of Array <eegData> = (# Of Channels) by (# Of Time Samples) !!!\n');
           error(errMsg);
           
       end
       
       samplingRate = input('\nEnter the sampling rate: ');
       precision = input('\nInteger Data (I), Single Precision Real (S), Double Precision Real (D) ? ', 's');
       
       switch precision
           case {'I', 'i'}
               versionNumber = 2;
           case {'S', 's'}
               versionNumber = 4;
           case {'D', 'd'}
               versionNumber = 6;
           otherwise
               errMsg = sprintf...
                  ('\n!!! Next Time, Please Type One Of The Following: I, i, S, s, D or d !!!\n');
               error(errMsg);
       end
       
       addEvents = input...
           ('\nAdd epoch-marked raw format events ''epoc'' and ''tim0'' with default values = 0 (Y/N) ? ', 's');
       
       switch addEvents
           case {'Y', 'y'}
               addEvents = 1;
           case {'N', 'n'}
               addEvents = 0;
           otherwise
               errMsg = sprintf...
                  ('\n!!! Next Time, Please Type One Of The Following: Y, y, N or n !!!\n');
               error(errMsg);
       end
       
       [outputLog] = ...
          WriteRaw(fileName, header, eegData, eventData, ...
                   addEvents, numChans, numSamples, samplingRate, versionNumber);
     
       usrMsg = sprintf('\nRun-Time Information:');  disp(usrMsg);  disp(outputLog);
      
    end
    
else  % Read in the data.
    
    [header, eegData, eventData, outputLog] = ReadRaw(fileName);
    
    % Display the header info.

    usrMsg = sprintf('\nHeader Information:\n');  disp(usrMsg);  disp(outputLog);
    
    if (header.numEvents ~= 0)
        eventText = input('\nOutput events to NetStation compatible text file (Y/N)? ', 's');
        if (eventText == 'Y') | (eventText == 'y')
            WriteEvents(fileName, header, eventData);
        end
    end
        
end