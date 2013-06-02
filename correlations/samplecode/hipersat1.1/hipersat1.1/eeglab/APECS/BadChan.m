function [badCh, goodCh, numGoodCh] = BadChan(i, badCh, badChProtocol, badChTol, goodCh, numGoodCh, ...
    VEOG, numVEOG, VEOGstr, HEOG, numHEOG, HEOGstr, numCh, msgStem);

global x logFile logFileIx;

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nRuntime Log: %s ---------------------------------------', msgStem{i});

% Determine 'dead' channels using current EEG data segment. -----------------------------------------------------------------

switch badChProtocol
    
    case 1
        
        numBadCh = length(badCh);
		
        goodCh{i} = setdiff(1:numCh, badCh);
        
        usrMsg = sprintf('\nNumber Of User-Specified Bad Channels: %d', numBadCh);
        
        if numBadCh
            usrMsg = strvcat(usrMsg, sprintf('\nBad Channel(s):\n'), sprintf('# %03d\t', badCh));
        end
        
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;
        
    case 2
        
        badCh = find(std(x, 1, 2) < badChTol);
		
        goodCh{i} = setdiff(1:numCh, badCh);
        
        numBadCh = length(badCh);
        
        usrMsg = sprintf('\nChannel Tolerance: %6.4f | Number Of Auto-Eliminated Low-Variance Channels: %d', ...
                 badChTol, numBadCh);
             
        if numBadCh
            usrMsg = strvcat(usrMsg, sprintf('\nLow-Variance Channel(s):\n'), sprintf('# %03d\t', badCh));
        end
        
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;
        
    case 3
        
        numBadCh1 = length(badCh);

        goodCh{i} = setdiff(1:numCh, badCh);
        
        goodCh{i}(find(std(x(goodCh{i}, :), 1, 2) < badChTol)) = [];
        
        badCh = setdiff(1:numCh, goodCh{i});
		
        numBadCh2 = length(badCh) - numBadCh1;
        
        usrMsg = strvcat(sprintf('\nNumber Of User-Specified Bad Channels: %d' , numBadCh1), ...
                         sprintf('\nChannel Tolerance: %6.4f | Number Of Auto-Eliminated Low-Variance Channels: %d', ...
                         badChTol, numBadCh2));
             
        if (numBadCh1 + numBadCh2)
            usrMsg = strvcat(usrMsg, sprintf('\nBad / Low-Variance Channel(s):\n'), sprintf('# %03d\t', badCh));
        end
        
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;
        
    case 4
        
        badCh = [];
		
        goodCh{i} = 1:numCh;
        
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = sprintf('\nNumber Of Bad / Low-Variance Channels Removed: 0');
        
end

numGoodCh(i) = length(goodCh{i});

% Verify that HEOG / VEOG  channels are not amongst 'dead' channels. --------------------------------------------------------

for j =  1 : numHEOG
    badHEOG(j) = any(badCh == HEOG(j));
end

for j =  1 : numVEOG
    badVEOG(j) = any(badCh == VEOG(j));
end

usrMsg = [];
switch any(badHEOG)
    case 0
        for j = 1:numHEOG
            usrMsg = [usrMsg sprintf('%s%03d\t', HEOGstr{j}, HEOG(j))];
        end
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = sprintf('\nGood HEOG Channels:\n\n%s', usrMsg);
    case 1
        for j = find(badHEOG)
            usrMsg = [usrMsg sprintf('%s%03d\t', HEOGstr{j}, HEOG(j))];
        end
        errMsg = sprintf('\n\nLow-Variance HEOG Channels:\n\n%s\n\n', usrMsg);
        error(errMsg);
end

usrMsg = [];
switch any(badVEOG)
    case 0
        for j = 1:numVEOG
            usrMsg = [usrMsg sprintf('%s%03d\t', VEOGstr{j}, VEOG(j))];
        end
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = sprintf('\nGood VEOG Channels:\n\n%s', usrMsg);
    case 1
        for j = find(badVEOG)
            usrMsg = [usrMsg sprintf('%s%03d\t', VEOGstr{j}, VEOG(j))];
        end
        errMsg = sprintf('\n\nLow-Variance VEOG Channels:\n\n%s\n\n', usrMsg);
        error(errMsg);
end
