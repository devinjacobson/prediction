function [ weights, sphere ] = rInfomax( data, p1, v1, p2, v2, p3, v3, p4, v4, p5, v5, p6, v6, p7, v7 )
% rInfomax() - Perform Independent Component Analysis (ICA) decomposition
%            of input data using the logistic infomax ICA algorithm of
%            Bell & Sejnowski (1995). Launch the process remotely on the
%            compute node located at rubato.nic.uoregon.edu using the
%            scp and SOAP interface
%            
% Usage:
%         >> [weights,sphere] = rInfomax(data); % train using defaults 
%    else
%          >> [weights,sphere] = rInfomax(data, 'Key1', 'Value1',...)
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

annealing = 0.9;
annealingDegree = 70;
blockSize = 'heuristic';
learningRate = 'heuristic';
maxSteps = 1000;
stopCondition = 'heuristic';
seed = 123456
sphering = 'sphering';



if ( nargin > 1 & rem( nargin, 2 ) == 0 )
    fprintf( 'rInfomax(): Even number of input arguments?' )
    return
end


% the remote execution command
for i = 3:2:nargin
    % grab the next keyword and value pair from the list
    keyword = eval(['p', int2str((i-3)/2 + 1)]);
    value = eval(['v', int2str((i-3)/2 + 1)]);
    if ~isstr( keyword )
        fprintf('rInfomax(): keywords must be strings')
        return
    end
    keyword = lower(keyword);

    if strcmp( keyword, 'lrate' )
        learningRate = value;
    elseif strcmp( keyword, 'block' )
        blockSize = value;
    elseif strcmp( keyword, 'anneal' )
        annealing = value;
    elseif strcmp( keyword, 'annealdeg' )
        annealingDegree = value
    elseif strcmp( keyword, 'stop' )
        stopCondition = value
    elseif strcmp( keyword, 'maxsteps' )
        maxSteps = value;
    end
end
id = rFileUpload( data, 'data', 'matlab infomax data' )
createClassFromWsdl( 'http://rubato.nic.uoregon.edu:4063/wsdl/test.wsdl' );
t = TestService();
infomax( t, id, sphering, annealing, annealingDegree, blockSize, learningRate, maxSteps, stopCondition, seed )
