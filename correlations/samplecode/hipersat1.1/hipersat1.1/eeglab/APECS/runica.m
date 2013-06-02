% runica() - Perform Independent Component Analysis (ICA) decomposition
%            of input data using the logistic infomax ICA algorithm of 
%            Bell & Sejnowski (1995) with the natural gradient feature 
%            of Amari, Cichocki & Yang, or optionally the extended-ICA 
%            algorithm of Lee, Girolami & Sejnowski, with optional PCA 
%            dimension reduction. Annealing based on weight changes is 
%            used to automate the separation process.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% 'extended'  = [integer] Perform tanh "extended-ICA" with sign estimation 
%               If N > 0, automatically estimate the number of sub-Gaussian
%               sources. If N < 0, fix number of sub-Gaussian comps to -N.
%               Default is 0 => off.
%

%
% 'pca'       = [integer] Decompose a principal component subspace of the data.
%               Value is the number of PCs to retain. Default is 0 => off.
%

%
% 'ncomps'    = [integer] Number of ICA components to compute using rectangular
%               ICA decomposition. Default is channels.
%

%
% 'sphering'  = ['on'/'off'/'none'] Flag sphering of data. Default is 'none'.
%

%
% 'weights'   = [matrix] Initial weight matrix. Default is eye().
%

%                            
% 'lrate'     = [float] Initial ICA learning rate (<< 1). Default is heuristic.
%

%
% 'block'     = [integer] ICA block size (<< datalength). Default is heuristic.
%

%
% 'anneal'    = Annealing constant (0,1]. Default is 0.90, or 0.98 if extended.
%               Controls speed of convergence.
%

%
% 'annealdeg' = [integer] Degrees weight change for annealing. Default is 60.
%

%
% 'stop'      = [float] Stop training when weight-change < this. Default is 1E-6
%               if less than 33 channels and 1E-7 otherwise.
%

%
% 'maxsteps'  = [integer] Max number of ICA training steps. Default is 512.
%

%
% 'bias'      = ['on'/'off'] Perform bias adjustment. Default is 'on'.
%

%
% 'momentum'  = [0,1] Training momentum. Default is 0.
%

%
% 'posact'    = Make all component activations net-positive. Default is 'off'.
%

%
% 'verbose'   = Give ascii messages ('on'/'off'). Default is 'on'.
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
% weights     = [ReverseOrder] ICA weight matrix (comps, chans).
%

%
% bias        = [RO] Vector of final (ncomps) online bias. Default => zeros().
%

%
% signs       = [RO] Extended-ICA signs for components. Default => ones().
%               (-1 = sub-Gaussian; 1 = super-Gaussian)
%

%
% lrates      = [RO] Vector of learning rates used at each training step.
%

%
% y           = Nonlinearly transformed output of Neurons
%

% Authors: Scott Makeig with contributions from Tony Bell, Te-Won Lee, 
% Tzyy-Ping Jung, Sigurd Enghoff, Michael Zibulevsky, Delorme Arnaud,
% CNL/The Salk Institute, La Jolla, 1996-
%
% Reference (please cite):
%
% Makeig, S., Bell, A.J., Jung, T-P and Sejnowski, T.J.,
% "Independent component analysis of electroencephalographic data," 
% In: D. Touretzky, M. Mozer and M. Hasselmo (Eds). Advances in Neural 
% Information Processing Systems 8:145-151, MIT Press, Cambridge, MA (1996).
%
% Toolbox Citation:
%
% Makeig, Scott et al. "EEGLAB: ICA Toolbox for Psychophysiological Research". 
% WWW Site, Swartz Center for Computational Neuroscience, Institute of Neural
% Computation, University of San Diego California
% <www.sccn.ucsd.edu/eeglab/>, 2000. [World Wide Web Publication]. 
%
% For more information:
% http://www.sccn.ucsd.edu/eeglab/icafaq.html - FAQ on ICA/EEG
% http://www.sccn.ucsd.edu/eeglab/icabib.html - mss. on ICA & biosignals
% http://www.cnl.salk.edu/~tony/ica.html - math. mss. on ICA
%
% Copyright (C) 1996 Scott Makeig et al, SCCN/INC/UCSD, scott@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation.
%
% $Log: runica.m,v $
% Revision 1.23  2004/10/06 20:41:10  scott
%
% Revision 1.22  2004/10/06 20:40:32  scott
%
% Revision 1.21  2004/10/06 20:39:20  scott
%
% Revision 1.20  2004/06/29 16:44:09  scott
%
% Revision 1.19  2004/05/16 01:13:19  scott
%
% Revision 1.18  2004/05/16 01:09:30  scott
%
% Revision 1.17  2004/05/16 01:07:44  scott
%
% Revision 1.16  2004/05/09 22:49:45  scott
%
% Revision 1.15  2004/05/09 18:18:36  scott
%
% Revision 1.14  2003/12/15 23:28:34  arno
%
% Revision 1.13  2003/12/11 17:51:11  arno
%
% Revision 1.12  2003/10/23 15:48:45  arno
%
% Revision 1.11  2003/10/19 17:14:15  scott
%
% Revision 1.10  2003/10/03 18:21:25  arno
%
% Revision 1.9  2003/09/19 01:42:56  arno
%
% Revision 1.8  2003/09/18 23:43:50  arno
%
% Revision 1.7  2003/08/19 18:56:14  scott
%
% Revision 1.6  2003/08/07 18:33:15  arno
%
% Revision 1.5  2003/08/07 18:25:27  arno
%
% Revision 1.4  2003/05/23 15:31:53  arno
%
% Revision 1.3  2003/01/15 22:08:21  arno
%
% Revision 1.2  2002/10/23 18:09:54  arno
%
% Revision 1.1  2002/04/05 17:36:45  jorn
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [weights, bias, signs, lrates, y] = runica(x, ...
    p1,v1,p2,v2,p3,v3,p4,v4,p5,v5,p6,v6,p7,v7,p8,v8,p9,v9,p10,v10, ...
    p11,v11,p12,v12,p13,v13,p14,v14,p15,v15);

[chans frames] = size(x); % determine the data size
urchans = chans;  % remember original # of data channels 
datalength = frames;
%
%%%%%%%%%%%%%%%%%%%%%%%% Declare defaults used below %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
MAX_WEIGHT           = 1e8;     % Weights larger than this have blown up
DEFAULT_STOP         = 1e-6;    % Stop training if weight changes below this
DEFAULT_ANNEALDEG    = 60;      % When angle change reaches this value,
DEFAULT_ANNEALSTEP   = 0.90;    % anneal by multiplying lrate by this
DEFAULT_EXTANNEAL    = 0.98;    % or this if extended-ICA
DEFAULT_MAXSTEPS     = 512;     % Stop training after this many steps 
DEFAULT_MOMENTUM     = 0.0;     % Default momentum weight

DEFAULT_BLOWUP       = 1e9;     % Learning rate has 'blown up'
DEFAULT_BLOWUP_FAC   = 0.8;     % When lrate 'blows up,' anneal by this factor
DEFAULT_RESTART_FAC  = 0.9;     % If weights blowup, restart with lrate
                                % lower by this factor
                                
MIN_LRATE            = 1e-6;    % If weight blowups make lrate < this, quit
MAX_LRATE            = 0.1;     % Guard against uselessly high learning rate

DEFAULT_LRATE        = 0.00065/log(chans); 
                                % Heuristic default - may need adjustment!
                                    
DEFAULT_BLOCK        = ceil(min(5*log(frames),0.3*frames)); 
                                % Heuristic default - may need adjustment!
% Extended-ICA option:
DEFAULT_EXTENDED     = 0;       % Default off
DEFAULT_EXTBLOCKS    = 1;       % Number of blocks per kurtosis calculation
DEFAULT_NSUB         = 1;       % Initial default # of assumed sub-Gaussians
                                % for extended-ICA
                                
DEFAULT_EXTMOMENTUM  = 0.5;     % Momentum term for extended-ICA kurtosis
MAX_KURTSIZE         = 6000;    % Max points to use in kurtosis calculation
MIN_KURTSIZE         = 2000;    % Minimum good kurtosis size (flag warning)
SIGNCOUNT_THRESHOLD  = 25;      % Raise extblocks when sign vector unchanged
                                % after this many steps
                                
SIGNCOUNT_STEP       = 2;       % Extblocks increment factor 

DEFAULT_SPHEREFLAG   = 'none';  % I = starting weight matrix  & no sphering
DEFAULT_PCAFLAG      = 'off';   % Don't use PCA reduction
DEFAULT_POSACTFLAG   = 'off';   % Don't use posact()
DEFAULT_VERBOSE      = 1;       % Write ascii info to calling screen
DEFAULT_BIASFLAG     = 1;       % Default to using bias in the ICA update rule
%                                 
%%%%%%%%%%%%%%%%%%%%%%% Set up keyword default values %%%%%%%%%%%%%%%%%%%%%%%%%%
%
epochs = 1;							 % Do not care how many epochs in data

pcaflag    = DEFAULT_PCAFLAG;
sphering   = DEFAULT_SPHEREFLAG;     % Default flags
posactflag = DEFAULT_POSACTFLAG;
verbose    = DEFAULT_VERBOSE;

block      = DEFAULT_BLOCK;          % Heuristic default - may need adjustment!
lrate      = DEFAULT_LRATE;
annealdeg  = DEFAULT_ANNEALDEG;

annealstep = 0;                      % Defaults declared below
nochange   = NaN;
momentum   = DEFAULT_MOMENTUM;
maxsteps   = DEFAULT_MAXSTEPS;

weights    = 0;                      % Defaults defined below
ncomps     = chans;
biasflag   = DEFAULT_BIASFLAG;

extended   = DEFAULT_EXTENDED;
extblocks  = DEFAULT_EXTBLOCKS;
kurtsize   = MAX_KURTSIZE;

signsbias   = 0.02;                   % Bias towards super-Gaussian components
extmomentum = DEFAULT_EXTMOMENTUM;    % Exp. average the kurtosis estimates
nsub        = DEFAULT_NSUB;
wts_blowup  = 0;                      % Flag =1 when weights too large
wts_passed  = 0;                      % Flag weights passed as argument
%
%%%%%%%%%%%%%% Collect keywords and values from argument list %%%%%%%%%%%%%%%%%%
%
if (nargin > 1 & rem(nargin,2) == 0)
    fprintf('runica(): Even number of input arguments???')
    return
end
   
for i = 3:2:nargin % for each Keyword
    
    Keyword = eval(['p',int2str((i-3)/2 +1)]);
    Value = eval(['v',int2str((i-3)/2 +1)]);
    if ~isstr(Keyword)
        fprintf('runica(): Keywords must be strings')
        return
    end
    Keyword = lower(Keyword); % convert upper or mixed case to lower

    if strcmp(Keyword,'weights') | strcmp(Keyword,'weight')
        if isstr(Value)
            fprintf(...
                'runica(): Weights value must be a weight matrix or sphere')
            return
        else
            weights = Value;
            wts_passed =1;
        end
    elseif strcmp(Keyword,'ncomps')
        if isstr(Value)
            fprintf('runica(): Ncomps value must be an integer')
            return
        end
        if ncomps < urchans & ncomps ~= Value
            fprintf('runica(): Use either PCA or ICA dimension reduction');
            return
        end
        ncomps = Value;
        if ~ncomps,
            ncomps = chans;
        end
    elseif strcmp(Keyword,'pca') 
        if ncomps < urchans & ncomps ~= Value
            fprintf('runica(): Use either PCA or ICA dimension reduction');
            return
        end
        if isstr(Value)
            fprintf(...
                'runica(): Pca value should be the number of principal components to retain')
            return
        end
        pcaflag = 'on';
        ncomps = Value;
        if ncomps > chans | ncomps < 1,
            fprintf('runica(): Pca value must be in range [1,%d]\n',chans)
            return
        end
        chans = ncomps;
    elseif strcmp(Keyword,'posact') 
        if ~isstr(Value)
            fprintf('runica(): Posact value must be on or off')
            return
        else 
            Value = lower(Value);
            if ~strcmp(Value,'on') & ~strcmp(Value,'off'),
                fprintf('runica(): Posact value must be on or off')
                return
            end
            posactflag = Value;
        end
    elseif strcmp(Keyword,'lrate')
        if isstr(Value)
            fprintf('runica(): Lrate value must be a number')
            return
        end
        lrate = Value;
        if lrate > MAX_LRATE | lrate <0,
            fprintf('runica(): Lrate value is out of bounds'); 
            return
        end
        if ~lrate,
            lrate = DEFAULT_LRATE;
        end
    elseif strcmp(Keyword,'block') | strcmp(Keyword,'blocksize')
        if isstr(Value)
            fprintf('runica(): Block size value must be a number')
            return
        end
        block = floor(Value);
        if ~block,
            block = DEFAULT_BLOCK; 
        end
    elseif strcmp(Keyword,'stop') | strcmp(Keyword,'nochange') ...
                | strcmp(Keyword,'stopping')
        if isstr(Value)
            fprintf('runica(): Stop wchange value must be a number')
            return
        end
        nochange = Value;
    elseif strcmp(Keyword,'maxsteps') | strcmp(Keyword,'steps')
        if isstr(Value)
            fprintf('runica(): Maxsteps value must be an integer')
            return
        end
        maxsteps = Value;
        if ~maxsteps,
            maxsteps   = DEFAULT_MAXSTEPS;
        end
        if maxsteps < 0
            fprintf('runica(): Maxsteps value (%d) must be a positive integer',maxsteps)
            return
        end
    elseif strcmp(Keyword,'anneal') | strcmp(Keyword,'annealstep')
        if isstr(Value)
            fprintf('runica(): Anneal step value (%2.4f) must be a number (0,1)',Value)
            return
        end
        annealstep = Value;
        if annealstep <= 0 | annealstep > 1,
            fprintf('runica(): Anneal step value (%2.4f) must be (0,1]',annealstep)
            return
        end
    elseif strcmp(Keyword,'annealdeg') | strcmp(Keyword,'degrees')
        if isstr(Value)
            fprintf('runica(): Annealdeg value must be a number')
            return
        end
        annealdeg = Value;
        if ~annealdeg,
            annealdeg = DEFAULT_ANNEALDEG;
        elseif annealdeg > 180 | annealdeg < 0
            fprintf('runica(): Annealdeg (%3.1f) is out of bounds [0,180]',annealdeg);
            return
        end
    elseif strcmp(Keyword,'momentum')
        if isstr(Value)
            fprintf('runica(): Momentum value must be a number')
            return
        end
        momentum = Value;
        if momentum > 1.0 | momentum < 0
            fprintf('runica(): Momentum value is out of bounds [0,1]')
            return
        end
    elseif strcmp(Keyword,'sphering') | strcmp(Keyword,'sphereing') ...
                | strcmp(Keyword,'sphere')
        if ~isstr(Value)
            fprintf('runica(): Sphering value must be on, off, or none')
            return
        else 
            Value = lower(Value);
            if ~strcmp(Value,'on') & ~strcmp(Value,'off') & ~strcmp(Value,'none'),
                fprintf('runica(): Sphering value must be on or off')
                return
            end
            sphering = Value;
        end
    elseif strcmp(Keyword,'bias')
        if ~isstr(Value)
            fprintf('runica(): Bias value must be on or off')
            return
        else 
            Value = lower(Value);
            if strcmp(Value,'on') 
                biasflag = 1;
            elseif strcmp(Value,'off'),
                biasflag = 0;
            else
                fprintf('runica(): Bias value must be on or off')
                return
            end
        end
    elseif strcmp(Keyword,'extended') | strcmp(Keyword,'extend')
        if isstr(Value)
            fprintf('runica(): Extended value must be an integer (+/-)')
            return
        else
            extended = 1;           % turn on extended-ICA
            extblocks = fix(Value); % number of blocks per kurt() compute
            if extblocks < 0
                nsub = -1*fix(extblocks);   % fix this many sub-Gauss comps
            elseif ~extblocks,
                extended = 0;               % turn extended-ICA off
            elseif kurtsize > frames,       % length of kurtosis calculation
                kurtsize = frames;
                if kurtsize < MIN_KURTSIZE
                    fprintf(...
                        'runica() Warning: kurtosis values inexact for << %d points.\n', ...
                         MIN_KURTSIZE);
                end
            end
        end
    elseif strcmp(Keyword,'verbose') 
        if ~isstr(Value)
            fprintf('runica(): Verbose flag value must be on or off')
            return
        elseif strcmp(Value,'on'),
            verbose = 1; 
        elseif strcmp(Value,'off'),
            verbose = 0; 
        else
            fprintf('runica(): Verbose flag value must be on or off')
            return
        end
    else
        fprintf('runica(): Unknown flag')
        return
    end
end
%
%%%%%%%%%%%%%%%%%%%%%%%% Initialize weights, etc. %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if ~annealstep,
    if ~extended,
        annealstep = DEFAULT_ANNEALSTEP;    % defaults defined above
    else
        annealstep = DEFAULT_EXTANNEAL;     % defaults defined above
    end
end % else use annealstep from commandline

if ~annealdeg, 
    annealdeg  = DEFAULT_ANNEALDEG - momentum*90; % heuristic
    if annealdeg < 0,
        annealdeg = 0;
    end
end

if ncomps >  chans | ncomps < 1
    fprintf('runica(): Number of components must be 1 to %d.\n',chans);
    return
end

if weights ~= 0, % initialize weights
    % starting weights are being passed to runica() from the commandline
    if verbose,
        fprintf('Using starting weight matrix named in argument list ...\n')
    end
    if  chans > ncomps & weights ~=0,
        [r, c] = size(weights);
        if r ~= ncomps | c ~= chans,
            fprintf(...
                'runica(): Weight matrix must have %d rows, %d columns.\n', ...
                    chans,ncomps);
            return;
        end
    end
end;   
%
%%%%%%%%%%%%%%%%%%%%% Check keyword values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if frames < chans,
    fprintf('runica(): Data length (%d) < data channels (%d)!\n',frames,chans)
    return
elseif block < 2,
    fprintf('runica(): Block size %d too small!\n',block)
    return
elseif block > frames, 
    fprintf('runica(): Block size exceeds data length!\n');
    return
elseif floor(epochs) ~= epochs,
    fprintf('runica(): Data length is not a multiple of the epoch length!\n');
    return
elseif nsub > ncomps
    fprintf('runica(): There can be at most %d sub-Gaussian components!\n',ncomps);
    return
end;
% 
% adjust nochange if necessary
%
if isnan(nochange) 
    if ncomps > 32
        nochange = 1E-7;
        nochangeupdated = 1; % for fprinting purposes
    else
        nochangeupdated = 1; % for fprinting purposes
        nochange = DEFAULT_STOP;
    end;
else 
    nochangeupdated = 0;
end;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Process the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if verbose,
    fprintf('\nInput data size [%d,%d] = %d channels, %d frames.\n', ...
        chans,frames,chans,frames);
    if strcmp(pcaflag,'on')
        fprintf('After PCA dimension reduction,\n  finding ');
    else
        fprintf('Finding ');
    end
    if ~extended
        fprintf('%d ICA components using logistic ICA.\n',ncomps);
    else % if extended
        fprintf('%d ICA components using extended ICA.\n',ncomps);
        if extblocks > 0
            fprintf(...
                'Kurtosis will be calculated initially every %d blocks using %d data points.\n',...
                    extblocks, kurtsize);
        else
            fprintf(...
                'Kurtosis will not be calculated. Exactly %d sub-Gaussian components assumed.\n',...
                    nsub);
        end
    end
    fprintf('Decomposing %d frames per ICA weight ((%d)^2 = %d weights, %d frames).\n', ...
        floor(frames/ncomps.^2), ncomps, ncomps .^ 2, frames);
    fprintf('Initial learning rate will be %g, block size %d.\n', lrate,block);
    if momentum > 0,
        fprintf('Momentum will be %g.\n',momentum);
    end
    fprintf('Learning rate will be multiplied by %g whenever angledelta >= %g deg.\n', ...
        annealstep, annealdeg);
    if nochangeupdated 
        fprintf('More than 32 channels: default stopping weight change 1E-7\n');
    end;
    fprintf('Training will end when wchange < %g or after %d steps.\n', ...
        nochange, maxsteps);
    if biasflag,
        fprintf('Online bias adjustment will be used.\n');
    else
        fprintf('Online bias adjustment will not be used.\n');
    end
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if verbose,
    fprintf('Final training data range: %g to %g\n', min(min(x)),max(max(x)));
end
%
%%%%%%%%%%%%%%%%%%% Perform PCA reduction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
%%%%%%%%%%%%%%%%%%% Perform specgram transformation %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
%%%%%%%%%%%%%%%%%%% Perform sphering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
sphere = eye(chans);
if ~weights
    if verbose,
        fprintf('Starting weights are the identity matrix ...\n');
    end
    weights = eye(ncomps,chans);
else
    if verbose,
        fprintf('Using starting weights named on commandline ...\n');
    end
end
%
%%%%%%%%%%%%%%%%%%%%%%%% Initialize ICA training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
lastt = fix((datalength/block-1)*block+1);
BI = block*eye(ncomps,ncomps);
delta = zeros(1,chans*ncomps);
changes = [];
degconst = 180./pi;
startweights = weights;
prevweights = startweights;
oldweights = startweights;
prevwtchange = zeros(chans,ncomps);
oldwtchange = zeros(chans,ncomps);
lrates = zeros(1,maxsteps); 
onesrow = ones(1,block); 
bias = zeros(ncomps,1);
signs = ones(1,ncomps);    % initialize signs to nsub -1, rest +1
for k = 1:nsub
    signs(k) = -1;
end
if extended & extblocks < 0 & verbose,
    fprintf('Fixed extended-ICA sign assignments:  ');
    for k = 1:ncomps
        fprintf('%d ',signs(k));	
    end;
    fprintf('\n');
end
signs = diag(signs); % make a diagonal matrix
oldsigns = zeros(size(signs));
signcount = 0;              % counter for same-signs
signcounts = [];
urextblocks = extblocks;    % original value, for resets
old_kk = zeros(1,ncomps);   % for kurtosis momemtum
%
%%%%%%%% ICA training loop using the logistic sigmoid %%%%%%%%%%%%%%%%%%%%%%%%%%
%
if verbose,
    fprintf('Beginning ICA training ...');
    if extended,
        fprintf(' First training step may be slow ...\n');
    else
        fprintf('\n');
    end
end
  
step = 0;
laststep = 0; 
blockno = 1;  % running block counter for kurtosis interrupts

rand('state',sum(100*clock));  % set the random number generator state to
                               % a position dependent on the system clock
                               
while step < maxsteps, %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    permute = randperm(datalength); % shuffle data order at each step

    for t = 1:block:lastt, %%%%%%%%% ICA Training Block %%%%%%%%%%%%%%%%%%%%%%%%
        
        if biasflag                                                   
            u = weights*x(:,permute(t:t+block-1)) + bias*onesrow;      
        else                                                             
            u = weights*x(:,permute(t:t+block-1));                      
        end   
        
        if ~extended
            %%%%%%%%%%%%%%%%%%% Logistic ICA weight update %%%%%%%%%%%%%%%%%%%%%
            y = 1 ./ (1+exp(-u));                                              %
            weights = weights + lrate*(BI+(1-2*y)*u')*weights;                 %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        else % Tanh extended-ICA weight update
            %%%%%%%%%%%%%%%%%%%% Extended-ICA weight update %%%%%%%%%%%%%%%%%%%%
             y = tanh(u);                                                      %
             weights = weights + lrate*(BI-signs*y*u'-u*u')*weights;           %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        
        if biasflag 
            if ~extended
                %%%%%%%%%%%%%%%%%%%%%%%% Logistic ICA bias %%%%%%%%%%%%%%%%%%%%%
                bias = bias + lrate*sum((1-2*y)')'; % for logistic nonlin.     %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            else % extended
                %%%%%%%%%%%%%%%%%%% Extended-ICA bias %%%%%%%%%%%%%%%%%%%%%%%%%%
                bias = bias + lrate*sum((-2*y)')';  % for tanh() nonlin.       %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end                                    
        end

        if momentum > 0 %%%%%%%%% Add momentum %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            weights = weights + momentum*prevwtchange;                
            prevwtchange = weights - prevweights;                      
            prevweights = weights;                                  
        end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if max(max(abs(weights))) > MAX_WEIGHT
            wts_blowup = 1;
            change = nochange;
        end
        
        if extended & ~wts_blowup
            %
            %%%%%%%%%%% Extended-ICA kurtosis estimation %%%%%%%%%%%%%%%%%%%%%%%
            %
            if extblocks > 0 & rem(blockno,extblocks) == 0, 
                % recompute signs vector using kurtosis
                if kurtsize < frames % 12-22-99 rand() size by M. Spratling
                    rp = fix(rand(1,kurtsize)*datalength); % pick random subset
                    % Accout for the possibility of a 0 generation by rand
                    ou = find(rp == 0);
                    while ~isempty(ou) % 1-11-00 by J. Foucher
                        rp(ou) = fix(rand(1,length(ou))*datalength);
                        ou = find(rp == 0);
                    end
                    partact = weights*x(:,rp(1:kurtsize));
                else % for small data sets,
                    partact = weights*x; % use whole data
                end
                m2 = mean(partact'.^2).^2; 
                m4 = mean(partact'.^4);
                kk = (m4./m2)-3.0; % kurtosis estimates
                if extmomentum
                    kk = extmomentum*old_kk + (1.0-extmomentum)*kk; % momentum
                    old_kk = kk;
                end
                signs = diag(sign(kk+signsbias)); % pick component signs
                if signs == oldsigns,
                    signcount = signcount+1;
                else
                    signcount = 0;
                end
                oldsigns = signs;
                signcounts = [signcounts signcount];
                if signcount >= SIGNCOUNT_THRESHOLD,
                    extblocks = fix(extblocks * SIGNCOUNT_STEP); % make kurt() estimation
                    signcount = 0;                               % less frequent if sign
                end                                              % is not changing
            end % extblocks > 0 & . . .
        end % if extended %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        blockno = blockno + 1;
        if wts_blowup
            break
        end
        
    end % training block %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if ~wts_blowup
        oldwtchange = weights - oldweights;
        step = step + 1; 
        %
        %%%%%%% Compute and print weight and update angle changes %%%%%%%%%%%%%%
        %
        lrates(1,step) = lrate;
        angledelta = 0.0;
        delta = reshape(oldwtchange,1,chans*ncomps);
        change = delta*delta'; 
    end
    %
    %%%%%%%%%%%%%%%%%%%%%% Restart if weights blow up %%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    if wts_blowup | isnan(change) | isinf(change), % if weights blow up,
        fprintf('');
        step = 0;                           % start again
        change = nochange;
        wts_blowup = 0;                     % re-initialize variables
        blockno = 1;
        lrate = lrate*DEFAULT_RESTART_FAC;  % with lower learning rate
        weights = startweights;             % and original weight matrix
        oldweights = startweights;            
        change = nochange;
        oldwtchange = zeros(chans,ncomps);
        delta = zeros(1,chans*ncomps);
        olddelta = delta;
        extblocks = urextblocks;
        prevweights = startweights;
        prevwtchange = zeros(chans,ncomps);
        lrates = zeros(1,maxsteps);
        bias = zeros(ncomps,1);
        if extended
            signs = ones(1,ncomps);         % initialize to nsub -1, rest +1
            for k = 1:nsub
                signs(k) = -1;
            end
            signs = diag(signs); % make a diagonal matrix
            oldsigns = zeros(size(signs));;
        end
        if lrate > MIN_LRATE
            r = rank(x);
            if r < ncomps
                fprintf('Data has rank %d. Cannot compute %d components.\n', r, ncomps);
                return
            else
                fprintf('Lowering learning rate to %g and starting again.\n',lrate);
            end
        else
            fprintf('runica(): QUITTING - weight matrix may not be invertible!\n');
            return;
        end
    else % if weights in bounds 
        %
        %%%%%%%%%%%%% Print weight update information %%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if step > 2 
            angledelta = acos((delta*olddelta')/sqrt(change*oldchange));
        end
        if verbose,
            places = -floor(log10(nochange));
            if step > 2, 
                if ~extended,
                    ps = sprintf('step %d - lrate %5f, wchange %%%d.%df, angledelta %4.1f deg\n', ...
                        step, lrate, places + 1, places, degconst*angledelta);
                else
                    ps = sprintf('step %d - lrate %5f, wchange %%%d.%df, angledelta %4.1f deg, %d subgauss\n',...
                        step, lrate, degconst*angledelta, places + 1, places, (ncomps-sum(diag(signs)))/2);
                end
            elseif ~extended
                ps = sprintf('step %d - lrate %5f, wchange %%%d.%df\n',...
                    step, lrate, places + 1, places);
            else
                ps = sprintf('step %d - lrate %5f, wchange %%%d.%df, %d subgauss\n',...
                    step, lrate, places + 1, places, (ncomps-sum(diag(signs)))/2);
            end % step > 2
            fprintf('step %d - lrate %5f, wchange %8.8f, angledelta %4.1f deg\n', ...
                step, lrate, change, degconst*angledelta);
        end; % if verbose
        %
        %%%%%%%%%%%%%%%%%%%% Save current values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        changes = [changes change];
        oldweights = weights;
        %
        %%%%%%%%%%%%%%%%%%%% Anneal learning rate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if degconst*angledelta > annealdeg,  
            lrate = lrate*annealstep;       % anneal learning rate
            olddelta =  delta;              % accumulate angledelta until
            oldchange = change;             %  annealdeg is reached
        elseif step == 1                    % on first step only
            olddelta = delta;               % initialize 
            oldchange = change;               
        end
        %
        %%%%%%%%%%%%%%%%%%%% Apply stopping rule %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        if step > 2 & change < nochange,      % apply stopping rule
            laststep = step;            
            step = maxsteps;                  % stop when weights stabilize
        elseif change > DEFAULT_BLOWUP,       % if weights blow up,
            lrate = lrate*DEFAULT_BLOWUP_FAC; % keep trying 
        end;                                  % with a smaller learning rate
        
    end; % end if weights in bounds

end; % end training %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~laststep
    laststep = step;
end;

%
%%%%%%%%%%%%%% Orient components towards max positive activation %%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
%%%%%%%%%%%%%%%%%% If pcaflag, compose PCA and ICA matrices %%%%%%%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
%%%%%%%% Sort components in descending order of max projected variance %%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
%%%%%%%%%%%%%%%%%%%%%%%%%%% Find mean variances %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
%%%%%%%%%%%%%%%%%%%%%% Sort components by mean variance %%%%%%%%%%%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
% 
%%%%%%%%%%%%%%%%%%%%%%%%% Filter data using final weights %%%%%%%%%%%%%%%%%%%%%%
%
% //////////////////////////////////////////////////////////////////////////////
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargout == 3
    signs = diag(signs);            % vectorize the signs matrix
end
if nargout == 4
    lrates = lrates(1,1:laststep);  % truncate lrate history vector
end
%
%%%%%%%%%%%%%%%%%%%%% return nonlinearly-transformed data  %%%%%%%%%%%%%%%%%%%%%
%
if nargout == 5
    u = weights*x + bias*ones(1,frames);      
    y = zeros(size(u));
    for c = 1:chans
        for f = 1:frames
            y(c,f) = 1/(1+exp(-u(c,f)));
        end
    end
end
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%