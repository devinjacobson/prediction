function y = logdet(A)
% function y = logdet(A)
%
% Calculates log(det(A)) where A should be positive-definite
% using the Cholesky decomposition of A.
% This is faster and more stable than using log(det(A)).
%
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

try
  U = chol(A);
  y = 2*sum(log(diag(U)));
catch me
  y = nan;
end
