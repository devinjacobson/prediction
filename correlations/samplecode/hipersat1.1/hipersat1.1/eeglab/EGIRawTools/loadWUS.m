%
% This MATLAB script will build sample input data and compute the 'correct' output using
% the MATLAB version of fastica. (Currently, the data originates in the icatest.m script, which
% is not currently part of the distribution).
%
tic

nChannels = 128;
nObservations = 100000;
fileName = sprintf( '%dx%d', nChannels, nObservations );

%whiteFile = [ fileName '_white' ];
unwhiteFile = [ fileName '_unwhite' ];
sphereFile = [ 'Sph' fileName '.scf' ];

%[ whiteHeader, whiteData, whiteEventData, whiteOutputLog ] = ReadRaw( whiteFile );
%disp( sprintf( '\nFile %s has been loaded', whiteFile ) );

%[ unwhiteHeader, unwhiteData, unwhiteEventData, unwhiteOutputLog ] = ReadRaw( unwhiteFile );
unwhiteFile = [unwhiteFile '.scf']
unwhiteFile
fid = fopen(unwhiteFile,'r','b');
unwhiteData = fread(fid,[128,inf],'double');
fclose(fid);
disp( sprintf( '\nFile %s has been loaded', unwhiteFile ) );


contrastFunc = 'cubic';
weightFile = [ fileName '_' contrastFunc '_correct_weight' ];
fprintf( 'Generating fastica weights for file: %s', weightFile );

[ A, W ] = fastica( ...
    unwhiteData, ...
    'g', 'pow3', ...
    'initGuess', eye( nChannels ), ...
    'epsilon', 0.0001, ...
    'verbose', 'off', ...
    'maxNumIterations', 1000 );
weight = W * inv( eye( nChannels ) );

fprintf( 'Writing EEGLab weights to file: %s', weightFile );
fid = fopen( weightFile, 'wb' );
fwrite( fid, weight, 'real*8' );
fclose( fid )

fprintf( 'Here is the EEGLab weight matrix for the %s contrast function', contrastFunc );

cubicWeight = weight;
cubicWeight( 1:nChannels, 1:nChannels )


fprintf( 'Here is the EEGLab sph matrix for the %s contrast function', contrastFunc );

cubicWeight = weight;
cubicWeight( 1:nChannels, 1:nChannels )

toc
return;
