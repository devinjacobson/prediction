function [weights, sphering] = hInfomax( data )
% 
% Perform Independent Component Analysis (ICA) decomposition of
% input data using the Infomax ICA algorithm of Bell & Sejnowski (1995)
% using the default arguments for the eeglab implementation (runica)
%
% Usage:
% >> [weights, sphering] = hInfomax( data )
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

    mfilename

    % The following twol lines work in Octave. Comment them out
    % if you are using Matlab
    %hiperSatPath = file_in_path( LOADPATH, "hInfomax.m" );     % Octave specific code
    %hiperSatPath = hiperSatPath( 1:size(hiperSatPath)(2)-11 ); % Octave specific code

    dataFileName = [ hiperSatPath filesep 'scratch' filesep 'data' ];
    dataFileId = fopen( dataFileName, 'wb', 'b' );
    fwrite( dataFileId, data, 'double' );
    fclose( dataFileId );

    spheringFileName = [ hiperSatPath filesep 'scratch' filesep 'sphere' ];
    weightsFileName = [hiperSatPath filesep 'scratch' filesep 'weights' ];

    % The following two lines work in Matlab. Comment them out if you 
    % are using Octave
    command = ['!' hiperSatPath filesep '..' filesep '..' filesep 'bin' filesep 'hInfomax -i ' dataFileName ' -if big -os ' spheringFileName ' -og ' weightsFileName ' -of big -c ' channels ' -s ' samples ' -sphering'  ];     % Matlab specific code
    eval( command );    % Matlab specific code

    % The following two lines work in Octave. Comment them out if
    % you are using Matlab
    %command = [hiperSatPath '/../../bin/hInfomax -i ' dataFileName ' -if big -os ' spheringFileName ' -og ' weightsFileName ' -of big -c ' channels ' -s ' samples ' -sphering'  ];    % Octave specific code
    %system( command );     % Octave specific code


    spheringFileId = fopen( spheringFileName, 'rb' ,'b' );
    sphering = fread( spheringFileId, [c c], 'double' );
    fclose( spheringFileId );
   
    weightsFileId  = fopen( weightsFileName, 'rb', 'b' );
    weights = fread( weightsFileId, [c c], 'double' );
    fclose( weightsFileId );

    return
