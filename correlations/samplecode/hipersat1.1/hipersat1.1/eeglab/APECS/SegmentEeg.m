function [segStrt, segStop, segSize, VEOG, numVEOG, VEOGstr, HEOG, numHEOG, HEOGstr, minAmp, maxAmp] = SegmentEeg(segment, numSeg, numCh, numSmpl);

global logFile logFileIx;

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n--------------------------------------------------------------------------------');

% Determine the type of recording hardware. --------------------------------------------------------------------------------

[EEG, VEOG, numVEOG, VEOGstr, HEOG, numHEOG, HEOGstr, minAmp, maxAmp] = EegNetType(numCh);

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nRecording Hardware: %s', EEG);

% Compute the size of each segment. ----------------------------------------------------------------------------------------

if segment
    
    segSize = floor(numSmpl / numSeg);
    lastSegSize = segSize + mod(numSmpl, numSeg);

    segStrt = [1, 1 + segSize * [1 : (numSeg - 1)]];
    segStop = [segSize * [1 : (numSeg - 1)], numSmpl];
    
    segSize = [segSize * ones(1, numSeg - 1), lastSegSize];
    
else
    
    segStrt = 1;
    segStop = numSmpl;
    segSize = numSmpl;
    
end
