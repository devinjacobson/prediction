function [weights, sphering] = hSobi( data )
% 
% Perform the Second Order Blind Identification (SOBI) algorithm on the
% input data using the HiperSAT C++ implementation of SOBI. This implementation
% assumes that the data has been centred and sphered.
%
% Usage:
% >> weights = hSobi( data )
% 
% Input:
%    data = input data (channels, samples)
%
% Output:
%    weights = the computed weight matrix

    [ channels samples ]= size( data );
    c = channels;
    channels = int2str( channels );
    samples = int2str( samples );

    % The following two lines work in Matlab. Comment them out
    % if you are using Octave
    info = what( 'hipersat' );
    hiperSatPath = info.path;

    % The following twol lines work in Octave. Comment them out
    % if you are using Matlab
    %hiperSatPath = file_in_path( LOADPATH, "hSobi.m" );     % Octave specific code
    %hiperSatPath = hiperSatPath( 1:size(hiperSatPath)(2)-8 ); % Octave specific code

    dataFileName = [ hiperSatPath filesep 'scratch' filesep 'data' ];
    dataFileId = fopen( dataFileName, 'wb', 'b' );
    fwrite( dataFileId, data, 'double' );
    fclose( dataFileId );

    spheringFileName = [ hiperSatPath filesep 'scratch' filesep 'sphere' ];
    weightsFileName = [hiperSatPath filesep 'scratch' filesep 'weights' ];

    % The following two lines work in Matlab. Comment them out if you 
    % are using Octave
    command = ['!' hiperSatPath filesep '..' filesep '..' filesep 'bin' filesep 'hSobi -i ' dataFileName ' -if big -og ' weightsFileName ' -of big -c ' channels ' -s ' samples ' -sphering -os ' spheringFileName ]
    eval( command );

    % The following two lines work in Octave. Comment them out if
    % you are using Matlab
    %command = [hiperSatPath '/../../bin/hSobi -i ' dataFileName ' -if big  -o ' weightsFileName ' -of big -c ' channels ' -s ' samples ];
    %system( command );     % Octave specific code

    weightsFileId  = fopen( weightsFileName, 'rb', 'b' );
    weights = fread( weightsFileId, [c c], 'double' );
    fclose( weightsFileId );

    spheringFileId = fopen( spheringFileName, 'rb', 'b' );
    sphering = fread( spheringFileId, [c c], 'double' );
    fclose( spheringFileId );

    return
