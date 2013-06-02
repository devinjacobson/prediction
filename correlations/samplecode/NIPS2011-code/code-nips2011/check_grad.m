function check_grad (f, X, eps)
% function check_grad (f, X, eps)
%
% Checks the gradient by using a numerical approximation.
%
% It outputs both the gradient supplied by f itself and 
% the numerical approximation of the gradient, and the norm
% of the difference of the two.
%
% INPUT:
%   f         function that returns a function value and gradient
%             when invoked as "[f,df] = f(X)"
%   X         point at which to evaluate the gradient
%   eps       step size
%
% Copyright (c) 2011  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

  [f0, df0] = f(X);
  appdF = zeros(size(X));
  for i = 1:length(X)
    Xi = X;
    Xi(i) = X(i) - 0.5 * eps;
    fi1 = f(Xi);
    Xi(i) = X(i) + 0.5 * eps;
    fi2 = f(Xi);
    appdF(i) = (fi2 - fi1) / eps;
  end
  [appdF df0]
  norm(appdF - df0)

return
