function [numBlinks] = blinkAway(sfID, fileID, precision, firstByte, goodCh, badCh, goodObs, badObs, satObsProtocol, ...
                            blinkProtocol, bktFile, fltrTol, numFltrTol, segSize, segNum, numSeg, ...
							A, VEOG, numVEOG, HEOG, numHEOG, msgStem, numCh);

% Inputs:
%
%   x                 - m x n EEG data matrix: n time samples from m detectors.
%
%   A                 - Mixing matrix (numGoodCh by numGoodCh).
%
%   HEOG / VEOG       - (vector) of ocular channel markers.
%
%   sfID              - (scalar / vector) file id numbers for binary scratch files.
%
%   precision         - (string) is the precision of the EEG data.
%
%   goodCh            - (vector / cell array) of good channel indices / segment.
%
%   badCh             - (vector / cell array) of bad channel indices / segment.
%
%   goodObs           - (vector / cell array) of non-saturated observation indices / segment.
%
%   badObs            - (vector / cell array) of saturated observation indices / segment.
%
%   satObsProtocol    - (scalar) determines if saturated observations are used to
%                           construct the ICA activations and are kept in the filtered
%                           EEG data, or are not used to construct the ICA activations
%                           and are either set = 0 in the filtered EEG data or eliminated.
%
%   blinkProtocol     - (scalar) determines the protocol for finding blinks: Blink template
%                               match, VEOG polarity match or both.
%                          
%   fltrTol           - (scalar / vector) of tolerances for determining blink (vector filter) matches.
%
%   numFltrTol        - (scalar) number of tolerances stored in fltrTol.
%
%   segSize           - # of good observations in the current segment.
%
%   segNum            - Current segment #.
%
%   numSeg            - # of data segments.
%
%   segStart          - (scalar / vector) of indices to the first observation of each segment.
%
%   segStop           - (scalar / vector) of indices to the last observation of each segment.
%
%---------------------------------------------------------------------------------------------------------------------------
%
%         bktFile - (ASCII file) is the 'blinks' template that is read into the program.
%         It should reside in the same directory as this routine.  The template is a m by 1 
%         array of space seperated data for describing the blink (or whatever) events.
%
%---------------------------------------------------------------------------------------------------------------------------
%
% Outputs:
%
%    numBlinks        - (scalar / vector) number of blink activations per segment.
%
%----------------------------------------- Written to disk. ----------------------------------------------------------------
%
%    x                - (Global Variable) EEG data array, new & improved, with fewer blinks.
%
%---------------------------------------------------------------------------------------------------------------------------

global x s logFile logFileIx;

epsilon = 0.0001;

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\nBlinkAway Log: %s -------------------------------------', msgStem);

vctrFltr = load( bktFile , '-ascii' );
vctrFltr = reshape(vctrFltr, numCh, 1);

% 1) Left-concatenate the blink template (vctrFltr) to mixing matrix A.
% 2) Determine correlations between the blink template and the columns of A (Spatial Projectors / ICA weights).

corrs = corrcoef([vctrFltr(goodCh) A]);
corrVctr = abs(corrs(1, 2 : size(corrs, 2)));

% Recompute HEOG / VEOG pointers if bad channels were removed.

for i = 1 : numHEOG
    HEOG(i) = HEOG(i) - sum(badCh < HEOG(i));
end

for i = 1 : numVEOG
    VEOG(i) = VEOG(i) - sum(badCh < VEOG(i));
end

switch blinkProtocol

case 1  %-------------------------------------------------------------------------------------------------------------------

heogPntr = find(sign(A(HEOG(1),:)) == -1 * sign(A(HEOG(2),:)));
numHeogPntrs = length(heogPntr);

veogPntr = find((sign(A(VEOG(1),:)) == sign(A(VEOG(2),:))) & ...
                (sign(A(VEOG(3),:)) == sign(A(VEOG(4),:))) & ...
                (sign(A(VEOG(1),:)) == -1 * sign(A(VEOG(3),:))));
numVeogPntrs = length(veogPntr);
       
usrMsg = sprintf('\nHEOG Polarity Inversion | %d ICA Activation(s):', numHeogPntrs);
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
if ~isempty(heogPntr)
    usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [heogPntr; corrVctr(heogPntr)]);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n------------------------------------------------------------');

usrMsg = sprintf('\nVEOG Polarity Inversion | %d ICA Activation(s):', numVeogPntrs);
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
if ~isempty(veogPntr)
    usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [veogPntr; corrVctr(veogPntr)]);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n------------------------------------------------------------');

for i = 1 : numFltrTol
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = sprintf('\nBlink Template Threshold: %4.3f', fltrTol(i));

    % Find pointer to columns of A which meet template correlation threshold.

    blinks = find(corrVctr >= (fltrTol(i) - epsilon));
    numBlinks(i) = length(blinks);

    usrMsg = sprintf('\nBlink Activity: Blink Template Correlation | %d ICA Activation(s):', numBlinks(i));
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
        
    if ~isempty(blinks)  % Blink template correspondence.
       
        usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [blinks; corrVctr(blinks)]);
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;
        
        % Extract blinks from the EEG data.

        x(goodCh, goodObs) = x(goodCh, goodObs) - (A(:, blinks) * s(blinks, :));
                
        usrMsg = sprintf('\n*** %d ICA Activation(s) Subtracted From The EEG Data ***', numBlinks(i));
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;
        
        % Save array x to a binary file.

        switch satObsProtocol
            case 1  % Keep saturated observations.
                fwrite(sfID(i), x(goodCh, :), precision);
            case 2  % Zero - out saturated observations.
                x(goodCh, badObs) = 0;
                fwrite(sfID(i), x(goodCh, :), precision);
            case 3  % Delete saturated observations.
                fwrite(sfID(i), x(goodCh, goodObs), precision);
        end

    else  % No blink template correspondence.

        logFileIx = logFileIx + 1;
        logFile{logFileIx} = sprintf('\n*** No Blink Activity: 0 ICA Activations Subtracted From The EEG Data ***');
       
    end

    if (i < numFltrTol)
        rewindFastForward(fileID, precision, segSize, firstByte, 0, 0, 1);
        readRawData(fileID, precision, 'real*8', segSize, segNum, numSeg, firstByte, 0, 0, 0);
    end

end

case 2  %-------------------------------------------------------------------------------------------------------------------

heogPntr = find(sign(A(HEOG(1),:)) == -1 * sign(A(HEOG(2),:)));
numHeogPntrs = length(heogPntr);

veogPntr = find((sign(A(VEOG(1),:)) == sign(A(VEOG(2),:))) & ...
                (sign(A(VEOG(3),:)) == sign(A(VEOG(4),:))) & ...
                (sign(A(VEOG(1),:)) == -1 * sign(A(VEOG(3),:))));
numBlinks = length(veogPntr);
       
usrMsg = sprintf('\nHEOG Polarity Inversion | %d ICA Activation(s):', numHeogPntrs);
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
if ~isempty(heogPntr)
    usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [heogPntr; corrVctr(heogPntr)]);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n------------------------------------------------------------');

usrMsg = sprintf('\nVEOG Polarity Inversion | %d ICA Activation(s):', numBlinks);
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
if ~isempty(veogPntr)
    usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [veogPntr; corrVctr(veogPntr)]);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n------------------------------------------------------------');

usrMsg = sprintf('\nBlink Activity: VEOG Polarity Inversion | %d ICA Activation(s):', numBlinks);
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
    
if ~isempty(veogPntr)  % VEOG polarity match.
    
    usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [veogPntr; corrVctr(veogPntr)]);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;

    % Extract blinks from the EEG data.

    x(goodCh, goodObs) = x(goodCh, goodObs) - (A(:, veogPntr) * s(veogPntr, :));

    usrMsg = sprintf('\n*** %d ICA Activation(s) Subtracted From The EEG Data ***', numBlinks);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
        
    % Save array x to a binary file.

    switch satObsProtocol
        case 1  % Keep saturated observations.
            fwrite(sfID(1), x(goodCh, :), precision);
        case 2  % Zero - out saturated observations.
            x(goodCh, badObs) = 0;
            fwrite(sfID(1), x(goodCh, :), precision);
        case 3  % Delete saturated observations.
            fwrite(sfID(1), x(goodCh, goodObs), precision);
    end

else  % No VEOG polarity match.

    logFileIx = logFileIx + 1;
    logFile{logFileIx} = sprintf('\n*** No Blink Activity: 0 ICA Activations Subtracted From The EEG Data ***');

end

case 3  %-------------------------------------------------------------------------------------------------------------------

heogPntr = (sign(A(HEOG(1),:)) == -1 * sign(A(HEOG(2),:)));
numHeogPntrs = sum(heogPntr);

veogPntr = ((sign(A(VEOG(1),:)) == sign(A(VEOG(2),:))) & ...
            (sign(A(VEOG(3),:)) == sign(A(VEOG(4),:))) & ...
            (sign(A(VEOG(1),:)) == -1 * sign(A(VEOG(3),:))));
numVeogPntrs = sum(veogPntr);
       
usrMsg = sprintf('\nHEOG Polarity Inversion | %d ICA Activation(s):', numHeogPntrs);
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
if numHeogPntrs ~= 0
    usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [find(heogPntr); corrVctr(find(heogPntr))]);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n------------------------------------------------------------');

usrMsg = sprintf('\nVEOG Polarity Inversion | %d ICA Activation(s):', numVeogPntrs);
logFileIx = logFileIx + 1;
logFile{logFileIx} = usrMsg;
if numVeogPntrs ~= 0
    usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [find(veogPntr); corrVctr(find(veogPntr))]);
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
end

logFileIx = logFileIx + 1;
logFile{logFileIx} = sprintf('\n------------------------------------------------------------');

for i = 1 : numFltrTol
    
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = sprintf('\nBlink Template Threshold: %4.3f', fltrTol(i));
 
    % Find pointer to columns of A which meet template correlation threshold + VEOG polarity constraint.

    blinks = find(veogPntr & (corrVctr >= (fltrTol(i) - epsilon)));
    numBlinks(i) = length(blinks);
    
    usrMsg = sprintf('\nBlink Activity: Blink Template Correlation + VEOG Polarity Inversion | %d ICA Activation(s):', numBlinks(i));
    logFileIx = logFileIx + 1;
    logFile{logFileIx} = usrMsg;
        
    if ~isempty(blinks)  % Blink template correspondence.
       
        usrMsg = sprintf('\n%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)\t%04d (%4.3f)', [blinks; corrVctr(blinks)]);
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;
        
        % Extract blinks from the EEG data.

        x(goodCh, goodObs) = x(goodCh, goodObs) - (A(:, blinks) * s(blinks, :));
                
        usrMsg = sprintf('\n*** %d ICA Activation(s) Subtracted From The EEG Data ***', numBlinks(i));
        logFileIx = logFileIx + 1;
        logFile{logFileIx} = usrMsg;
        
        % Save array x to a binary file.

        switch satObsProtocol
            case 1  % Keep saturated observations.
                fwrite(sfID(i), x(goodCh, :), precision);
            case 2  % Zero - out saturated observations.
                x(goodCh, badObs) = 0;
                fwrite(sfID(i), x(goodCh, :), precision);
            case 3  % Delete saturated observations.
                fwrite(sfID(i), x(goodCh, goodObs), precision);
        end

    else  % No blink template correspondence.

        logFileIx = logFileIx + 1;
        logFile{logFileIx} = sprintf('\n*** No Blink Activity: 0 ICA Activations Subtracted From The EEG Data ***');
       
    end

    if (i < numFltrTol)
        rewindFastForward(fileID, precision, segSize, firstByte, 0, 0, 1);
        readRawData(fileID, precision, 'real*8', segSize, segNum, numSeg, firstByte, 0, 0, 0);
    end
   
end

end
