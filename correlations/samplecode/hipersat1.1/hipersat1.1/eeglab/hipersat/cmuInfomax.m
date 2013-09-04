function [ weights, sphere ] = cmuInfomax( data, p1, v1, p2, v2, p3, v3, p4, v4, p5, v5, p6, v6, p7, v7 )
% cmuInfomax() - Perform Independent Component Analysis (ICA) decomposition
%            of input data using the logistic infomax ICA algorithm of
%            Bell & Sejnowski (1995). Launch the process remotely on the
%            compute node located at Carnegie Mellon University
%            Based on the implementation of Makeig et. al.
%            
% Usage:
%         >> [weights,sphere] = runica(data); % train using defaults 
%    else
%          >> [weights,sphere] = runica(data, 'Key1', 'Value1',...)
% Input:
%    data     = input data (chans,frames*epochs). 
%               Note that if data consists of multiple discontinuous epochs, 
%               each epoch should be separately baseline-zero'd using
%                  >> data = rmbase(data,frames,basevector);
%
% Optional keywords [argument]:
% 'lrate'     = [rate] initial ICA learning rate (<< 1) (default -> heuristic)
% 'block'     = [N] ICA block size (<< datalength)      (default -> heuristic)
% 'anneal'    = annealing constant (0,1] (defaults -> 0.90, or 0.98, extended)
%                         controls speed of convergence
% 'annealdeg' = [N] degrees weight change for annealing (default -> 70)
% 'stop'      = [f] stop training when weight-change < this (default -> 1e-6
%               if less than 33 channel and 1E-7 otherwise)
% 'maxsteps'  = [N] max number of ICA training steps    (default -> 512)
%
% Outputs: 
% weights     = ICA weight matrix (comps,chans) 
% sphere      = data sphering matrix (chans,chans) = spher(data)
%               Note that unmixing_matrix = weights*sphere {if sphering off -> eye(chans)}

% set up the initial data
uniqueId = makeId
[ channels samples ] = size( data );
c = channels;
channels = int2str( channels );
samples = int2str( samples );

% set up the working directories
info = what( 'hipersat' )
hiperSatPath = info.path
inputDir = ['/tmp/input' uniqueId ];
outputDir = ['/tmp/output' uniqueId ];
remoteBin = '/new/usr4/cchoge/hipersat/bin'
eval( ['!mkdir ' inputDir ] )
eval( ['!mkdir ' outputDir ] )

% file names
dataFileName = [ inputDir '/data' ]
spheringFileName = [ outputDir '/sphere' ];
weightsFileName = [ outputDir '/weights' ];



if ( nargin > 1 & rem( nargin, 2 ) == 0 )
    fprintf( 'cmuInfomax(): Even number of input arguments?' )
    return
end

username = ''

% the minimum command needed to run hipersat
hCommand = [remoteBin '/hInfomax -i ' dataFileName ' -if big -os ' spheringFileName ' -og ' weightsFileName ' -of big -c ' channels ' -s ' samples ' -sphering' ];

% the remote execution command
for i = 3:2:nargin
    % grab the next keyword and value pair from the list
    keyword = eval(['p', int2str((i-3)/2 + 1)]);
    value = eval(['v', int2str((i-3)/2 + 1)]);
    if ~isstr( keyword )
        fprintf('cmuInfomax(): keywords must be strings')
        return
    end
    keyword = lower(keyword);

    if strcmp( keyword, 'lrate' )
        hCommand = [ hCommand ' -lrate ' num2str( value ) ];
    elseif strcmp( keyword, 'block' )
        hCommand = [ hCommand, ' -block ' num2str( value ) ];
    elseif strcmp( keyword, 'anneal' )
        hCommand = [ hCommand, ' -anneal ' num2str( value ) ];
    elseif strcmp( keyword, 'annealdeg' )
        hCommand = [ hCommand, ' -annealdeg ' num2str( value ) ];
    elseif strcmp( keyword, 'stop' )
        hCommand = [ hCommand, ' -stop ' num2str( value ) ];
    elseif strcmp( keyword, 'maxsteps' )
        hCommand = [ hCommand, ' -maxsteps ' num2str( value ) ];
    elseif strcmp( keyword, 'user' )
        username = value;
    end
end

command = [ '!' hiperSatPath filesep 'processLauncher -c "' hCommand '" -i ' inputDir ' -o ' outputDir ' -r cchoge@newhaven.lti.cs.cmu.edu -p ""' ]

dataFileId = fopen( dataFileName, 'wb', 'b' );
fwrite( dataFileId, data, 'double' );
fclose( dataFileId );

eval( command )


function id = makeId()
    x = clock();
    id = [ int2str( x(1) ) int2str( x(2) ) int2str( x(3) ) int2str( x(4) ) int2str( x(5) ) int2str( floor( x(6) ) ) ];

function writeFile( file, data )
    file
    data
