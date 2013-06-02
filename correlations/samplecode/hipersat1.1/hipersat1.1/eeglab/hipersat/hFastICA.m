function [weights, sphering] = hFastICA( data )
% The HiPerSAT implementation of Fast Independent 
% Component Analysis. This implementation uses
% Hyvarinen's fixed-point algorithm in deflationary
% mode.
%
% Usage:
% >> [weights, sphering] = hFastICA( data )
% 
% Input:
%    data = input data (channels, samples)
%
% Output:
%    weights = the computed weight matrix
%    sphering = the computed sphering matrix

    [ channels samples ]= size( data );
    c = channels;
    channels = int2str( channels );
    samples = int2str( samples );

    % The following two lines work in Matlab. Comment them out
    % if you are using Octave
    info = what( 'hipersat' );      % Matlab specific code
    hiperSatPath = info.path;       % Matlab specific code

    % The following twol lines work in Octave. Comment them out
    % if you are using Matlab
    %hiperSatPath = file_in_path( LOADPATH, "hFastICA.m" );     % Octave specific code
    %hiperSatPath = hiperSatPath( 1:size(hiperSatPath)(2)-11 ); % Octave specific code

    dataFileName = [ hiperSatPath filesep 'scratch' filesep 'data' ];
    dataFileId = fopen( dataFileName, 'wb', 'b' );
    fwrite( dataFileId, data, 'double' );
    fclose( dataFileId );

    spheringFileName = [ hiperSatPath filesep 'scratch' filesep 'sphere' ];
    weightsFileName = [hiperSatPath filesep 'scratch' filesep 'weights' ];

    % The following two lines work in Matlab. Comment them out if you 
    % are using Octave
    command = ['!' hiperSatPath filesep '..' filesep '..' filesep 'bin' filesep 'hFastICA -i ' dataFileName ' -if big -os ' spheringFileName ' -og ' weightsFileName ' -of big -c ' channels ' -s ' samples ' -sphering -C cubic -t 0.0001 -I 1000 -g random -r 100'  ];     % Matlab specific code
    eval( command );    % Matlab specific code

    % The following two lines work in Octave. Comment them out if
    % you are using Matlab
    %command = [ hiperSatPath '/../../bin/hFastICA -i ' dataFileName ' -if big -os ' spheringFileName ' -og ' weightsFileName ' -of big -c ' channels ' -s ' samples ' -S -C cubic -t 0.0001 -I 1000 -g random -r 100'  ];     % Matlab specific code
    %system( command );     % Octave specific code


    spheringFileId = fopen( spheringFileName, 'rb' ,'b' );
    sphering = fread( spheringFileId, [c c], 'double' );
    fclose( spheringFileId );
   
    weightsFileId  = fopen( weightsFileName, 'rb', 'b' );
    weights = fread( weightsFileId, [c c], 'double' );
    fclose( weightsFileId );

    return
