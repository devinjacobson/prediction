% runica() - Perform Independent Component Analysis (ICA) decomposition
%            of input data using the logistic infomax ICA algorithm of 
%            Bell & Sejnowski (1995) with the natural gradient feature 
%            of Amari, Cichocki & Yang, or optionally the extended-ICA 
%            algorithm of Lee, Girolami & Sejnowski, with optional PCA 
%            dimension reduction. Annealing based on weight changes is 
%            used to automate the separation process.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Options%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%                            
% 'lrate'     = [float] Initial ICA learning rate (<< 1).
%               Default is 0 => heuristic.
%

lrate         = 0.001;

%
% 'maxsteps'  = [integer] Max number of ICA training steps. Default is 512.
%

maxsteps      = 1024;

%
% 'stop'      = [float] Stop training when weight-change < this. Default is 1E-6
%               if less than 33 channels and 1E-7 otherwise.
%

stop          = 0.000001;

%
% 'numOfIC'   = (integer or []) Number of independent components to be
%               estimated. Default is [] => # of data channels.
%

numOfIC       = [];

%
% 'weights'   = [matrix or 0] Initial weight matrix. Default is 0 => Identity
%               Matrix.
%

weights       = 0;

%
% 'extended'  = [integer] Perform tanh "extended-ICA" with sign estimation. 
%               If N > 0, automatically estimate the number of sub-Gaussian
%               sources. If N < 0, fix number of sub-Gaussian comps to -N.
%               Default is 0 => off.
%

extended      = 0;

%
% 'verbose'   = ['on'/'off'] Give ascii messages. Default is 'on'.
%

verbose       = 'on';
