function [K,C,dK] = kernel(X,type,pars)
% function [K,C,dK] = kernel(X,type,pars)
%
% Constructs kernel matrix, its Cholesky decomposition and the matrices 
% of partial derivatives.
%
% Input:
%   X      Nxd matrix (N data points, dimensionality d)
%   type   One of the kernel types from the table below
%   pars   Parameters for that kernel
%
% Output:
%   K      kernel matrix
%   C      Cholesky decomposition (K = C' * C)
%   dK     partial derivatives dK{k}(i,j) = d k(xi,xj) / d xi_k)
%
% Kernel types and parameters:
%
%   type:         pars:
%   -----------------------------------------
%   rbf           jitter, sigma_in, sigma_out
%   gauss         bandwidth
%   rbfsimple     sigma
% 
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  N = size(X,1);
  d = size(X,2);

  % Calculate K(i,j) = norm(X(i,:) - X(j,:),2)
  if d > 1
    K = sum((repmat(reshape(X,N,1,d),[1,N,1]) - repmat(reshape(X,1,N,d),[N,1,1])).^2,3);
    
    if nargout >= 3
      error('Not implemented yet');
      dK = cell(d,1);
      for k=1:d
        dK{k} = 2 * (repmat(X,1,N) - repmat(X',N,1));
      end
    end
  else
    K = (repmat(X,1,N) - repmat(X',N,1)).^2;
    if nargout >= 3
      dK = 2 * (repmat(X,1,N) - repmat(X',N,1));
    end
  end

%  this alternative code is slower, except if d is large
%
%  K = zeros(N,N);
%  dK = zeros(N,N);
%  % Calculate K(i,j) = norm(X(i,:) - X(j,:),2)
%  if size(X,2) > 1
%    for i = 1:N
%      for j = i+1:N
%        K(i,j) = sum((X(i,:)-X(j,:)).^2);
%        K(j,i) = K(i,j);
%      end
%    end
%  else
%    for i = 1:N
%      for j = i+1:N
%        K(i,j) = (X(i)-X(j))^2;
%        K(j,i) = K(i,j);
%        dK(i,j) = 2 * (X(i) - X(j));
%        dK(i,j) = -dK(j,i);
%      end
%    end
%  end

  if( strcmp(lower(type),'rbf') )
    K = pars.sigma_out^2 * exp(-K / (2.0 * pars.sigma_in^2));
    if pars.jitter ~= 0.0;
      for i=1:N
        K(i,i) = K(i,i) + pars.jitter * pars.sigma_out^2;
      end
    end
    if nargout >= 3
      dK = (dK .* K) / (-2.0 * pars.sigma_in^2);
    end
  elseif( strcmp(lower(type),'gauss') )
    K = (1.0 / sqrt(2.0 * pi) / pars.bandwidth) * exp(-K / (2.0 * pars.bandwidth^2));
    if nargout >= 3
      dK = (dK .* K) / (-2.0 * pars.bandwidth^2);
    end
  elseif( strcmp(lower(type),'rbfsimple') )
    K = exp(-K / (2.0 * pars.sigma^2));
    if nargout >= 3
      dK = (dK .* K) / (-2.0 * pars.sigma^2);
    end
  else
    error('Unknown kernel type');
  end

  if nargout >= 2
    % Calculate Cholesky decomposition
    C = chol(K);  % K = C' * C
  end
return
