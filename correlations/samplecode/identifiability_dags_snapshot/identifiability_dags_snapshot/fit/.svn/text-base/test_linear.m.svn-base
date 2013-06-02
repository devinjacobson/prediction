function result = test_linear(Xtest, model, pars)
% function result = test_linear(Xtest, model, pars)
%
% Evaluates a linear model 
% 
% INPUT:
%   model
%     .lincoefs     linear coefficients of the model (dx1)
%     .offset       real number that is added (1x1)
%   pars      leave empty      
%
% MODEL: Y = X * model.lincoefs + model.offset 
%
%
% OUTPUT:
%   result    structure with the result of the evaluation
%     .Ytest         fitted outputs for test inputs according to the learned model
%
% Copyright (c) 2011-2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
%               2011-2011  Jonas Peters [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.


  % check argument sizes
  if (size(Xtest,2)~=size(model.lincoefs,1))
    error('Xtest should be Nxd and model.lincoefs dx1');
  end

  result.Ytest = Xtest * model.lincoefs - ones(size(Xtest,1),1)*model.offset;
return
