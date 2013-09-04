function [badObs, goodObs, numGoodObs] = SatObs(i, goodObs, numGoodObs, HEOG, VEOG, minAmp, maxAmp, segSize);

global x logFile logFileIx;

% Determine if any of the HEOG / VEOG channels have saturated observations. -------------------------------------------------

badObs = find((min(x([HEOG VEOG],:)) < minAmp) | (max(x([HEOG VEOG],:)) > maxAmp));

numBadObs = length(badObs);

goodObs{i} = setdiff(1:segSize(i), badObs);

numGoodObs(i) = length(goodObs{i});

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nNumber Of Saturated Observations: %d', numBadObs);

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n--------------------------------------------------------------------------------');
