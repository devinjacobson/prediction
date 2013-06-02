function result = train_template(X, Y, pars)
% function result = train_template(X, Y, pars)
%
% Template for writing train_* functions that perform some regression method.
% Its sole purpose is to define a common interface for the various train_* functions;
% it does not in itself perform any useful function.
%
% See also: test_template, train_*, test_*
%
% INPUT:
%   X         Nxd matrix of training inputs (N data points, d dimensions)
%   Y         Nx1 matrix of training outputs (N data points)
%   pars      structure containing parameters of the regression method
%
% OUTPUT:
%   result    structure with the result of the regression
%             required fields:
%               .model        learned model (e.g., weight vector)
%               .Yfit         fitted outputs for training inputs according to the learned model
%               .eps          noise values (e.g., residuals in the additive noise case)
%             optional fields:
%               .loss         loss function of trained model
%               .dloss        gradient of loss function of trained model
%               .ddloss       Hessian of loss function of trained model
%               .Yvar         variance of training outputs according to the learned model
%               ...           ...
%
% Copyright (c) 2011-2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
%               2011-2011  Jonas Peters [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  help('train_template');

return
