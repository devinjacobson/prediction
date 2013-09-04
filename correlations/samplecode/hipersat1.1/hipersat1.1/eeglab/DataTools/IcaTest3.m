function IcaTest3(runName, freqIC, secOfData);

close all; clc;

runName = '4x1001';
nargin = 1;
if nargin == 0
    runName = input('Enter a run series name: ', 's');
end

% ------------------------------Constants---------------------------------

sampFreq                =  250;                 % Sampling Frequency (Hz)

if nargin < 2
    
    freqIC              =  [4; 8; 16; 25];      % Frequency (Hz) Of IC
    
    secOfData           =  4;                   % # Of Seconds Of Data Collected
    
end

% ****** FastICA Parameters Only ******

epsilon     =  0.0001;  % FastICA Convergence Tolerance
%icaMethod   =  'pow3';  % FastICA Contrast Function: Cubic = 'pow3', Hyperbolic Tangent = 'tanh', Guassian = 'gauss'

% *************************************

%-------------------------------------------------------------------------

twoPi = 2 * pi;
numIC = length(freqIC);
sampInterval = 1 / sampFreq;
n = 0 : sampInterval : secOfData;

% Generate IC: -----------------------------------------------------------

s = sin((twoPi .* freqIC) * n );

% Generate Mixing Matrix A: ----------------------------------------------

A = randn(numIC);

% Generate Mixed Signals ------------------------------------------------

x = A * s;

% ICA: -------------------------------------------------------------------

c = cov(x',1);
fprintf( 'Bob thinks cov=\n' );
c

[V D] = eig(c);

Sph_F = inv(sqrt(D)) * V';
x_WF  = Sph_F * x;
            
[tmp_tanh, Wgt_F_tanh] = fastica( x_WF, ...
                        'initGuess',    eye(numIC), ...
                        'whiteSig',     x_WF, ...
                        'whiteMat',     eye(numIC), ...
                        'dewhiteMat',   eye(numIC), ...
                        'displayMode',  'off', ...
                        'g',            'tanh', ...
                        'epsilon',      epsilon);
                    
W_F_tanh = Wgt_F_tanh * Sph_F;
A_F_tanh = inv(W_F_tanh);
                  

[tmp_cubic, Wgt_F_cubic] = fastica( x_WF, ...
                        'initGuess',    eye(numIC), ...
                        'whiteSig',     x_WF, ...
                        'whiteMat',     eye(numIC), ...
                        'dewhiteMat',   eye(numIC), ...
                        'displayMode',  'off', ...
                        'g',            'pow3', ...
                        'epsilon',      epsilon);
                    
W_F_cubic = Wgt_F_cubic * Sph_F;
A_F_cubic = inv(W_F_cubic);
                  

Sph_I = 2 * V * Sph_F;

if ( 1 == 0 )
	Sph_I2 = 2 * inv( sqrtm( cov( x' ) ) );

	x1 = cov( ( Sph_I * x )' );
	x2 = cov( ( Sph_I2 * x )' );

	fprintf( '=========== x1\n' );
	Sph_I
	x1
	Sph_I2
	x2
	fprintf( '===========\n' );

	for i =1:4
		x1(i,i)=1;
		x2(i,i)=1;
	end;

	fprintf( 'x1max=%d\n', max( max( abs( eye( 4 ) - x1 ) ) ) );
	fprintf( 'x2max=%d\n', max( max( abs( eye( 4 ) - x2 ) ) ) );

	return;
end;


x_WI  = Sph_I * x;
 
[Wgt_I, tmp] = runica( x_WI, ...
                       'sphering', 'none', ...
                       'lrate',  0.001);
                   
W_I = Wgt_I * Sph_I;
A_I = inv(W_I);



[Wgt_IU, Sph_IU] = runica( x, ...
                       'lrate',  0.001);
WriteAscii( [runName '-Wgt_IU.txt'], Wgt_IU );
WriteAscii( [runName '-Sph_IU.txt'], Sph_IU );
          

WriteBinary( [runName '-Sph_F.scf'], Sph_F );
WriteAscii( [runName '-Sph_F.txt'], Sph_F );
WriteRaw([runName '-Sph_F'], [], Sph_F, [], 0, size(Sph_F,1), size(Sph_F,2), sampFreq, 6);

WriteBinary( [runName '-x_WF.scf'], x_WF );
WriteRaw([runName '-x_WF'], [], x_WF, [], 0, size(x_WF,1), size(x_WF,2), sampFreq, 6);



WriteBinary( [runName '-Wgt_F_tanh.scf'], Wgt_F_tanh);
WriteAscii( [runName '-Wgt_F_tanh.txt'], Wgt_F_tanh);
WriteRaw([runName '-Wgt_F_tanh'], [], Wgt_F_tanh, [], 0, size(Wgt_F_tanh,1), size(Wgt_F_tanh,2), sampFreq, 6);

WriteBinary( [runName '-A_F_tanh.scf'], A_F_tanh );
WriteAscii( [runName '-A_F_tanh.txt'], A_F_tanh );
WriteRaw([runName '-A_F_tanh'], [], A_F_tanh, [], 0, size(A_F_tanh,1), size(A_F_tanh,2), sampFreq, 6);

WriteBinary( [runName '-W_F_tanh.scf'], W_F_tanh );
WriteAscii( [runName '-W_F_tanh.txt'], W_F_tanh );
WriteRaw([runName '-W_F_tanh'], [], W_F_tanh, [], 0, size(W_F_tanh,1), size(W_F_tanh,2), sampFreq, 6);



WriteBinary( [runName '-Wgt_F_cubic.scf'], Wgt_F_cubic);
WriteAscii( [runName '-Wgt_F_cubic.txt'], Wgt_F_cubic);
WriteRaw([runName '-Wgt_F_cubic'], [], Wgt_F_cubic, [], 0, size(Wgt_F_cubic,1), size(Wgt_F_cubic,2), sampFreq, 6);

WriteBinary( [runName '-A_F_cubic.scf'], A_F_cubic );
WriteAscii( [runName '-A_F_cubic.txt'], A_F_cubic );
WriteRaw([runName '-A_F_cubic'], [], A_F_cubic, [], 0, size(A_F_cubic,1), size(A_F_cubic,2), sampFreq, 6);

WriteBinary( [runName '-W_F_cubic.scf'], W_F_cubic );
WriteAscii( [runName '-W_F_cubic.txt'], W_F_cubic );
WriteRaw([runName '-W_F_cubic'], [], W_F_cubic, [], 0, size(W_F_cubic,1), size(W_F_cubic,2), sampFreq, 6);



WriteBinary( [runName '-Sph_I.scf'], Sph_I );
WriteAscii( [runName '-Sph_I.txt'], Sph_I );
WriteRaw([runName '-Sph_I'], [], Sph_I, [], 0, size(Sph_I,1), size(Sph_I,2), sampFreq, 6);

WriteBinary( [runName '-x_WI.scf'], x_WI );
WriteRaw([runName '-x_WI'], [], x_WI, [], 0, size(x_WI,1), size(x_WI,2), sampFreq, 6);

WriteBinary( [runName '-Wgt_I.scf'], Wgt_I );
WriteAscii( [runName '-Wgt_I.txt'], Wgt_I );
WriteRaw([runName '-Wgt_I'], [], Wgt_I, [], 0, size(Wgt_I,1), size(Wgt_I,2), sampFreq, 6);

WriteBinary( [runName '-A_I.scf'], A_I );
WriteAscii( [runName '-A_I.txt'], A_I );
WriteRaw([runName '-A_I'], [], A_I, [], 0, size(A_I,1), size(A_I,2), sampFreq, 6);

WriteBinary( [runName '-W_I.scf'], W_I );
WriteAscii( [runName '-W_I.txt'], W_I );
WriteRaw([runName '-W_I'], [], W_I, [], 0, size(W_I,1), size(W_I,2), sampFreq, 6);

WriteBinary( [runName '-x.scf'], x );
WriteRaw([runName '-x'], [], x, [], 0, size(x,1), size(x,2), sampFreq, 6);

WriteBinary( [runName '-i.scf'], eye( 4 ) );

WriteBinary( [runName '-s.scf'], s );
WriteRaw([runName '-s'], [], s, [], 0, size(s,1), size(s,2), sampFreq, 6);

return;


%-------------------------
function result = WriteBinary( fname, x )
	fid = fopen( fname, 'w', 'b' );
	fwrite( fid, x, 'real*8' );
	result = true;


%-------------------------
function result = WriteAscii( fname, x )
	fid = fopen( fname, 'w');
	for i=1:size(x,1)
		fprintf(fid,'%12.6f\t', x(i,:) );
		fprintf(fid,'\n');
	end;
	fclose(fid);
	result = true;
    
    
%-------------------------
function [outputLog] = WriteRaw...
    (fileName, header, eegData, eventData, addEvents, numChans, numSamples, samplingRate, versionNumber);

% Writes data, stored in the array eegData, to the file
% <fileName.raw> along with its corresponding header and, for numEvents > 0, event information.
%
% <fileName.raw> will be an epoch-marked simple-binary format (epoch-marked raw format) file.
%
% Epoch-marked raw format: Unsegmented simple-binary format (raw format,
%                          version # 2, 4 or 6) with event codes <epoc> and <tim0>.
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
%
% Output Arguments: outputLog - Character array of relevant steps taken
%                               during program execution.

% Create the EGI epoch-marked raw format data file: <fileName.raw>.

fid = fopen([fileName '.raw'],'w','b');

if (fid == -1)  % File not found.
    
    error(sprintf('\n\n File Creation Error: %s \n\n', [fileName '.raw']));
    
end

outputLog = ['OutputFile = <' fileName '.raw>'];   % Seed outputLog.


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
        header.numEvents = 2
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


