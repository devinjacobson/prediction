function result = test_discrete_anm(Xtest, model, pars)
% function result = test_discrete_anm(Xtest, model, pars)
%
% evaluates a discrete additive noise model (ANM) specified with model at Xtest.
%
% Uses:
%
% OUTPUT:
%          result    structure with the result of the regression
%              .Ytest            Nx1 matrix: expected outputs of the model,
%                            evaluated on test inputs
%
% INPUT:   X         Nxd matrix of test inputs (N data points, d dimensions)
%          model         contains the parameter of the fitted model, namely 
%	       .fct
%	       .X_values
%	       .dim_X
%	       .X_old
%	       .Y_values
%
%-please cite
% Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, 
% in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, 
% JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
% Copyright (c) 2010-2011  Jonas Peters [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.


fct=model.fct;
X_values=fct=model.X_values;
dim_X=fct=model.dim_X;
Y_values=fct=model.Y_values;

if dim_X~=size(Xtest,2);
    error('The discrete ANM was trained with data having a different dimension.');
end


X_new2=sum(X_old.*(ones(samplesize,1)*10.^(2*((dim_X-1):(-1):0))),2);

[tf, index] = ismember(X_new2, X_values);

result.Ytest=fct(index);


