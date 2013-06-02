function [fileName, fileID, firstByte, precision, path, outputDir, bktFile, badChProtocol, badCh, badChTol, ...
          satObsProtocol, icaProtocol, sigClean, hipersatHome, hipersatExec, formExt, wgtExt, tau, blinkProtocol, ...
            fltrTol, numFltrTol, segment, numSeg, numIC, msgStem, stem, autoInput] = userInfo;

global metaData logFile logFileIx;

% Initialization ------------------------------------------------------------------------------------------------------

tau   = []          ;
numIC = []          ;
sigClean = []       ;

epsilon  = 0.0001   ;

shSetup = ''        ;
hipersatExec = ''   ;
hipersatHome = ''   ;
        
execDir  = 'bin'            ;
        
formExt  = '.form'          ;
        
execName = 'hipersat'       ;
    
wgtExt   = '_binary.wgt'    ;

dataName = 'HiPerSAT.scf'   ;
        
workSpace = [filesep 'tmp' filesep 'HiPerSatData' filesep];

% 	Figure out whether user is bash / tcsh and which env file to execute. ---------------------------------------------
%	Code determines (indirectly) value of environment symbol <HIPERSAT_HOME>. -----------------------------------------

fprintf( 'Determining HiPerSAT configuration ...\n' );

if ( isempty( strfind( [ getenv( 'SHELL' ) '-x-x-x' ], 'bash-x-x-x' )  ) )
    
    shell = 'tcsh';
    
else
    
	shell = 'bash';
    
end

shSetupFile = [ getenv( 'HOME' ) '/HiPerSAT/MATLAB_' shell 'env.sh' ];

fid = fopen( shSetupFile, 'r' );

if ( fid ~= -1 )
    
	fclose( fid );

	shSetup = [ 'source ' shSetupFile ' && ' ];

	eval( [ '!' shSetup ' echo $HIPERSAT_HOME>/tmp/hipersat.tmp' ] );

	fid = fopen( '/tmp/hipersat.tmp', 'r' );

	if ( fid ~= -1 )
	    
		hipersatHome = fscanf( fid, '%s' );
	    
		fclose(fid);
        
	end

	delete /tmp/hipersat.tmp;

	if ( length( hipersatHome ) > 0 )
        
		hipersatExec = [ shSetup fullfile( hipersatHome, execDir, execName ) ];
        
    end
    
end

fprintf( '\n\nSHELL: %s\nHIPERSAT_HOME: %s\nHIPERSAT_EXEC: %s\n\n', shell, hipersatHome, hipersatExec );

% Auto Mode -----------------------------------------------------------------------------------------------------------

if (exist('AutoDriver.m', 'file') == 2)

    AutoDriver;

    autoInput = 1;

    % Call readRawHeader ----------------------------------------------------------------------------------------------

    [fileID, firstByte, precision] = readRawHeader(fileName);
	
    LogFileOutput([fileName '_MD_Log'], char(logFile), 0);

    logFile   = {};
    logFileIx =  0;
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = sprintf('\nUserInfo Log: See AutoDriver.m For User Settings -------------------------------');

    % Segmentation ----------------------------------------------------------------------------------------------------

    if (segment =='y') || (segment == 'Y')

        segment = 1;

        for i = 1 : numSeg
            
            msgStem{i} = sprintf('EEG Data Segment # %02d of %02d', i, numSeg);
            
        end

    else

        segment = 0;
        numSeg  = 1;
        
        msgStem{1} = 'EEG Data Segment # 01 of 01';

    end

    % ICA Protocol ----------------------------------------------------------------------------------------------------

    switch icaProtocol
        
        case {3, 4}
    
            switch icaProtocol
            
                case 3
                
                    icatype = 'nic-fastica';
                
                case 4
                
                    icatype = 'nic-infomax';
                
            end
		
            warning off all  ;
                         
            mkdir(workSpace) ;
        
            warning on all   ;
            
            [sigClean] = IcaGuiApecs(workSpace, dataName, formExt, icatype, metaData.numCh, metaData.numSmpl, autoInput);
		
            if isempty(sigClean)
                        
                error(sprintf('\n\nError (File Read): Invalid HiPerSAT Form (%s)\n\n', formExt));
			                     
            end
        
    end

    % Blink Protocol --------------------------------------------------------------------------------------------------

    switch blinkProtocol
    
        case{1, 3}

            if (fltrProtocol == 2)
			
                numFltrInc  =  round((fltrTolMax - fltrTolMin) / fltrTolInc);
                fltrTolInc  =  (fltrTolMax - fltrTolMin) / numFltrInc;
                fltrTol     =  fltrTolInc * [0 : numFltrInc] + fltrTolMin;
				
            end

            numFltrTol = length(fltrTol);

            for i = 1 : numFltrTol
			
                stem{i} = ['_T' num2str(fltrTol(i), '%4.3f')];
				
            end

        case 2

            fltrTol = 0;
            numFltrTol = 1;
            stem{1} = '_VEOG';

    end

% APECS Path, Output Directory & Blink Template -----------------------------------------------------------------------

    path = fileparts( which( 'APECS/Driver.m' ) );
    
    bktFile = fullfile( path , [ fileName '.bkt' ] );
        
    outputDir = [ fileName '-' int2str( length( dir( fullfile( path , [ fileName '-*' ] ) ) ) + 1 ) ];

    return;

else

    autoInput = 0;

end

% Blink Away Intro ----------------------------------------------------------------------------------------------------

errFlag1 = 1;
errFlag2 = 1;

while errFlag1

    disp(sprintf(['\nWelcome.  APECS, an EEG blink-removal program, will perform the following actions:\n' ...
                  '\n1) Read EEG data from a ''.raw'' formatted file\n' ...
                  '\n2) Remove bad channels / saturated observations\n' ...
                  '\n3) Perform an ICA decomposition of the EEG data\n' ...
                  '\n4) Extract blink activity via Blink Template Correlation / VEOG Polarity Inversion \n' ...
                  '\n5) Write the blink-free EEG to a ''.raw'' formatted file']));
        
    while errFlag2

        fileName = input('\nEnter the ''.raw'' formatted file name: ', 's');

        if isempty(fileName)
            
            disp(sprintf('\n\nError (File Name): Improper File Name Syntax\n'));
	
        else
            
            errFlag2 = 0;
            
            if ~isempty(regexp(fileName, '.+(?=\.raw)', 'match'))
        
                fileName = char(regexp(fileName, '.+(?=\.raw)', 'match'));
                
            end
            
        
        end
    
    end

    % Call readRawHeader ----------------------------------------------------------------------------------------------

    [fileID, firstByte, precision] = readRawHeader(fileName);
	
    LogFileOutput([fileName '_MD_Log'], char(logFile), 1);

    errFlag1 = input('\n\nProceed (P), Re-enter (R) or Quit (Q): ', 's');
            
    switch errFlag1
                
        case {'P' , 'p'}
                    
            clc;
            errFlag1 = 0;
                    
        case{'R' , 'r'}
                    
            clc;
            errFlag1 = 1;
            errFlag2 = 1;
            fclose(fileID);
                    
        case{'Q' , 'q'}
                    
            error(sprintf('\n\nError (User Selection): User Cancelled Program Execution\n\n'));
            
        otherwise
            
            clc;
            errFlag1 = 0;
              
    end
    
end

% APECS Path, Output Directory & Blink Template -----------------------------------------------------------------------

path = fileparts( which( 'APECS/Driver.m' ) );

bktFile = fullfile( path , [ fileName '.bkt' ] );
        
outputDir = [ fileName '-' int2str( length( dir( fullfile( path , [ fileName '-*' ] ) ) ) + 1 ) ];

logFile = {};
logFileIx = 0;

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nUserInfo Log -------------------------------------------------------------------');

% Segmentation Protocol -----------------------------------------------------------------------------------------------

errFlag1 = 1;
errFlag2 = 1;

while errFlag1

    disp(sprintf(['\n------------ Segmentation Protocol ------------\n' ...
                  '\nThe input EEG can be ICA processed in 2 or more equal segments' ...
                  '\nif the data''s original size exceeds MATLAB''s memory capacity.']));
    
    segment = input('\nSegment the EEG data (Y/N)? ', 's');
    
    if isempty(segment)
        
        segment = 'N';
        
    end

    switch segment
        
        case {'Y' , 'y'}
    
            segment = 1;
    
            while errFlag2
        
                numSeg = input('\nEnter number of segments (+''ve integer >= 2): ');
                
                if isempty(numSeg)
                    
                    numSeg = 2;
                    
                end

                if (round(numSeg) == numSeg) && (numSeg >= 2)
            
                    errFlag2 = 0;

                    usrMsg = sprintf('\nNumber Of EEG Data Segments: %d', numSeg);
            
                    disp(usrMsg);
            
                    for i = 1 : numSeg
                
                        msgStem{i} = sprintf('EEG Data Segment # %02d of %02d', i, numSeg);
                
                    end

                else

                    disp(sprintf('\n\nError (# Of Segments): # Of Segments Must Be A Positive Integer >= 2\n'));

                end
        
            end

        otherwise

            segment = 0;
            numSeg = 1;

            usrMsg = sprintf('\nEEG Data Will Not Be Segmented');
    
            disp(usrMsg);
    
            msgStem{1} = 'EEG Data Segment # 01 of 01';

    end

    errFlag1 = input('\n\nProceed (P), Re-enter (R) or Quit (Q): ', 's');
            
    switch errFlag1
                
        case {'P' , 'p'}
                    
            clc;
            errFlag1 = 0;
                    
        case{'R' , 'r'}
                    
            clc;
            errFlag1 = 1;
            errFlag2 = 1;
                    
        case{'Q' , 'q'}
                    
            error(sprintf('\n\nError (User Selection): User Cancelled Program Execution\n\n'));
            
        otherwise
            
            clc;
            errFlag1 = 0;
                    
    end
    
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;

% Bad Channel Protocol ------------------------------------------------------------------------------------------------

errFlag1 = 1;
errFlag2 = 1;

while errFlag1

    disp(sprintf(['\n------------ Bad / Low-Variance Channel Protocol ------------\n' ...
                  '\n1) Eliminate user-specified bad channels' ...
                  '\n2) Eliminate low-variance channels: |Channel Variance| < Low-Variance Threshold' ...
                  '\n3) Eliminate user-specified bad channels + Eliminate remaining low-variance channels' ...
                  '\n4) No bad / low-variance channels']));
    
    while errFlag2

        badChProtocol = input('\nPlease select the Bad / Low-Variance Channel Protocol: ');
        
        if isempty(badChProtocol)
            
            badChProtocol = 4;
            
        end

        switch badChProtocol

            case {1, 2, 3, 4}
            
                errFlag2 = 0;

                disp(sprintf('\nBad / Low-Variance Channel Protocol: %d', badChProtocol));
                
            otherwise

                disp(sprintf('\n\nError (Bad / Low-Variance Channel Protocol): Select Appropriate Protocol\n'));

        end
    
    end

    switch badChProtocol

        case 1

            badChTol = 0;
            badCh    = input('\n\nEnter vector of bad channel markers ([Channel# Channel# Channel# ...]): ');
		
            usrMsg   = strvcat(sprintf('\nUser-Specified Bad Channel(s):\n'), sprintf('# %03d\t', badCh));
		
            disp(usrMsg);
            
        case 2

            badCh    = [];
            badChTol = abs(input('\n\nEnter threshold level for low-variance channel auto-detection (microvolts): '));
		
            usrMsg   = sprintf('\nLow-Variance Channel Auto-Detection Threshold (microvolts): %6.4f', badChTol);
		
            disp(usrMsg);

        case 3

            badCh    = input('\n\nEnter vector of bad channel markers ([Channel# Channel# Channel# ...]): ');
            badChTol = abs(input('\nEnter threshold level for low-variance channel auto-detection (microvolts): '));
		
            usrMsg   = strvcat(sprintf('\nLow-Variance Channel Auto-Detection Threshold (microvolts): %6.4f', badChTol), ...
                               sprintf('\nUser-Specified Bad Channel(s):\n'), sprintf('# %03d\t', badCh));
						 
            disp(usrMsg);
            
        case 4
            
            badCh    = [];
            badChTol = 0;
        
            usrMsg   = sprintf('\nUser Specified Bad / Low-Variance Channels: N/A');
        
            disp(usrMsg);
    end
    
    errFlag1 = input('\n\nProceed (P), Re-enter (R) or Quit (Q): ', 's');
            
    switch errFlag1
                
        case {'P' , 'p'}
                    
            clc;
            errFlag1 = 0;

        case{'R' , 'r'}
                    
            clc;
            errFlag1 = 1;
            errFlag2 = 1;
                    
        case{'Q' , 'q'}
                    
            error(sprintf('\n\nError (User Selection): User Cancelled Program Execution\n\n'));
            
        otherwise

            clc;
            errFlag1 = 0;
                    
    end
    
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
    
% Saturated Observations Protocol -------------------------------------------------------------------------------------

errFlag1 = 1;
errFlag2 = 1;

while errFlag1

    disp(sprintf(['\n------------ Saturated Observations Protocol ------------\n' ...
                  '\nThe ICA decomposition will be performed WITHOUT using either the bad channels or' ...
                  '\nthe saturated observations, and the user-specified / auto-eliminated bad channels' ...
                  '\nwill be zeroed out in the filtered EEG data.\n' ...
                  '\nRegarding saturated observations, select one of the following:\n' ...
                  '\n1) Re-insert the saturated observations into the filtered data' ...
                  '\n2) Replace the saturated observations with zeros in the filtered data' ...
                  '\n3) Remove all saturated observations + corresponding event markers from the filtered data']));
    
    while errFlag2

        satObsProtocol = input('\nPlease select the Saturated Observations Protocol: ');
        
        if isempty(satObsProtocol)
            
            satObsProtocol = 3;
            
        end

        switch satObsProtocol

            case {1, 2, 3}
            
                errFlag2 = 0;

                usrMsg = sprintf('\nSaturated Observations Protocol: %d', satObsProtocol);
                
                disp(usrMsg);
		
            otherwise

                disp(sprintf('\n\nError (Saturated Observations Protocol): Select Appropriate Protocol\n'));

        end
    
    end

    errFlag1 = input('\n\nProceed (P), Re-enter (R) or Quit (Q): ', 's');
            
    switch errFlag1
                
        case {'P' , 'p'}
                    
            clc;
            errFlag1 = 0;

        case{'R' , 'r'}
                    
            clc;
            errFlag1 = 1;
            errFlag2 = 1;
                    
        case{'Q' , 'q'}
                    
            error(sprintf('\n\nError (User Selection): User Cancelled Program Execution\n\n'));
            
        otherwise

            clc;
            errFlag1 = 0;
                    
    end
    
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;

% ICA Decomposition Protocol ------------------------------------------------------------------------------------------

errFlag1 = 1;
errFlag2 = 1;

while errFlag1

    disp(sprintf(['\n------------ ICA Decomposition Protocol ------------\n' ...
                  '\n1) FastICA (MATLAB)'                                    ...
                  '\n2) Infomax (MATLAB)']                                   ));
                
    if isempty(hipersatExec)
     
        disp(sprintf('\n----- Install HiPerSAT To Activate 3 & 4 -----\n'));
                
    end
     
    disp(sprintf(['3) HiPerSAT - FastICA (C++)\n'                            ...
                  '4) HiPerSAT - Infomax (C++)\n'                            ...
                  '5) SOBI (MATLAB)\n\n'                                     ...
                  '------------------------------------------']              ));
        
    while errFlag2

        icaProtocol = input('\nPlease select the ICA Decomposition Protocol: ');
        
        if isempty(icaProtocol)
            
            icaProtocol = 2;
            
        end
    
        if isempty(hipersatExec)
        
            if icaProtocol == 3 || icaProtocol == 4
            
                icaProtocol = 0;
            
            end
        
        end

        switch icaProtocol

            case {1, 2, 3, 4, 5}

                errFlag2 = 0;
                
                usrMsg = sprintf('\nICA Decomposition Protocol: %d', icaProtocol);
                
                disp(usrMsg);
            
            otherwise

                disp(sprintf('\n\nError (ICA Decomposition Protocol): Select Appropriate Protocol\n'));
            
        end

    end

    switch icaProtocol
        
        case {3, 4}

            warning off all  ;
                     
            mkdir(workSpace) ;
        
            warning on all   ;
            
            switch icaProtocol
            
                case 3
                
                    icatype = 'nic-fastica';
                
                case 4
                
                    icatype = 'nic-infomax';
                
            end
            
            [sigClean] = IcaGuiApecs(workSpace, dataName, formExt, icatype, metaData.numCh, metaData.numSmpl, autoInput);
		
            if isempty(sigClean)
                    
                icaProtocol = 2;
                    
                disp(sprintf('\nWarning (HiPerSAT): Cancelling HiPerSAT Invocation'));
                    
                usrMsg = sprintf('\nICA Decomposition Protocol: %d', icaProtocol);
                
                disp(usrMsg);
                        
            else
                
                if (sigClean.icaProtocol + 2 ~= icaProtocol)
                        
                    icaProtocol = sigClean.icaProtocol + 2;
                        
                    usrMsg = sprintf('\nICA Decomposition Protocol: %d', icaProtocol);
                
                    disp(usrMsg);
                        
                end
            
                disp(sprintf('\n\nHiPerSAT Structure Info:\n\n----------------------------------------------------\n'));
                    
                disp(sigClean);
                    
                disp('----------------------------------------------------');
                    
            end
                
        case 5
        
            logFileIx = logFileIx + 1;
            logFile{logFileIx} = usrMsg;
            
            errFlag2 = 1;
        
            while errFlag2
        
                tau = input('\n\nEnter vector of time delays ([Delay #1 ... Delay #N] or < Return > for default): ');
        
                if isempty(tau)
                
                    errFlag2 = 0;
            
                    usrMsg = sprintf('\nUsing default SOBI time-delay vector');
                
                    disp(usrMsg);
            
                else
            
                    if isnumeric(tau)
                    
                        errFlag2 = 0;
                
                        tau = sort(abs(tau));
                    
                        usrMsg = sprintf('\nUsing user-specified SOBI time-delay vector');
                    
                        disp(usrMsg);

                    else
                
                        disp(sprintf('\n\nError (SOBI Protocol): Non-numeric Time Delay(s)\n'));
                
                    end
            
                end
            
            end
            
    end
            
    errFlag1 = input('\n\nProceed (P), Re-enter (R) or Quit (Q): ', 's');
            
    switch errFlag1
                
        case {'P' , 'p'}
                    
            clc;
            errFlag1 = 0;

        case{'R' , 'r'}
            
            clc;        
            errFlag1 = 1;
            errFlag2 = 1;
                    
        case{'Q' , 'q'}
                    
            error(sprintf('\n\nError (User Selection): User Cancelled Program Execution\n\n'));
            
        otherwise
            
            clc;
            errFlag1 = 0;
                    
    end
            
end
        
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
        
% Blink Activity Protocol ---------------------------------------------------------------------------------------------

errFlag1 = 1;
errFlag2 = 1;

while errFlag1

    disp(sprintf(['\n------------ Blink Activity Protocol ------------\n'       ...
                  '\nBlink activity at the EEG detectors is determined by:\n'   ...
                  '\n1) Blink Template Correlation'                             ...
                  '\n2) VEOG Polarity Inversion'                                ...
                  '\n3) Blink Template Correlation + VEOG Polarity Inversion']));
    
    while errFlag2

        blinkProtocol = input('\nPlease select the Blink Activity Protocol: ');
        
        if isempty(blinkProtocol)
            
            blinkProtocol = 3;
            
        end

        switch blinkProtocol

            case {1, 2, 3}
            
                errFlag2 = 0;

                disp(sprintf('\nBlink Activity Protocol: %d', blinkProtocol));
                
            otherwise

                disp(sprintf('\n\nError (Blink Activity Protocol): Select Appropriate Protocol\n'));

        end
    
    end
    
    % Blink Template Threshold Protocol -------------------------------------------------------------------------------
    
    switch blinkProtocol
    
        case{1, 3}
        
            disp(sprintf(['\n------- Blink Template Threshold Protocol -------\n'   ...
                          '\n1) Specify a single blink template threshold'          ...
                          '\n2) Specify a range of blink template thresholds']));
        
            errFlag2 = 1;

            while errFlag2
        
                fltrProtocol = input('\nPlease select the Blink Template Threshold Protocol: ');
                
                if isempty(fltrProtocol)
                    
                    fltrProtocol = 1;
                    
                end
            
                switch fltrProtocol
            
                    case {1, 2}
                    
                        errFlag2 = 0;
                        
                        disp(sprintf('\nBlink Template Threshold Protocol: %d', fltrProtocol));
                        
                    otherwise
                        
                        disp(sprintf('\n\nError (Blink Template Threshold Protocol): Select Appropriate Protocol\n'));
                
                end
                
            end
            
            switch fltrProtocol
            
                case 1
                
                    errFlag2 = 1;

                    while errFlag2
                
                        fltrTol = abs(input('\nEnter blink template threshold: '));
                        
                        if isempty(fltrTol)
                            
                            fltrTol = 0.95;
                            
                        end
                    
                        if (fltrTol < 0 || fltrTol > 1)
                        
                            disp(sprintf('\n\nError (Blink Template Threshold): 0 <= Blink Template Threshold <= 1\n'));
                        
                        else
                        
                            errFlag2 = 0;
                        
                        end
                    
                    end
				
                    usrMsg = sprintf('\nBlink Template Threshold: %4.3f', fltrTol);
                    
                    disp(usrMsg);
				
                case 2
                
                    errFlag2 = 1;
                
                    while errFlag2
                
                        fltrTolMin = abs(input('\nEnter minimum blink template threshold: '));
                        
                        if isempty(fltrTolMin)
                            
                            fltrTolMin = 0.85;
                            
                        end
                
                        if (fltrTolMin < 0 || fltrTolMin >= 1)
                        
                            disp(sprintf('\n\nError (Blink Template Threshold): 0 <= Min Blink Template Threshold < Max Blink Template Threshold <= 1\n'));
                        
                        else
                        
                            errFlag2 = 0;
                    
                        end
                    
                    end
                
                    disp(sprintf('\nMinimum Blink Template Threshold: %4.3f',   fltrTolMin));
                            
                    errFlag2 = 1;

                    while errFlag2
                
                        fltrTolMax = abs(input('\nEnter maximum blink template threshold: '));
                        
                        if isempty(fltrTolMax)
                            
                            fltrTolMax = 1.00;
                            
                        end

                        if (fltrTolMax <= fltrTolMin || fltrTolMax > 1)
                    
                            disp(sprintf('\n\nError (Blink Template Threshold): 0 <= Min Blink Template Threshold < Max Blink Template Threshold <= 1\n'));
                        
                        else
                        
                            errFlag2 = 0;
                    
                        end
                    
                    end
                
                    disp(sprintf('\nMaximum Blink Template Threshold: %4.3f',   fltrTolMax));
                            
                    errFlag2 = 1;

                    while errFlag2
                
                        fltrTolInc = abs(input('\nEnter threshold increment: '));
                        
                        if isempty(fltrTolInc)
                            
                            fltrTolInc = 0.05;
                            
                        end
                    
                        if (fltrTolInc == 0 || fltrTolInc > (fltrTolMax - fltrTolMin + epsilon))
                    
                            disp(sprintf('\n\nError (Threshold Increment): Enter A Smaller, +''ve Increment\n'));
                    
                        else
                    
                            errFlag2 = 0;
                    
                        end
                    
                    end
                    
                    disp(sprintf('\nBlink Template Threshold Increment: %4.3f', fltrTolInc));
                            
                    numFltrInc = round((fltrTolMax - fltrTolMin) / fltrTolInc);
                    fltrTolInc = (fltrTolMax - fltrTolMin) / numFltrInc;
                    fltrTol = fltrTolInc * [0 : numFltrInc] + fltrTolMin;
				
                    usrMsg = strvcat( sprintf('\nMinimum Blink Template Threshold: %4.3f',   fltrTolMin), ...
                                      sprintf('\nMaximum Blink Template Threshold: %4.3f',   fltrTolMax), ...
                                      sprintf('\nBlink Template Threshold Increment: %4.3f', fltrTolInc) );

            end

            numFltrTol = length(fltrTol);

            for i = 1 : numFltrTol
            
                stem{i} = ['_T' num2str(fltrTol(i), '%4.3f')];
            
            end
        
            if ~exist( bktFile , 'file' )
            
                errFlag2 = 1;
                
                disp( sprintf( '\n\nWarning (File Missing): %s' , bktFile ) );
                disp( sprintf( '\n!!! Provide missing file prior to continuing or terminate execution !!!' ) );
                disp( sprintf( '\n< Return > to continue or < Ctrl-C > to quit ...' ) ); pause;
            
            else
            
                errFlag2 = 0;
            
            end
        

            if errFlag2 == 1
            
                if ~exist( bktFile , 'file' )
            
                    error( sprintf( '\n\nError (File Missing): %s\n\n' , bktFile ) );
                
                else
                
                    disp( sprintf( '\n\nNotice (File Detected): %s' , bktFile ) );
                
                end
            
            end
        
    case 2
        
        fltrTol = 0;
        numFltrTol = 1;
        stem{1} = '_VEOG';
        
        usrMsg = sprintf('\nBlink Template Threshold: N/A (VEOG Polarity Inversion Only)');
        
        disp(usrMsg);
        
    end
        
    errFlag1 = input('\n\nProceed (P), Re-enter (R) or Quit (Q): ', 's');
            
    switch errFlag1
                
    case {'P' , 'p'}
                    
        clc;
        errFlag1 = 0;

    case{'R' , 'r'}
                    
        clc;
        errFlag1 = 1;
        errFlag2 = 1;
                    
    case{'Q' , 'q'}
                    
        error(sprintf('\n\nError (User Selection): User Cancelled Program Execution\n\n'));
            
    otherwise
                
        clc;
        errFlag1 = 0;
                
    end
                    
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
