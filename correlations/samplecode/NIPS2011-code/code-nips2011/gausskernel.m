function [K,dK] = gausskernel(X,sigma_in,sigma_out)
% function [K,dK] = gausskernel(X,sigma_in,sigma_out)
%
% Constructs kernel matrix and the matrices of partial derivatives.
%
%   K = sigma_out^2 * exp(-(X(i) - X(j))^2 / (2.0 * sigma_in^2));
%
% INPUT:
%   X         Nxd matrix (N data points, dimensionality d)
%   sigma_in  input length scale
%   sigma_out output length scale
%
% OUTPUT:
%   K         kernel matrix
%   dK        partial derivatives dK{k}(i,j) = d k(xi,xj) / d xi_k)
%
% Copyright (c) 2011  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

  N = size(X,1);
  d = size(X,2);
  assert( d == 1);

  % Calculate K(i,j) = norm(X(i,:) - X(j,:),2)^2
  K = (repmat(X,1,N) - repmat(X',N,1)).^2;

  % Calculate kernel
  K = sigma_out^2 * exp(-K / (2.0 * sigma_in^2));

  if nargout >= 2
    dK = 2 * (repmat(X,1,N) - repmat(X',N,1));
    dK = (dK .* K) / (-2.0 * sigma_in^2);
  end
return
