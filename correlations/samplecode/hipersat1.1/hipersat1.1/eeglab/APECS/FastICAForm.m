%FASTICA - Fast Independent Component Analysis
%
% FastICA for Matlab 6.x
% Version 2.3, July 27 2004
% Copyright (c) Jarmo Hurri, Hugo Gävert, Jaakko Särelä, and Aapo Hyvärinen.
%
% FASTICA estimates the independent components from given multidimensional
% signals. Each row of matrix mixedsig is one observed signal. FASTICA uses
% Hyvarinen's fixed-point algorithm, see:
%
%   http://www.cis.hut.fi/projects/ica/fastica/.
%
% FASTICA can be called with numerous optional arguments. Optional arguments
% are given in parameter pairs, so that first argument is the name of the
% parameter and the next argument is the value for that parameter. Optional
% parameter pairs can be given in any order.
%
% OPTIONAL PARAMETERS:
%
% Parameter name        Values and description
%
%===============================================================================
% --Basic parameters in fixed-point algorithm:
%
% 'approach'            (string) The decorrelation approach used. Can be
%                       symmetric ('symm'), i.e. estimate all the independent
%                       components in parallel, or deflation ('defl'), i.e.
%                       estimate independent components one-by-one like in
%                       projection pursuit. Default is 'defl'.
%
approach        =       'defl';
%
% 'numOfIC'             (integer or []) Number of independent components to be
%                       estimated. Default is [] => # of data channels.
%
numOfIC         =       [];
%
%===============================================================================
% --Choosing the nonlinearity:
%
% 'g'                   (string) Chooses the nonlinearity g used in the
%                       fixed-point algorithm. Possible values:
%
%                       Value of 'g':      Nonlinearity used:
%                       'pow3' (default)   g(u)=u^3
%                       'tanh'             g(u)=tanh(a1*u)
%                       'gauss'            g(u)=u*exp(-a2*u^2/2)
%                       'skew'             g(u)=u^2
%
g               =       'tanh';
% 
% 'finetune'            (string) Chooses the nonlinearity 'g' when fine-tuning.
%                       In addition to same values as for 'g', a possible value
%                       for 'finetune' is 'off' => fine-tuning is disabled.
%
finetune        =       'off';
%
% 'a1'                  (number) Parameter a1 used when g ='tanh'. Default is 1.
%
a1              =       1;
%
% 'a2'                  (number) Parameter a2 used when g ='gauss'. Default is 1.
%
a2              =       1;
%
% 'mu'                  (number) Step size. Default is 1.
%                       If the value of mu is other than 1, then the program
%                       will use the stabilized version of the algorithm
%                       (see parameter 'stabilization').
%
mu              =       1;
%
%
% 'stabilization'       (string) Values 'on' or 'off'. Default is 'off'. 
%                       This parameter controls whether the program uses the
%                       stabilized version of the algorithm or not. If the 
%                       stabilization is on, then the value of mu can be halved,
%                       momentarily, when the program senses that the algorithm
%                       is stuck between two points (this is called a stroke).
%                       Also, if there is no convergence before half of the
%                       maximum number of iterations has been reached, then mu
%                       will be halved for the rest of the rounds.
%
stabilization   =       'off';
%
%===============================================================================
% --Controlling convergence:
%
% 'epsilon'             (number) Stopping criterion. Default is 0.0001.
%
epsilon             =   0.000001;
%
% 'maxNumIterations'    (integer) Maximum number of iterations. Default is 1000.
%
maxNumIterations    =   1000;
%
% 'maxFinetune'         (integer) Maximum number of iterations in fine-tuning.
%                       Default is 100.
%
maxFinetune         =   100;
%
% 'initState'           (string) Initial state setting for A. Default is 'rand'
%                       => random. Other option is 'seed'.
%
initState           =   'rand';
%
% 'seed'                (array) Starting seed for matrix A. Only used if
%                       initState = 'seed'.
%
seed                =   [];
%
% 'sampleSize'          (number) [0 - 1] Percentage of samples used in one
%                       iteration. Samples are chosen in random.
%                       Default is 1 => all samples.
%
sampleSize          =   1;
%
%===============================================================================
% --Display
%
% 'verbose'             Report progress as screen text. Default is 'on'.
%
verbose             =   'on';
