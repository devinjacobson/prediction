function [W] = fpica(x, Sph, approach, numOfIC, g, finetune, a1, a2, myy, stabilization, epsilon, ...
                     maxNumIterations, maxFinetune, initState, seed, sampleSize, ...
                     verbose, vectorSize, numSamples);
        
% Perform independent component analysis using Hyvarinen's fixed point
% algorithm. Outputs an estimate of the unmixing matrix W.
%
%
% x                                     :Whitened data as row vectors
% Sph                                   :Sphering (whitening) matrix
% approach      [ 'symm'  | 'defl' ]    :Approach used (deflation or symmetric)
% numOfIC       [   0 - Dim of x   ]    :# of independent components estimated
%
% g             [ 'pow3' | 'tanh' | 'gauss' | 'skew' ]  :Nonlinearity used
%
% finetune      [same as g + 'off']     :Nonlinearity used in finetuning.
% a1                                    :Parameter for tuning 'tanh'
% a2                                    :Parameter for tuning 'gauss'
% mu (myy)                              :Step size in stabilized algorithm
% stabilization [ 'on' | 'off' ]        :Automatically on if mu < 1
% epsilon                               :Stopping criterion
% maxNumIterations                      :Max number of iterations 
% maxFinetune                           :Max number of iterations for finetuning
% initState     [ 'rand' | 'seed' ]     :Initial seed or random initial state
% seed                                  :Initial seed for A if initState = 'seed'
% sampleSize    [ 0 - 1 ]               :% of samples used in one iteration
% verbose       [ 'on' | 'off' ]        :Report progress in text format
% vectorSize & numSamples               :Dimensions of the data matrix x
%
%
%   @(#)$Id: fpica.m,v 1.6 2004/07/27 11:37:17 jarmo Exp $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the data

if ~isreal(x)
    error('Input has an imaginary part.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for verbose

switch lower(verbose)
    case 'on'
        b_verbose = 1;
    case 'off'
        b_verbose = 0;
    otherwise
        error(sprintf('Illegal value [ %s ] for parameter: ''verbose''\n', verbose));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for approach

switch lower(approach)
    case 'symm'
        approachMode = 1;
    case 'defl'
        approachMode = 2;
    otherwise
        error(sprintf('Illegal value [ %s ] for parameter: ''approach''\n', approach));
end
if b_verbose, fprintf('Used approach [ %s ].\n', approach); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for numOfIC

if vectorSize < numOfIC
    error('Must have numOfIC <= Dimension!');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the sampleSize

if sampleSize > 1
    sampleSize = 1;
    if b_verbose
        fprintf('Warning: Setting ''sampleSize'' to 1.\n');
    end  
elseif sampleSize < 1
    if (sampleSize * numSamples) < 1000
        sampleSize = min(1000/numSamples, 1);
        if b_verbose
            fprintf('Warning: Setting ''sampleSize'' to %0.3f (%d samples).\n', ...
                sampleSize, floor(sampleSize * numSamples));
        end  
    end
end
if b_verbose
  if  b_verbose & (sampleSize < 1)
    fprintf('Using about %0.0f%% of the samples in random order in every step.\n', ...
        sampleSize*100); 
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for nonlinearity.

switch lower(g)
    case 'pow3'
        gOrig = 10;
    case 'tanh'
        gOrig = 20;
    case 'gauss'
        gOrig = 30;
    case 'skew'
        gOrig = 40;
    otherwise
        error(sprintf('Illegal value [ %s ] for parameter: ''g''\n', g));
end
if sampleSize ~= 1
    gOrig = gOrig + 2;
end
if myy ~= 1
    gOrig = gOrig + 1;
end

if b_verbose,
    fprintf('Used nonlinearity [ %s ].\n', g);
end

finetuningEnabled = 1;
switch lower(finetune)
    case 'pow3'
        gFine = 10 + 1;
    case 'tanh'
        gFine = 20 + 1;
    case {'gaus', 'gauss'}
        gFine = 30 + 1;
    case 'skew'
        gFine = 40 + 1;
    case 'off'
        if myy ~= 1
            gFine = gOrig;
        else 
            gFine = gOrig + 1;
        end
        finetuningEnabled = 0;
    otherwise
        error(sprintf('Illegal value [ %s ] for parameter: ''finetune''\n', ...
            finetune));
end

if b_verbose & finetuningEnabled
    fprintf('Finetuning enabled (nonlinearity: [ %s ]).\n', finetune);
end

switch lower(stabilization)
    case 'on'
        stabilizationEnabled = 1;
    case 'off'
        if myy ~= 1
            stabilizationEnabled = 1;
        else
            stabilizationEnabled = 0;
        end
    otherwise
        error(sprintf('Illegal value [ %s ] for parameter: ''stabilization''\n', ...
            stabilization)); 
end

if b_verbose & stabilizationEnabled
    fprintf('Using stabilized algorithm.\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Some other parameters

myyOrig = myy;

% When we start fine-tuning we'll set myy = myyK * myy

myyK = 0.01;

% How many times do we try for convergence until we give up.

failureLimit = 5;

usedNlinearity = gOrig;
notFine = 1;
stroke = 0;
long = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking the value for initial state.

switch lower(initState)
    case 'rand'
        initialStateMode = 0;
    case 'seed'
        if size(seed, 1) ~= vectorSize
            initialStateMode = 0;
            if b_verbose
                fprintf('Warning: size of initial seed is incorrect. Using random seed.\n');
            end
        else
            initialStateMode = 1;
            if size(seed, 2) < numOfIC
                if b_verbose
                    fprintf('Warning: initial seed for first %d components. Using random seed for others.\n', ...
                        size(seed, 2)); 
                end
                seed(:, size(seed, 2) + 1:numOfIC) = rand(vectorSize, numOfIC - size(seed,2)) - 0.5;
            elseif size(seed, 2) > numOfIC
                seed = seed(:, 1:numOfIC);
                fprintf('Warning: Initial seed too large. The excess column are dropped.\n');
            end
        if b_verbose, fprintf('Using initial seed.\n'); end
        end
    otherwise
        error(sprintf('Illegal value [ %s ] for parameter: ''initState''\n', initState));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if b_verbose, fprintf('Starting ICA calculation...\n'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYMMETRIC APPROACH

if approachMode == 1,

    if initialStateMode == 0
        % Take random orthonormal initial vectors.
        B = orth(rand(vectorSize, numOfIC) - .5);
    elseif initialStateMode == 1
        % Use the given initial vector as the initial state
        B = Sph * seed;
    end
  
    BOld = zeros(size(B));
    BOld2 = zeros(size(B));
  
    % This is the actual fixed-point iteration loop.
    for round = 1:maxNumIterations + 1,
        
        if round == maxNumIterations + 1,
            fprintf('No convergence after %d steps\n', maxNumIterations);
            fprintf('Note that the plots are probably wrong.\n');
            if ~isempty(B)
                W = B';
            else
                W = [];
            end
            return;
        end
    
        % Symmetric orthogonalization.
        B = B * real(inv(B' * B)^(1/2));
    
        % Test for termination condition. Note that we consider opposite
        % directions here as well.
        minAbsCos = min(abs(diag(B' * BOld)));
        minAbsCos2 = min(abs(diag(B' * BOld2)));
    
        if (1 - minAbsCos < epsilon)
            if finetuningEnabled & notFine
                if b_verbose, fprintf('Initial convergence, fine-tuning: \n'); end;
                notFine = 0;
                usedNlinearity = gFine;
                myy = myyK * myyOrig;
                BOld = zeros(size(B));
                BOld2 = zeros(size(B));
            else
                if b_verbose, fprintf('Convergence after %d steps\n', round); end
                break;
            end
        elseif stabilizationEnabled
            if (~stroke) & (1 - minAbsCos2 < epsilon)
                if b_verbose, fprintf('Stroke!\n'); end;
                stroke = myy;
                myy = .5*myy;
                if mod(usedNlinearity,2) == 0
                    usedNlinearity = usedNlinearity + 1;
                end
            elseif stroke
                myy = stroke;
                stroke = 0;
                if (myy == 1) & (mod(usedNlinearity,2) ~= 0)
                    usedNlinearity = usedNlinearity - 1;
                end
            elseif (~long) & (round > maxNumIterations/2)
                if b_verbose, fprintf('Taking long (reducing step size)\n'); end;
                long = 1;
                myy = .5*myy;
                if mod(usedNlinearity,2) == 0
                    usedNlinearity = usedNlinearity + 1;
                end
            end
        end
    
        BOld2 = BOld;
        BOld = B;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Show the progress ...
        
        if b_verbose
            if round == 1
                fprintf('Step no. %d\n', round);
            else
                fprintf('Step no. %d, change in value of estimate: %.3g \n', round, 1 - minAbsCos);
            end
        end
    
        switch usedNlinearity
            % pow3
            case 10
                B = (x * (( x' * B) .^ 3)) / numSamples - 3 * B;
            case 11
                % optimoitu - epsilonin kokoisia eroja
                % tämä on optimoitu koodi, katso vanha koodi esim.
                % aikaisemmista versioista kuten 2.0 beta3
                Y = x' * B;
                Gpow3 = Y .^ 3;
                Beta = sum(Y .* Gpow3);
                D = diag(1 ./ (Beta - 3 * numSamples));
                B = B + myy * B * (Y' * Gpow3 - diag(Beta)) * D;
            case 12
                Xsub = x(:, getSamples(numSamples, sampleSize));
                B = (Xsub * (( Xsub' * B) .^ 3)) / size(Xsub,2) - 3 * B;
            case 13
                % Optimoitu
                Ysub = x(:, getSamples(numSamples, sampleSize))' * B;
                Gpow3 = Ysub .^ 3;
                Beta = sum(Ysub .* Gpow3);
                D = diag(1 ./ (Beta - 3 * size(Ysub', 2)));
                B = B + myy * B * (Ysub' * Gpow3 - diag(Beta)) * D;
                % tanh
            case 20
                hypTan = tanh(a1 * x' * B);
                B = x * hypTan / numSamples - ...
                    ones(size(B,1),1) * sum(1 - hypTan .^ 2) .* B / numSamples * a1;
            case 21
                % optimoitu - epsilonin kokoisia 
                Y = x' * B;
                hypTan = tanh(a1 * Y);
                Beta = sum(Y .* hypTan);
                D = diag(1 ./ (Beta - a1 * sum(1 - hypTan .^ 2)));
                B = B + myy * B * (Y' * hypTan - diag(Beta)) * D;
            case 22
                Xsub = x(:, getSamples(numSamples, sampleSize));
                hypTan = tanh(a1 * Xsub' * B);
                B = Xsub * hypTan / size(Xsub, 2) - ...
                    ones(size(B,1),1) * sum(1 - hypTan .^ 2) .* B / size(Xsub, 2) * a1;
            case 23
                % Optimoitu
                Y = x(:, getSamples(numSamples, sampleSize))' * B;
                hypTan = tanh(a1 * Y);
                Beta = sum(Y .* hypTan);
                D = diag(1 ./ (Beta - a1 * sum(1 - hypTan .^ 2)));
                B = B + myy * B * (Y' * hypTan - diag(Beta)) * D;      
            % gauss
            case 30
                U = x' * B;
                Usquared = U .^ 2;
                ex = exp(-a2 * Usquared / 2);
                gauss =  U .* ex;
                dGauss = (1 - a2 * Usquared) .*ex;
                B = x * gauss / numSamples - ...
                    ones(size(B,1),1) * sum(dGauss) .* B / numSamples ;
            case 31
                % optimoitu
                Y = x' * B;
                ex = exp(-a2 * (Y .^ 2) / 2);
                gauss = Y .* ex;
                Beta = sum(Y .* gauss);
                D = diag(1 ./ (Beta - sum((1 - a2 * (Y .^ 2)) .* ex)));
                B = B + myy * B * (Y' * gauss - diag(Beta)) * D;
            case 32
                Xsub = x(:, getSamples(numSamples, sampleSize));
                U = Xsub' * B;
                Usquared = U .^ 2;
                ex = exp(-a2 * Usquared / 2);
                gauss =  U .* ex;
                dGauss = (1 - a2 * Usquared) .*ex;
                B = Xsub * gauss / size(Xsub,2) - ...
                    ones(size(B,1),1) * sum(dGauss) .* B / size(Xsub,2) ;
            case 33
                % Optimoitu
                Y = x(:, getSamples(numSamples, sampleSize))' * B;
                ex = exp(-a2 * (Y .^ 2) / 2);
                gauss = Y .* ex;
                Beta = sum(Y .* gauss);
                D = diag(1 ./ (Beta - sum((1 - a2 * (Y .^ 2)) .* ex)));
                B = B + myy * B * (Y' * gauss - diag(Beta)) * D;
            % skew
            case 40
                B = (x * ((x' * B) .^ 2)) / numSamples;
            case 41
                % Optimoitu
                Y = x' * B;
                Gskew = Y .^ 2;
                Beta = sum(Y .* Gskew);
                D = diag(1 ./ (Beta));
                B = B + myy * B * (Y' * Gskew - diag(Beta)) * D;
            case 42
                Xsub = x(:, getSamples(numSamples, sampleSize));
                B = (Xsub * ((Xsub' * B) .^ 2)) / size(Xsub,2);
            case 43
                % Uusi optimoitu
                Y = x(:, getSamples(numSamples, sampleSize))' * B;
                Gskew = Y .^ 2;
                Beta = sum(Y .* Gskew);
                D = diag(1 ./ (Beta));
                B = B + myy * B * (Y' * Gskew - diag(Beta)) * D;
            otherwise
                error('Code for desired nonlinearity not found!');
        end
    
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate ICA filters.

    W = B';

end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DEFLATION APPROACH

if approachMode == 2
  
    B = zeros(vectorSize);
  
    % The search for a basis vector is repeated numOfIC times.
    
    round = 1;
    numFailures = 0;
  
    while round <= numOfIC,
        
        myy = myyOrig;
        usedNlinearity = gOrig;
        stroke = 0;
        notFine = 1;
        long = 0;
        endFinetuning = 0;
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Show the progress...
    
        if b_verbose, fprintf('IC %d ', round); end
    
        % Take a random initial vector of length 1 and orthogonalize it
        % with respect to the other vectors.
    
        if initialStateMode == 0
            w = rand(vectorSize, 1) - .5;
        elseif initialStateMode == 1
            w = Sph * seed(:,round);
        end
    
        w = w - B * B' * w;
        w = w / norm(w);
    
        wOld = zeros(size(w));
        wOld2 = zeros(size(w));
    
        % This is the actual fixed-point iteration loop.
        % for i = 1 : maxNumIterations + 1
    
        i = 1;
        gabba = 1;
    
        while i <= maxNumIterations + gabba
      
            % Project the vector into the space orthogonal to the space
            % spanned by the earlier found basis vectors. Note that we can do
            % the projection with matrix B, since the zero entries do not
            % contribute to the projection.
        
            w = w - B * B' * w;
            w = w / norm(w);
      
            if notFine
                if i == maxNumIterations + 1
                    if b_verbose
                        fprintf('\nComponent number %d did not converge in %d iterations.\n', round, maxNumIterations);
                    end
                    round = round - 1;
                    numFailures = numFailures + 1;
                    if numFailures > failureLimit
                        if b_verbose
                            fprintf('Too many failures to converge (%d). Giving up.\n', numFailures);
                        end
                        if round == 0
                            W = [];
                        end
                        return;
                    end
                    % numFailures > failurelimit
                    break;
                end
            else
                if i >= endFinetuning
                    wOld = w; % So the algorithm will stop on the next test ...
                end
            end
      
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Show the progress ...
      
            if b_verbose, fprintf('.'); end;
      
            % Test for termination condition. Note that the algorithm has
            % converged if the direction of w and wOld is the same, this
            % is why we test the two cases.
        
            if norm(w - wOld) < epsilon | norm(w + wOld) < epsilon
                
                if finetuningEnabled & notFine
                    if b_verbose, fprintf('Initial convergence, fine-tuning: '); end;
                    notFine = 0;
                    gabba = maxFinetune;
                    wOld = zeros(size(w));
                    wOld2 = zeros(size(w));
                    usedNlinearity = gFine;
                    myy = myyK * myyOrig;
                    endFinetuning = maxFinetune + i;
                else
                    numFailures = 0;
                    % Save the vector
                    B(:, round) = w;
                    % Calculate ICA filter.
                    W(round,:) = w';
	  
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Show the progress...
                
                    if b_verbose, fprintf('computed ( %d steps ) \n', i); end
	  
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % IC ready - next...
                
                     break;
                end
            elseif stabilizationEnabled
                if (~stroke) & (norm(w - wOld2) < epsilon | norm(w + wOld2) < epsilon)
                    stroke = myy;
                    if b_verbose, fprintf('Stroke!'); end;
                    myy = .5*myy;
                    if mod(usedNlinearity,2) == 0
                        usedNlinearity = usedNlinearity + 1;
                    end
                elseif stroke
                    myy = stroke;
                    stroke = 0;
                    if (myy == 1) & (mod(usedNlinearity,2) ~= 0)
                        usedNlinearity = usedNlinearity - 1;
                    end
                elseif (notFine) & (~long) & (i > maxNumIterations / 2)
                    if b_verbose, fprintf('Taking long (reducing step size) '); end;
                    long = 1;
                    myy = .5*myy;
                    if mod(usedNlinearity,2) == 0
                        usedNlinearity = usedNlinearity + 1;
                    end
                end
            end
      
            wOld2 = wOld;
            wOld = w; 
      
            switch usedNlinearity
                % pow3
                case 10
                    w = (x * ((x' * w) .^ 3)) / numSamples - 3 * w;
                case 11
                    EXGpow3 = (x * ((x' * w) .^ 3)) / numSamples;
                    Beta = w' * EXGpow3;
                    w = w - myy * (EXGpow3 - Beta * w) / (3 - Beta);
                case 12
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    w = (Xsub * ((Xsub' * w) .^ 3)) / size(Xsub, 2) - 3 * w;
                case 13
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    EXGpow3 = (Xsub * ((Xsub' * w) .^ 3)) / size(Xsub, 2);
                    Beta = w' * EXGpow3;
                    w = w - myy * (EXGpow3 - Beta * w) / (3 - Beta);
                % tanh
                case 20
                    hypTan = tanh(a1 * x' * w);
                    w = (x * hypTan - a1 * sum(1 - hypTan .^ 2)' * w) / numSamples;
                case 21
                    hypTan = tanh(a1 * x' * w);
                    Beta = w' * x * hypTan;
                    w = w - myy * ((x * hypTan - Beta * w) / ...
                        (a1 * sum((1-hypTan .^2)') - Beta));
                case 22
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    hypTan = tanh(a1 * Xsub' * w);
                    w = (Xsub * hypTan - a1 * sum(1 - hypTan .^ 2)' * w) / size(Xsub, 2);
                case 23
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    hypTan = tanh(a1 * Xsub' * w);
                    Beta = w' * Xsub * hypTan;
                    w = w - myy * ((Xsub * hypTan - Beta * w) / ...
                        (a1 * sum((1-hypTan .^2)') - Beta));
                % gauss
                case 30
                    % This has been split for performance reasons.
                    u = x' * w;
                    u2 = u .^ 2;
                    ex = exp(-a2 * u2/2);
                    gauss =  u .* ex;
                    dGauss = (1 - a2 * u2) .*ex;
                    w = (x * gauss - sum(dGauss)' * w) / numSamples;
                case 31
                    u = x' * w;
                    u2 = u .^ 2;
                    ex = exp(-a2 * u2/2);
                    gauss = u .* ex;
                    dGauss = (1 - a2 * u2) .*ex;
                    Beta = w' * x * gauss;
                    w = w - myy * ((x * gauss - Beta * w) / (sum(dGauss)' - Beta));
                case 32
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    u = Xsub' * w;
                    u2 = u .^ 2;
                    ex = exp(-a2 * u2/2);
                    gauss = u .* ex;
                    dGauss = (1 - a2 * u2) .* ex;
                    w = (Xsub * gauss - sum(dGauss)' * w) / size(Xsub, 2);
                case 33
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    u = Xsub' * w;
                    u2 = u .^ 2;
                    ex = exp(-a2 * u2/2);
                    gauss = u .* ex;
                    dGauss = (1 - a2 * u2) .*ex;
                    Beta = w' * Xsub * gauss;
                    w = w - myy * ((Xsub * gauss - Beta * w) / (sum(dGauss)' - Beta));
                % skew
                case 40
                    w = (x * ((x' * w) .^ 2)) / numSamples;
                case 41
                    EXGskew = (x * ((x' * w) .^ 2)) / numSamples;
                    Beta = w' * EXGskew;
                    w = w - myy * (EXGskew - Beta*w)/(-Beta);
                case 42
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    w = (Xsub * ((Xsub' * w) .^ 2)) / size(Xsub, 2);
                case 43
                    Xsub = x(:,getSamples(numSamples, sampleSize));
                    EXGskew = (Xsub * ((Xsub' * w) .^ 2)) / size(Xsub, 2);
                    Beta = w' * EXGskew;
                    w = w - myy * (EXGskew - Beta*w)/(-Beta);
                otherwise
                    error('Code for desired nonlinearity not found!');
            end
      
            % Normalize the new w.
      
            w = w / norm(w);
            i = i + 1;
            
        end
    
        round = round + 1;
    
    end
  
    if b_verbose, fprintf('Done.\n'); end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In the end let's check the data for some security

if ~isreal(W)
    if b_verbose, fprintf('Warning: removing the imaginary part from the result.\n'); end
    W = real(W);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculates tanh simplier and faster than Matlab tanh.

function y = tanh(x)
y = 1 - 2 ./ (exp(2 * x) + 1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Get the data.

function Samples = getSamples(max, percentage)
Samples = find(rand(1, max) < percentage);
