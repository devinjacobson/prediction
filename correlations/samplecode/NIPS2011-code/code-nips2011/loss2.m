function [L,dL] = loss2(input,X,Y,pars)
% function [L,dL] = loss2(input,X,Y,pars)
%
% Evaluates loss function of bivariate cyclic additive noise model and its gradient
% with respect to (hyper)parameters.
%
% This implementation works in the "alphaX,alphaY" representation, avoiding illposed
% kernel inverses.
%
% INPUT:
%   input                (2*N+6)x1 matrix encoding the model parameters and hyperparameters
%                        input = [alphaX; alphaY; log_lambda_X; log_lambda_Y; 
%                                 log_kappa_X; log_kappa_Y; log_sigma_X; log_sigma_Y]
%   X                    Nx1 matrix with X component of the data
%   Y                    Nx1 matrix with Y component of the data
%   pars                 loss function properties
%     .jitter              jitter (rho in the paper)
%     .fix_alphaX          fix parameters alphaX to this value if nonempty
%     .fix_alphaY          fix parameters alphaY to this value if nonempty
%     .fix_log_lambda_X    fix hyperparameter log_lambda_X to this value if nonempty
%     .fix_log_lambda_Y    fix hyperparameter log_lambda_Y to this value if nonempty
%     .fix_log_kappa_X     fix hyperparameter log_kappa_X to this value if nonempty
%     .fix_log_kappa_Y     fix hyperparameter log_kappa_Y to this value if nonempty
%     .fix_log_sigma_X     fix hyperparameter log_sigma_X to this value if nonempty
%     .fix_log_sigma_Y     fix hyperparameter log_sigma_Y to this value if nonempty
%
% OUTPUT:
%   L         loss function
%   dL        partial derivatives dL / dinput
%
% Copyright (c) 2011  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

  % check input
  assert(size(X,2) == 1);
  assert(size(Y,2) == 1);
  assert(size(input,2) == 1);
  N = size(X,1);
  assert(size(Y,1) == N);
  assert(size(input,1) == 2 * N + 6);

  % verbosity
  verbose = 0;

  % set default properties
  if ~isfield(pars,'jitter')
    pars.jitter = 1e-4;
  end
  if ~isfield(pars,'fix_alphaX')
    pars.fix_alphaX = [];
  end
  if ~isfield(pars,'fix_alphaY')
    pars.fix_alphaY = [];
  end
  if ~isfield(pars,'fix_log_lambda_X')
    pars.fix_log_lambda_X = [];
  end
  if ~isfield(pars,'fix_log_lambda_Y')
    pars.fix_log_lambda_Y = [];
  end
  if ~isfield(pars,'fix_log_kappa_X')
    pars.fix_log_kappa_X = [];
  end
  if ~isfield(pars,'fix_log_kappa_Y')
    pars.fix_log_kappa_Y = [];
  end
  if ~isfield(pars,'fix_log_sigma_X')
    pars.fix_log_sigma_X = [];
  end
  if ~isfield(pars,'fix_log_sigma_Y')
    pars.fix_log_sigma_Y = [];
  end

  % decode input and set variables either to the value given by 
  % input, or to the fixed value given by pars.fix_...
  if isempty(pars.fix_alphaX)
    alphaX = input(1:N,1);
  else
    alphaX = pars.fix_alphaX;
  end
  if isempty(pars.fix_alphaY)
    alphaY = input(N+1:2*N,1);
  else
    alphaY = pars.fix_alphaY;
  end
  if isempty(pars.fix_log_lambda_X)
    lambda_X = exp(input(2*N+1,1));
  else
    lambda_X = exp(pars.fix_log_lambda_X);
  end
  if isempty(pars.fix_log_lambda_Y)
    lambda_Y = exp(input(2*N+2,1));
  else
    lambda_Y = exp(pars.fix_log_lambda_Y);
  end
  if isempty(pars.fix_log_kappa_X)
    kappa_X = exp(input(2*N+3,1));
  else
    kappa_X = exp(pars.fix_log_kappa_X);
  end
  if isempty(pars.fix_log_kappa_Y)
    kappa_Y = exp(input(2*N+4,1));
  else
    kappa_Y = exp(pars.fix_log_kappa_Y);
  end
  if isempty(pars.fix_log_sigma_X)
    sigma_X = exp(input(2*N+5,1));
  else
    sigma_X = exp(pars.fix_log_sigma_X);
  end
  if isempty(pars.fix_log_sigma_Y)
    sigma_Y = exp(input(2*N+6,1));
  else
    sigma_Y = exp(pars.fix_log_sigma_Y);
  end

  % if verbose, output hyperparameters
  if verbose
    fprintf('lambda_X: %e\n',lambda_X);
    fprintf('lambda_Y: %e\n',lambda_Y);
    fprintf('kappa_X:  %e\n',kappa_X);
    fprintf('kappa_Y:  %e\n',kappa_Y);
    fprintf('sigma_X:  %e\n',sigma_X);
    fprintf('sigma_Y:  %e\n',sigma_Y);
  end

  % calculate kernels, Cholesky decompositions, inverses
  [KX,dKX] = gausskernel(Y,kappa_X,lambda_X);
  [KY,dKY] = gausskernel(X,kappa_Y,lambda_Y);
  KXjit = KX + eye(N) * pars.jitter;
  KYjit = KY + eye(N) * pars.jitter;
  CX = chol(KXjit); % CX' * CX = KXjit
  CY = chol(KYjit); % CY' * CY = KYjit
  % iKX = CX \ (CX' \ eye(N)); % iKX = inv(KXjit)
  % iKY = CY \ (CY' \ eye(N)); % iKY = inv(KYjit)
  hatX = KXjit * alphaX;
  hatY = KYjit * alphaY;

  % if verbose, output some estimated function values
  % and corresponding alpha values
  if verbose
    m = min(N,10);
    fprintf('alphaX, alphaY:');
    [alphaX(1:m), alphaY(1:m)]
    fprintf('hatX, hatY:');
    [hatX(1:m), hatY(1:m)]
  end

  % calculate loss function
  L = 2 * N * log(2*pi);
  L = L + N * log(sigma_X);
  L = L + N * log(sigma_Y);
  if isempty(pars.fix_alphaX)
    L = L + sum(log(diag(CX)));
  end
  if isempty(pars.fix_alphaY)
    L = L + sum(log(diag(CY)));
  end
  L = L + norm(X - hatX,2)^2 / (2 * sigma_X^2);
  L = L + norm(Y - hatY,2)^2 / (2 * sigma_Y^2);
  L = L + 0.5 * hatX' * alphaX;
  L = L + 0.5 * hatY' * alphaY;
  dfX = dKX * alphaX;
  dfY = dKY * alphaY;
  L = L - sum(log(abs(dfX .* dfY - 1)));

  % calculate gradient with respect to hatX parameters
  if isempty(pars.fix_alphaX)
    dLX = KXjit * (hatX - X) / sigma_X^2;
    dLX = dLX + hatX;
    blaX = (dfY ./ (dfX .* dfY - 1));
    dLX = dLX + dKX * blaX;
  else
    dLX = zeros(N,1);
  end
  
  % calculate gradient with respect to hatY parameters
  if isempty(pars.fix_alphaY)
    dLY = KYjit * (hatY - Y) / sigma_Y^2;
    dLY = dLY + hatY;
    blaY = (dfX ./ (dfX .* dfY - 1));
    dLY = dLY + dKY * blaY;
  else
    dLY = zeros(N,1);
  end

  % calculate gradients with respect to lambda hyperparameters
  if isempty(pars.fix_alphaX)
    dKXdlambda = 2 * KX;
    ddfXdlambda = 2 * dKX;
    dLloglambda_X = 0.5 * trace((CX \ (CX' \ dKXdlambda))) - blaX' * ddfXdlambda * alphaX + alphaX' * dKXdlambda * (hatX - X + sigma_X^2/2 * alphaX) / sigma_X^2;
  else
    dLloglambda_X = 0;
  end
  if isempty(pars.fix_alphaY)
    dKYdlambda = 2 * KY;
    ddfYdlambda = 2 * dKY;
    dLloglambda_Y = 0.5 * trace((CY \ (CY' \ dKYdlambda))) - blaY' * ddfYdlambda * alphaY + alphaY' * dKYdlambda * (hatY - Y + sigma_Y^2/2 * alphaY) / sigma_Y^2;
  else
    dLloglambda_Y = 0;
  end

  % calculate gradients with respect to kappa hyperparameters
  if isempty(pars.fix_alphaX)
    diffX2 = (repmat(Y,1,N) - repmat(Y',N,1)).^2; % (y_i - y_j)^2
    dKXdkappa = KX .* diffX2 / kappa_X^2;
    ddfXdkappa = (dKX .* (diffX2 / kappa_X^2 - 2));
    dLlogkappa_X = 0.5 * trace((CX \ (CX' \ dKXdkappa))) - blaX' * ddfXdkappa * alphaX + alphaX' * dKXdkappa * (hatX - X + sigma_X^2/2 * alphaX) / sigma_X^2;
  else
    dLlogkappa_X = 0;
  end
  if isempty(pars.fix_alphaY)
    diffY2 = (repmat(X,1,N) - repmat(X',N,1)).^2; % (x_i - x_j)^2
    dKYdkappa = KY .* diffY2 / kappa_Y^2;
    ddfYdkappa = (dKY .* (diffY2 / kappa_Y^2 - 2));
    dLlogkappa_Y = 0.5 * trace((CY \ (CY' \ dKYdkappa))) - blaY' * ddfYdkappa * alphaY + alphaY' * dKYdkappa * (hatY - Y + sigma_Y^2/2 * alphaY) / sigma_Y^2;
  else
    dLlogkappa_Y = 0;
  end

  % calculate gradients with respect to sigma hyperparameters
  dLlogsigma_X = N - norm(X - hatX,2)^2 / (sigma_X^2);
  dLlogsigma_Y = N - norm(Y - hatY,2)^2 / (sigma_Y^2);
 
  % set some gradients to zero, if these hyperparameters are fixed
  if ~isempty(pars.fix_log_lambda_X)
    dLloglambda_X = 0.0;
  end
  if ~isempty(pars.fix_log_lambda_Y)
    dLloglambda_Y = 0.0;
  end
  if ~isempty(pars.fix_log_kappa_X)
    dLlogkappa_X = 0.0;
  end
  if ~isempty(pars.fix_log_kappa_Y)
    dLlogkappa_Y = 0.0;
  end
  if ~isempty(pars.fix_log_sigma_X)
    dLlogsigma_X = 0.0;
  end
  if ~isempty(pars.fix_log_sigma_Y)
    dLlogsigma_Y = 0.0;
  end

  % construct total gradient
  dL = [dLX; dLY; dLloglambda_X; dLloglambda_Y; dLlogkappa_X; dLlogkappa_Y; dLlogsigma_X; dLlogsigma_Y];
return
