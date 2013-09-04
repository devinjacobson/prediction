function IcaTest(runName, freqIC, secOfData);

close all; clc;

if nargin == 0
    runName = input('Enter a run series name: ', 's');
end

% ------------------------------Constants---------------------------------

ica                     =  'FastICA';           % ICA Algorithm: 'FastICA', 'InfoMax'
preWhiten               =  1;                   % User Whitens = 1; FastICA Whitens = 0;
randomMixMatrx          =  1;                   % Generate Random Mixing Matrix: 1 = Yes, 0 = No

sampFreq                =  250;                 % Sampling Frequency (Hz)

if nargin < 2
    
    freqIC              =  [4; 8; 16; 25];      % Frequency (Hz) Of IC
    secOfData           =  4;                   % # Of Seconds Of Data Collected
    
end

% ****** FastICA Parameters Only ******

epsilon     =  0.0001;  % FastICA Convergence Tolerance
randomSeed  =  1;       % FastICA Starting Seed: Random = 1, Identity Matrix = 0
icaMethod   =  'tanh';  % FastICA Contrast Function: Cubic = 'pow3', Hyperbolic Tangent = 'tanh', Guassian = 'gauss'

% *************************************

%-------------------------------------------------------------------------

twoPi = 2 * pi;
numIC = length(freqIC);
sampInterval = 1 / sampFreq;
n = 0 : sampInterval : secOfData;

% Generate IC: -----------------------------------------------------------

s = sin((twoPi .* freqIC) * n );

% Generate Mixing Matrix A: ----------------------------------------------

if randomMixMatrx
    A = randn(numIC);
else
    load mixMatrix.mat
end

% Generate Mixed Signals ------------------------------------------------

x = A * s;

% ICA: -------------------------------------------------------------------

switch ica
    case 'FastICA'
        
        if randomSeed
            
            mySeed = rand(numIC) - 0.5;
            
        else
            
            mySeed = eye(numIC);
            
        end
        
        if preWhiten
            
            [V D] = eig(cov(x'));
            Sph_fica = diag(diag(D) .^ -0.5) * V';
            x_w = Sph_fica * x;
            
            [s_fICA, A_fICA, W_fICA] = fastica( x, ...
                                                'initGuess', mySeed, ...
                                                 'whiteSig', x_w, ...
                                                 'whiteMat', Sph_fica, ...
                                                 'dewhiteMat', inv(Sph_fica), ...
                                                 'displayMode', 'off', ...
                                                 'g', icaMethod, ...
                                                 'epsilon', epsilon);
                                             
                                             
        else
            
            Sph_fica = [];
            
            [s_fICA, A_fICA, W_fICA] = fastica( x, ...
                                                'initGuess', mySeed, ...
                                                 'displayMode', 'off', ...
                                                 'g', icaMethod, ...
                                                 'epsilon', epsilon);
                                             
        end
        
    case 'InfoMax'
        
        if preWhiten
            
            [V D] = eig(cov(x'));
            Sph_infMax = diag(diag(D) .^ -0.5) * V';
            x_w = Sph_infMax * x;
            
            [Wgt_infMax, tmp] = runica( x_w, ...
                                        'sphering', 'none');
                                            
        else
            
            [Wgt_infMax, Sph_infMax] = runica(x);
            
        end
                                            
        W_infMax = Wgt_infMax * Sph_infMax;
        A_infMax = inv(W_infMax);
        s_infMax = W_infMax * x;
        
end

% Compute Correlations Between Columns of A and A (Estimated): -----------

switch ica
    case 'FastICA'
        corrCoefMtrx = abs(corrcoef([A, A_fICA]));
        [maxCorr, maxCorrIndx] = max(corrCoefMtrx(1:numIC, (numIC + 1):(2 * numIC)), [], 2);
    case 'InfoMax'
        corrCoefMtrx = abs(corrcoef([A, A_infMax]));
        [maxCorr, maxCorrIndx] = max(corrCoefMtrx(1:numIC, (numIC + 1):(2 * numIC)), [], 2);
end

% Save Stuff: ------------------------------------------------------------

switch ica
    case 'FastICA'
        save([runName '.mat'], 'A', 'A_fICA', 'W_fICA', 'x', 's_fICA', 'Sph_fica', '-mat');
    case 'InfoMax'
        save([runName '.mat'], 'A', 'A_infMax', 'W_infMax', 'x', 's_infMax', 'Sph_infMax', '-mat');
end

% Plot IC: ---------------------------------------------------------------

figure;
for i = 1:numIC
    subplot((numIC), 1, i); plot(n, s(i,:));
end
set(gcf, 'Position', [1  1  560  1050], 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', 'Independent Components (Original)');

% Plot Mixed Signals: ----------------------------------------------------

figure;
for i = 1:numIC
    subplot(numIC, 1, i); plot(n, x(i,:));
end
set(gcf, 'Position', [561  1  560  1050], 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', 'Mixed Signals');

% Plot IC (Estimated): ---------------------------------------------------

figure;
switch ica
    case 'FastICA'
        for i = 1:numIC
            subplot(numIC, 1, i); plot(n, s_fICA(maxCorrIndx(i),:));
            title(['IC # ' int2str(maxCorrIndx(i))]); set(gca,'XTicklabel', '');
        end
    case 'InfoMax'
        for i = 1:numIC
            subplot(numIC, 1, i); plot(n, s_infMax(maxCorrIndx(i),:));
            title(['IC # ' int2str(maxCorrIndx(i))]); set(gca,'XTicklabel', '');
        end
end
set(gcf, 'Position', [1121  1  560  1050], 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', 'Independent Components (Estimated)');

% Compute Power Spectral Density of IC: ----------------------------------

%for i = 1:numIC
%    [ps_s{i}, freq_s{i}] = periodogram(s(i,:), [], [], sampFreq);
%end

% Compute Power Spectral Density of Mixed Signals: -----------------------

%for i = 1:numIC
%    [ps_x{i}, freq_x{i}] = periodogram(x(i,:), [], [], sampFreq);
%end

% Compute Power Spectral Density of IC (Estimated): ----------------------

%switch ica
%    case 'FastICA'
%        for i = 1:numIC
%            [ps_s_fICA{i}, freq_s_fICA{i}] = periodogram(s_fICA(i,:), [], [], sampFreq);
%        end
%    case 'InfoMax'
%        for i = 1:numIC
%            [ps_s_infMax{i}, freq_s_infMax{i}] = periodogram(s_infMax(i,:), [], [], sampFreq);
%        end
%end

% Plot Power Spectral Density of IC: -------------------------------------

%figure;
%for i = 1:numIC
%    subplot((numIC) , 1, i); plot(freq_s{i}, ps_s{i});
%end
%set(gcf, 'Position', [1  1  560  1050], 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', 'Power Spectrum: Independent Components (Original)');

% Plot Power Spectral Density of Mixed Signals: --------------------------

%figure;
%for i = 1:numIC
%    subplot(numIC, 1, i); plot(freq_x{i}, ps_x{i});
%end
%set(gcf, 'Position', [561  1  560  1050], 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', 'Power Spectrum: Mixed Signals');

% Plot Power Spectral Density of IC (Estimated): -------------------------

%figure;
%switch ica
%    case 'FastICA'
%        for i = 1:numIC
%            subplot(numIC, 1, i); plot(freq_s_fICA{maxCorrIndx(i)}, ps_s_fICA{maxCorrIndx(i)});
%            title(['IC # ' int2str(maxCorrIndx(i))]); set(gca,'XTicklabel', '');
%        end
%    case 'InfoMax'
%        for i = 1:numIC
%            subplot(numIC, 1, i); plot(freq_s_infMax{maxCorrIndx(i)}, ps_s_infMax{maxCorrIndx(i)});
%            title(['IC # ' int2str(maxCorrIndx(i))]); set(gca,'XTicklabel', '');
%        end
%end
%set(gcf, 'Position', [1121  1  560  1050], 'MenuBar', 'none',
%'NumberTitle', 'off', 'Name','Power Spectrum: Independent Components (Estimated)');%

% Plot Columns of A: -----------------------------------------------------

figure;
for i = 1:numIC
    subplot((numIC), 1, i); plot(A(:, i), 'b');
    title(['Column # ' int2str(i)]); set(gca, 'XTicklabel', '');
end
set(gcf, 'Position', [1   1   840   1050], 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', 'Columns of Mixing Matrix A (Actual)')

% Plot Columns of A (Estimated): -----------------------------------------

figure;
    switch ica
        case 'FastICA'
            for i = 1:numIC
                subplot(numIC, 1, i); plot(A_fICA(:, maxCorrIndx(i)), 'b');
                title(['Column # ' int2str(maxCorrIndx(i)) ' | CorrCoef = ' num2str(maxCorr(i))]); set(gca,'XTicklabel', '');
            end
        case 'InfoMax'
            for i = 1:numIC
                subplot(numIC, 1, i); plot(A_infMax(:, maxCorrIndx(i)), 'b');
                title(['Column # ' int2str(maxCorrIndx(i)) ' | CorrCoef = ' num2str(maxCorr(i))]); set(gca,'XTicklabel', '');
            end
    end
set(gcf, 'Position', [841    1   840   1050], 'MenuBar', 'none', 'NumberTitle', 'off', 'Name', 'Columns of Mixing Matrix A (Estimated)');



[m n] = size(x);
WriteRaw([runName '_unwhite'], [], x, [], 0, m, n, sampFreq, 6);

if ( preWhiten == 1 )
    WriteRaw([runName '_white'], [], x_w, [], 0, m, n, sampFreq, 6);
end

function WriteRaw(fileName, header, eegData, eventData, addEvents, numChans, numSamples, samplingRate, versionNumber);

% Function [outputLog] = writeRaw(fileName, header, eegData, 
%                                 eventData, numChans, numSamples, samplingRate, versionNumber)
% writes blink-corrected EEG data, stored in the array eegData, to the file
% <fileName.raw> along with its corresponding header and, for numEvents > 0, event information.
%
% <fileName.raw> will be an epoch-marked simple-binary format (epoch-marked raw format) file.
%
% Epoch-marked raw format: Unsegmented simple-binary format (raw format,
%                          version # 2, 4 or 6) with event codes <epoc> and <tim0>.
%
% This function is to be used in combination with readRaw, which first parses
% the arrays header, eegData (pre blink-correction) and eventData from an 
% epoch-marked simple-binary format (epoch-marked raw format) file generated by NetStation.
%
% Input Arguments: fileName - Name of the EGI epoch-marked simple-binary format
%                             file originally read by readRaw.
%                             It must be a MATLAB string.
%
%                  header - MATLAB structure containing the header info.
%
%                  eegData - m1 by n array containing the continuous EEG data,
%                            ideally after ICA blink extraction.
%                            m1 = # of channels, n = # of time samples.
%
%                  eventData - m2 by n array containing the corresponding event info.
%                              m2 = # of event types, n = # of time samples.
%
%                  addEvents - logical 1 if user requests default events <epoc> and <tim0>.
%
%                  numChans - # of data channels (detectors).
%
%                  numSamples - # of time samples.
%
%                  samplingRate - the rate of sampling.
%
%                  versionNumber - 2: Integer, 4: single Precion Real, 
%                                  6: Double Precision Real

% Create the EGI epoch-marked raw format data file: <fileName.raw>.

fid = fopen([fileName '.raw'],'w','b');

if (fid == -1)  % File not found.
    
    errorMsg = sprintf('\n!!! File Creation Error: %s !!!\n', [fileName '.raw']); error(errorMsg);
    
end

if (nargin == 9)  % Header file NOT supplied.  Instantiate with user-supplied & default values.
    
    header.versionNumber = versionNumber;
    header.recordingTimeYear = 0;
    header.recordingTimeMonth = 0;
    header.recordingTimeDay = 0;
    header.recordingTimeHour = 0;
    header.recordingTimeMinute = 0;
    header.recordingTimeSecond = 0;
    header.recordingTimeMillisec = 0;
    header.samplingRate = samplingRate;
    header.numChans = numChans;
    header.boardGain = 0;
    header.numConvBits = 0;
    header.ampRange = 0;
    header.numSamples = numSamples;
    if addEvents
        header.numEvents = 2;
        header.eventCodes(1) = {'epoc'};
        header.eventCodes(2) = {'tim0'};
        eventData = zeros(2,numSamples);
        outputLog = strvcat(outputLog, ...
            ['Generated default event codes <epoc> and <tim0> (= 0 for all time samples)']);
    else
        header.numEvents = 0;
    end

end
    
% ---------------- Write the header information to the file. ---------------- 

fwrite(fid, header.versionNumber, 'integer*4');
fwrite(fid, header.recordingTimeYear, 'integer*2');
fwrite(fid, header.recordingTimeMonth, 'integer*2');
fwrite(fid, header.recordingTimeDay, 'integer*2');
fwrite(fid, header.recordingTimeHour, 'integer*2');
fwrite(fid, header.recordingTimeMinute, 'integer*2');
fwrite(fid, header.recordingTimeSecond, 'integer*2');
fwrite(fid, header.recordingTimeMillisec, 'integer*4');
fwrite(fid, header.samplingRate, 'integer*2');
fwrite(fid, header.numChans, 'integer*2');
fwrite(fid, header.boardGain, 'integer*2');
fwrite(fid, header.numConvBits, 'integer*2');
fwrite(fid, header.ampRange, 'integer*2');
fwrite(fid, header.numSamples, 'integer*4');
fwrite(fid, header.numEvents, 'integer*2');

if (header.numEvents ~= 0)  % File contains event info.
    
    for  i = 1:header.numEvents
        
        fwrite(fid, header.eventCodes{i}, 'uchar');
        
    end
    
end

% ---------------------- Finished writing the header. ----------------------

% Determine precision of data from version #.

switch header.versionNumber
   case 2
       precision = 'integer*2';  % Integer
   case 4
       precision = 'real*4';  % Single Precision Real
   case 6
       precision = 'real*8';  % Double Precision Real
end

%  --------- Write the SSR's and corresponding event records to the file. ---------

if (header.numEvents ~= 0)  % File contains event info.
    
    for j = 1:header.numSamples
        
        fwrite(fid, eegData(:,j), precision);
        fwrite(fid, eventData(:,j), precision);
        
    end
    
else  % File does not contain event info.
    
    fwrite(fid, eegData, precision);
    
end

% Close the file.

fclose(fid);


