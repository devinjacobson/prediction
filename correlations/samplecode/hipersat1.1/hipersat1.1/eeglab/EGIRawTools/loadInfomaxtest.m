%
% This MATLAB script will build sample input data and compute the 'correct' output using
% the MATLAB version of Infomax (runica). (Currently, the data originates in the icatest.m script, which
% is not currently part of the distribution).
%

nChannels = 4;
nObservations = 1001;
fileName = sprintf( '%dx%d', nChannels, nObservations );

whiteFile = [ fileName '-x_WI' ];
%unwhiteFile = [ fileName '_unwhite' ];
%sphereFile = [ 'Sph' fileName ];

[ whiteHeader, whiteData, whiteEventData, whiteOutputLog ] = ReadRaw( whiteFile );
%disp( sprintf( '\nFile %s has been loaded', whiteFile ) );
%raw2scf( whiteFile );
%disp( sprintf( '\nFile %s has been converted to %s', whiteFile, [ whiteFile '.scf' ] ) );

%[ unwhiteHeader, unwhiteData, unwhiteEventData, unwhiteOutputLog ] = ReadRaw( unwhiteFile );
%disp( sprintf( '\nFile %s has been loaded', unwhiteFile ) );
%raw2scf( unwhiteFile );
%disp( sprintf( '\nFile %s has been converted to %s', unwhiteFile, [ unwhiteFile '.scf' ] ) );

%[ sphereHeader, sphereData, sphereEventData, sphereOutputLog ] = ReadRaw( sphereFile );
%disp( sprintf( '\nFile %s has been loaded', sphereFile ) );
%raw2scf( sphereFile );
%disp( sprintf( '\nFile %s has been converted to %s', sphereFile, [ sphereFile '.scf' ] ) );

%weightFile_binary = [ fileName '_infomax_correct_weight_binary' ];
%fprintf( 'Generating Infomax weights for file: %s', weightFile_binary);

[weights,sphere] ...
               = runica(whiteData, 'lrate', 0.001, ...
                'sphering', 'none'...
           );
           
%fprintf( 'Writing matlab weights to file: %s', weightFile_binary );
%fid = fopen( weightFile_binary, 'wb' );
%fwrite( fid, weights, 'real*8' );
%fclose( fid )

%fprintf( 'weights are: \n' );
%weights
