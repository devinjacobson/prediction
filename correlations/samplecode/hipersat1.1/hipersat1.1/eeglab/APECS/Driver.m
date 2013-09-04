% ICA Blink Removal - Driver Program

clc; clear all;

global x s metaData logFile logFileIx;

% Fetch runtime parameters. -------------------------------------------------------------------------------------------------

[fileName, fileID, firstByte, precision, path, outputDir, bktFile, badChProtocol, badCh, badChTol, satObsProtocol, ...
    icaProtocol, sigClean, hipersatHome, hipersatExec, formExt, wgtExt, tau, blinkProtocol, fltrTol, ...
        numFltrTol, segment, numSeg, numIC, msgStem, stem, autoInput] = userInfo;

% Determine EEG Net Type and Segmentation. ----------------------------------------------------------------------------------

[segStrt, segStop, segSize, VEOG, numVEOG, VEOGstr, HEOG, numHEOG, HEOGstr, minAmp, maxAmp] = ...
    SegmentEeg(segment, numSeg, metaData.numCh, metaData.numSmpl);

LogFileOutput([fileName '_UI_Log'], char(logFile), 0);

% Open binary scratch files / initialize arrays. ----------------------------------------------------------------------------

goodCh      =  cell(numSeg, 1)                      ;
numGoodCh   =  zeros(numSeg, 1)                     ;

goodObs     =  cell(numSeg, 1)                      ;
numGoodObs  =  zeros(numSeg, 1)                     ;

meanProjVar =  cell(numSeg, 1)                      ;

kurt        =  zeros(metaData.numCh, numSeg)        ;
stdKurt     =  zeros(numSeg, 1)                     ;
meanKurt    =  zeros(numSeg, 1)                     ;

negent      =  zeros(metaData.numCh, numSeg)        ;
stdNegent   =  zeros(numSeg, 1)                     ;
meanNegent  =  zeros(numSeg, 1)                     ;

numBlinks   =  zeros(numSeg, numFltrTol)            ;

for i = 1 : numFltrTol

    sfID(i) = fopen([fileName stem{i}], 'w+')                               ;

    if (sfID(i) == -1)
        
        error(sprintf('\n\nError (File Open): %s\n\n', [fileName stem{i}])) ;
        
    end

end

sfID(numFltrTol + 1) = fopen([fileName '_MX'], 'w+')                        ;

if (sfID(numFltrTol + 1) == -1)
    
    error(sprintf('\n\nError (File Open): %s\n\n', [fileName '_MX']))       ;
    
end

sfID(numFltrTol + 2) = fopen([fileName '_IC'], 'w+')                        ;

if (sfID(numFltrTol + 2) == -1)
    
    error(sprintf('\n\nError (File Open): %s\n\n', [fileName '_IC']))       ;
    
end
    
% ICA decomposition protocol messages. --------------------------------------------------------------------------------------

switch icaProtocol
    
    case 1
        
	    FastICAForm;
        icaMsg = 'ICA Decomposition Protocol: FastICA (MATLAB) | '          ;
        
    case 2
        
	    RunICAForm;
        icaMsg = 'ICA Decomposition Protocol: Infomax (MATLAB) | '          ;
        
    case 3
        
        icaMsg = 'ICA Decomposition Protocol: HiPerSAT - FastICA (C++) | '  ;
        
    case 4
        
        icaMsg = 'ICA Decomposition Protocol: HiPerSAT - Infomax (C++) | '  ;
        
    case 5
        
        icaMsg = 'Orthogonal Decomposition Protocol: SOBI (MATLAB) | '      ;
        
end

for i = 1 : numSeg

    clc;
    logFile = {};
    logFileIx = 0;
    
    usrMsg = sprintf('\n%s%s\n', icaMsg , msgStem{i});
    
% Determine 'Dead' Channels and Saturated Observations. ---------------------------------------------------------------------

	readRawData(fileID, precision, 'real*8', segSize(i), i, numSeg, firstByte, 0, 0, 0);

	[badCh, goodCh, numGoodCh] = BadChan(i, badCh, badChProtocol, badChTol, goodCh, numGoodCh, ...
		VEOG, numVEOG, VEOGstr, HEOG, numHEOG, HEOGstr, metaData.numCh, msgStem);

	[badObs, goodObs, numGoodObs] = SatObs(i, goodObs, numGoodObs, HEOG, VEOG, minAmp, maxAmp, segSize);

    [meanEeg, Sph, goodCh, numGoodCh] = whiten(i, numIC, goodCh, numGoodCh, goodObs, numGoodObs);
    
	if (~autoInput)
	
		disp(char(logFile));
        disp( sprintf( '\n\n< Return > to continue or < Ctrl-C > to quit ...' ) ); pause;
		
		clc;
		disp(usrMsg);
		
	end
    
% Call ICA decomposition and vector filtering algorithm. --------------------------------------------------------------------

    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
    
    switch icaProtocol
        
        case 1
            
            W = fpica(x(goodCh{i}, goodObs{i}), Sph, approach, numGoodCh(i), g, finetune, a1, a2, ...
					mu, stabilization, epsilon, maxNumIterations, maxFinetune, initState, ...
                        seed, sampleSize, verbose, numGoodCh(i), numGoodObs(i));
                       
        case 2
            
            W = runica(x(goodCh{i}, goodObs{i}), 'extended', extended, 'lrate', lrate, ...
                    'weights', weights, 'maxsteps', maxsteps, 'stop', stop, 'verbose', verbose);
            
        case {3, 4}
            
			tempID = fopen([sigClean.scfPath sigClean.scfName], 'w', 'b');
            
			if (tempID == -1)
                
				error(sprintf('\n\nError (File Open): %s\n\n', [sigClean.scfPath sigClean.scfName]));
                
            else
                
				fwrite(tempID, x(goodCh{i}, goodObs{i}), 'real*8');
                
				fclose(tempID);
                
            end
            
            switch icaProtocol
                
                case 3
                    
                    switch sigClean.wgtMtrx
        
                        case 1
                            
                            tempID = fopen([sigClean.scfPath sigClean.wgtFileName], 'w');
            
                            if (tempID == -1)
                
                                error(sprintf('\n\nError (File Open): %s\n\n', [sigClean.scfPath sigClean.wgtFileName]));
                
                            else
                
                                fwrite(tempID, Sph, 'real*8');
                                
                                fclose(tempID);
                
                            end
                            
                        case 3
                            
                            tempID = fopen([sigClean.scfPath sigClean.wgtFileName], 'r+');
            
                            if (tempID == -1)
                
                                error(sprintf('\n\nError (File Open): %s\n\n', [sigClean.scfPath sigClean.wgtFileName]));
                
                            else
                
                                uWgt = fread(tempID, [metaData.numCh metaData.numCh], 'real*8');
                                
                                fseek(tempID, 0, 'bof');
                                
                                fwrite(tempID, Sph * uWgt(goodCh{i}, 1:numGoodCh(i)), 'real*8');
                                
                                fclose(tempID);
                                
                                clear uWgt;
                
                            end
                    end
                    
                case 4
                    
                    tempID = fopen([sigClean.scfPath sigClean.sphFileName], 'w');
            
                    if (tempID == -1)
                
                        error(sprintf('\n\nError (File Open): %s\n\n', [sigClean.scfPath sigClean.sphFileName]));
                
                    else
                
                        fwrite(tempID, Sph, 'real*8');
                        
                        fclose(tempID);
                
                    end
                    
            end
                        
            eval(['! ' hipersatExec ' ' sigClean.scfPath sigClean.scfName formExt ' ' sigClean.scfPath]);
			
            tempID = fopen([sigClean.scfPath sigClean.scfName wgtExt], 'r');
            
            if (tempID == -1)
                
                error(sprintf('\n\nError (File Open): %s\n\n', [sigClean.scfPath sigClean.scfName wgtExt]));
                
            else
                
                W = fread(tempID, [numGoodCh(i), numGoodCh(i)], 'real*8');
                
                fclose(tempID);
                
            end
			
		case {5}
			
			W = Sobi(x(goodCh{i}, goodObs{i}), tau);
            
    end
    
% Mixing matrix and components (Normalize for Infomax). ---------------------------------------------------------------------

    switch icaProtocol
        
        case {1, 3, 5}
            
            A = inv(W * Sph);
            s = W * (x(goodCh{i}, goodObs{i}));
    
        case {2, 4}
    
            A = inv(W * Sph) * diag(sqrt(diag(W*W')));
            s = inv(diag(sqrt(diag(W*W')))) * W * (x(goodCh{i}, goodObs{i}));
            
    end
    
% Component sorting. --------------------------------------------------------------------------------------------------------

    meanProjVar{i} = zeros(numGoodCh(i), 1);

    disp(sprintf('\nSorting components in descending mean projected variance ...'));

    for j = 1:numGoodCh(i)
                
        meanProjVar{i}(j) = mean(mean((A(:,j) * s(j,:)) .^ 2));
                
    end
            
    [meanProjVar{i}, sortVarIx] = sort(meanProjVar{i}, 'descend');
            
    s = s(sortVarIx, :); 
    A = A(:, sortVarIx);
    
% Negentropy stats. ---------------------------------------------------------------------------------------------------------

    disp(sprintf('\nEstimating non-gaussianity of components ...'));
    
    [kurt, meanKurt, stdKurt, negent, meanNegent, stdNegent] = EegStats(i, numGoodCh(i), numGoodObs(i), ...
        kurt, meanKurt, stdKurt, negent, meanNegent, stdNegent);
            
% Blink extraction. ---------------------------------------------------------------------------------------------------------

    disp(sprintf('\nSearching for blink components ...'));
    
    fwrite(sfID(numFltrTol + 1), A, precision);
    
    fwrite(sfID(numFltrTol + 2), s, precision);
    
    [goodCh, numGoodCh] = unWhiten(i, meanEeg, Sph, A, goodCh, numGoodCh, goodObs, numGoodObs, numIC);
    
    [numBlinks(i,:)] = blinkAway(sfID, fileID, precision, firstByte, goodCh{i}, badCh, goodObs{i}, badObs, ...
        satObsProtocol, blinkProtocol, bktFile, fltrTol, numFltrTol, segSize(i), i, numSeg, ...
            A, VEOG, numVEOG, HEOG, numHEOG, msgStem{i}, metaData.numCh);
        
    clc;
	LogFileOutput([fileName '_' int2str(i) '_RT_Log'], char(logFile), 1);
	
    if (~autoInput)
        
        disp( sprintf( '\n\n< Return > to continue or < Ctrl-C > to quit ...' ) ); pause;
        
    end

end

logFile = {};
logFileIx = 0;

% Load event data, if any. --------------------------------------------------------------------------------------------------

if metaData.numEvents
    
    for i = 1 : numSeg
        
        eventData{i} = readRawData(fileID, precision, 'uint8', segSize(i), i, numSeg, firstByte, (i == 1), 1, 0);
        
    end
    
else

    eventData = cell(numSeg, 1);
    
end

% Deleted bad observations? Recalculate segStrt, segStop and numSmpl. -------------------------------------------------------

if (satObsProtocol == 3)

    if metaData.numEvents
        
        for i = 1 : numSeg
            
            eventData{i}(:, setdiff(1:segSize(i), goodObs{i})) = [];
            
        end
        
    end

    segStrt = cumsum([1, numGoodObs(1 : numSeg - 1)]);
    segStop = cumsum(numGoodObs(1 : numSeg));
    segSize = numGoodObs;
    
    for i = 1 : numSeg
        
        goodObs{i} = 1 : segSize(i);
        
    end

    metaData.numSmpl = sum(numGoodObs);
    
end

% Read in mixing matrix A & IC from disk; write to .raw format. -------------------------------------------------------------

filStatus = fseek(sfID(numFltrTol + 1), 0, 'bof');
    
if filStatus
    
    error(sprintf('\n\nError (BOF Seek Failure): MX Data Array\n\n'));
    
end
    
filStatus = fseek(sfID(numFltrTol + 2), 0, 'bof');
    
if filStatus
    
    error(sprintf('\n\nError (BOF Seek Failure): IC Data Array\n\n'));
    
end
    
clc; disp(sprintf('\nWriting Output ---------------------------------------------'));

for i = 1 : numSeg

    A = zeros(metaData.numCh, numGoodCh(i));
    
    s = zeros(numGoodCh(i), segSize(i));
    
    A(goodCh{i}, :) = fread(sfID(numFltrTol + 1), [numGoodCh(i), numGoodCh(i)], precision);

    writeRaw([fileName '_' int2str(i) '_MX'], precision, A, [], numGoodCh(i), numGoodCh(i), 1, 0, 0);

    s(:, goodObs{i}) = fread(sfID(numFltrTol + 2), [numGoodCh(i), numGoodObs(i)], precision);
    
    writeRaw([fileName '_' int2str(i) '_IC'], precision, s, [], segSize(i), segSize(i), 1, 0, 0);

end
    
% Read in filtered EEG from disk; write to .raw format. ---------------------------------------------------------------------

for i = 1 : numFltrTol

    filStatus = fseek(sfID(i), 0, 'bof');

    if filStatus
        
        error(sprintf('\n\nError (BOF Seek Failure): FD Data Array\n\n'));
        
    end

    if all(numBlinks(:,i))

        for j = 1 : numSeg
            
            x = zeros(metaData.numCh, segSize(j));
            
            x(goodCh{j}, :) = fread(sfID(i), [numGoodCh(j), segSize(j)], precision);
            
            writeRaw([fileName stem{i} 'FD'], precision, x, eventData{j}, segSize(j), metaData.numSmpl, (j == 1), 1, 1);
            
        end


    else

        usrMsg = sprintf(['\nVector Filter Tolerance: %6.4f | EEG Data Not Filtered (Null Blink Activity)'], fltrTol(i));
                      
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;

    end

end

% Write event codes to .txt file; extract 'eyeb' flags. ---------------------------------------------------------------------

if metaData.numEvents
    
    eyeCode = writeEvents(fileName, [eventData{:}]);
    
else
    
    eyeCode = [];

end
 
LogFileOutput([fileName '_UO_Log'], char(logFile), 1);

% Display each segment's ICA decomposition quality statistics (kurtosis and negentropy). ------------------------------------
    
logFile = {};
logFileIx = 0;

for i = 1 : numSeg
    
    usrMsg = sprintf('\n\n---------- Kurtosis and Negentropy Statistics: Segment # %d of %d ----------', i, numSeg);
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
    
    usrMsg = sprintf('\nIC # %3d   |   Kurtosis = %8.6E   |   Negentropy = %8.6E', [goodCh{i}; kurt(1:numGoodCh(i), i)'; negent(1:numGoodCh(i), i)']);
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
    
    usrMsg = sprintf('\nKurtosis Mean = %8.6E   |   Negentropy Mean = %8.6E', meanKurt(i), meanNegent(i));
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
    
    usrMsg = sprintf('Kurtosis SDev = %8.6E   |   Negentropy SDev = %8.6E', stdKurt(i), stdNegent(i));
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
    
end

LogFileOutput([fileName '_KN_Log'], char(logFile), 1);

% Display Histogram and BERP GUIs. ------------------------------------------------------------------------------------------
    
if ~autoInput
    
    disp(sprintf('\nGenerating GUI(s) ...'));
    
    filStatus = fseek(sfID(numFltrTol + 2), 0, 'bof');
    
    if filStatus
        
        error(sprintf('\n\nError (BOF Seek Failure): IC Data Array\n\n'));
        
    end
        
    for i = 1 : numSeg
            
        x = zeros(metaData.numCh, segSize(i), 'single');
        
        s = zeros(numGoodCh(i), segSize(i), 'single');
        
        readRawData(fileID, precision, 'real*4', segSize(i), i, numSeg, firstByte, (i == 1), 0, 0);
        
        s(:, goodObs{i}) = fread(sfID(numFltrTol + 2), [numGoodCh(i), numGoodObs(i)], [precision '=>real*4']);
            
        whiten(i, numIC, goodCh, numGoodCh, goodObs, numGoodObs);
        
        ChannelHistogramsGUI('Name', sprintf('PDFs: %s (Segment # %d of %d)', fileName, i, numSeg), ...
            x(goodCh{i}, :), s, goodCh{i}, numGoodCh(i), segSize(i));
                
        if ~isempty(eyeCode)
            
            BlinkSplitGUI('Name', sprintf('BERPs: %s (Segment # %d of %d)', fileName, i, numSeg), ...
                s, numGoodCh(i), segSize(i), eyeCode, metaData.samplingRate, eventData{i});
                    
        end
        
    end
        
end
        
% Housekeeping. -------------------------------------------------------------------------------------------------------------

filStatus = fclose('all');

if (filStatus == -1)
    
    error(sprintf('\n\nError (File Close): File(s) Failed To Close\n\n'));
    
end

eval(['! rm ' fileName '_MX']);
eval(['! rm ' fileName '_IC']);

for i = 1 : numFltrTol
    
    eval(['! rm ' fileName stem{i}]);
    
end

switch icaProtocol
    
    case{3, 4}
        
        eval(['! rm -rf ' sigClean.scfPath]);
        
end

warning off all             ;
mkdir( path , outputDir )   ;
warning on all              ;

movefile( fullfile( path , [ fileName '_*'] ) , fullfile( path , outputDir ), 'f' );
