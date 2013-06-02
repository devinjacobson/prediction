function result = train_linear(X, Y, pars)
% function result = train_linear(X, Y, pars)
%
% Performs a linear regression from X to Y using the MatLab function REGRESS.
% Uses: Matlab Statistics Toolbox
%
% INPUT:
%   X         Nxd matrix of training inputs (N data points, d dimensions)
%   Y         Nx1 matrix of training outputs (N data points)
%   pars      structure containing parameters of the regression method
%
% OUTPUT:
%   result    structure with the result of the regression
%      .model        learned model (e.g., weight vector)
%      .Yfit         fitted outputs for training inputs according to the learned model
%      .eps          noise values (e.g., residuals in the additive noise case)
%
% Copyright (c) 2011-2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
%               2011-2011  Jonas Peters [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

if size(X,2)==0
    result.Yfit = zeros(size(Y,1),1);
    result.model.lincoefs = 0;
    result.eps = Y;
    return
end

if ~isfield(pars,'robust')
    pars.robust = 0;
end;

% check argument sizes
if (size(Y,2)~=1) || (size(X,1)~=size(Y,1))
    error('X should be Nxd and Y should be Nx1');
end

ss=size(X,1);

if pars.robust==0
    % perform regression
    mY = mean(Y);
    sdY = sqrt(var(Y));
    orY = Y;
    mX = mean(X); %1xd
    sdX = sqrt(var(X)); %1xd
    orX = X;

    Y = (Y-mY)/sdY;
    X = (X-ones(ss,1)*mX)./(ones(ss,1)*sdX);
    [lincoefs] = regress(Y,X);
    result.Yfit = X * lincoefs;
    result.model.lincoefs = (lincoefs./sdX') * sdY;
    result.model.offset = - mX * (lincoefs./sdX') * sdY + mY;
    result.eps = sdY * (Y - result.Yfit);
    display('with centering')
    % OR result.eps = orY - orX*result.model.lincoefs - ones(ss,1)*result.model.offset;
elseif pars.robust==1
    % perform robust regression
    [lincoefs] = robustfit(X,Y);
    result.Yfit = [ones(ss,1), X] * lincoefs;
    result.model.lincoefs = lincoefs(2:size(X,2));
    result.model.offset = lincoefs(1);
    result.eps = Y - result.Yfit;
    display('robust inference')
else
    % perform regression without centering
    Xp = [ones(ss,1), X];
    [lincoefs] = regress(Y,Xp);
    result.Yfit = Xp * lincoefs;
    result.model.lincoefs = lincoefs(2:size(X,2));
    result.model.offset = lincoefs(1);
    result.eps = Y - result.Yfit;
    display('without centering')
end
return
