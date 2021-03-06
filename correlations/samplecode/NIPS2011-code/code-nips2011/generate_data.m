function [X,Y] = generate_data(N,fX,fY,EX,EY,iters)
% function [X,Y] = generate_data(N,fX,fY,EX,EY,iters)
%
% Generates N data points sampled from a bivariate cyclic additive noise model.
% The data is generated by iterating the following fixed point equations:
%
%   X = fX(Y) + EX
%   Y = fY(X) + EY
%
%  iters times, starting from standard-normally distributed X and Y.
%
% INPUT:
%   N         number of samples requested
%   fX        function mapping Y to X
%   fY        function mapping X to Y
%   EX        Nx1 matrix with sampled EX values
%   EY        Nx1 matrix with sampled EY values
%   iters     number of iterations of fixed point equations
%
% OUTPUT:
%   X         Nx1 matrix with sampled X values
%   Y         Nx1 matrix with sampled Y values
%
% Copyright (c) 2011  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

  X0 = randn(N,1);
  Y0 = randn(N,1);
  for i=1:iters
    X = fX(Y0) + EX;
    Y = fY(X0) + EY;
    X0 = X;
    Y0 = Y;
  end

return
