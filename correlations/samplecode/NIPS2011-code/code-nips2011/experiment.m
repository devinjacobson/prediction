function experiment(n,N,outputdir)
% function experiment(n,N,outputdir)
%
% Generates synthetic data from one out of 10 predefined models
% and learns a bivariate cyclic additive noise model from these
% data. Output is written to outputdir.
%
% INPUT:
%   n           scenario (n=1,..,10)
%   N           number of data points
%   outputdir   directory where output should be written
%
% Copyright (c) 2011  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

  % for reproducibility, init random number generator
  s = RandStream.create('mt19937ar','seed',12345);
  RandStream.setDefaultStream(s);

  % number of iterations of fixed point equations
  iters = 10000;

  % jitter (rho in the paper)
  % default jitter for initial optimization
  jit = 1e-4;
  % jitter for final optimization 
  % (should be the same for similar experiments to ensure 
  % that the marginal likelihoods can be compared)
  finaljit = 1e-4; 

  % loss function (although loss2 should have better numerical
  % properties, it seems as if loss1 behaves better...?)
  lossf = 'loss1';

  % which scenario?
  if n == 1
    fX = @(Y) 0;
    fY = @(X) 0.9 * tanh(2*X);
    sX = 1;
    sY = 0.5;
  elseif n == 2 % oops
    fX = @(Y) 0;
    fY = @(X) 0.9 * tanh(2*X);
    sX = 1;
    sY = 0.5;
    % changing the jitter can take us to another optimum...
    jit = 1e-6;
  elseif n == 3
    fX = @(Y) 0.9 * tanh(2*Y);
    fY = @(X) 0.0;
    sX = 0.5;
    sY = 1;
  elseif n == 4
    fX = @(Y) 0.9 * tanh(Y);
    fY = @(X) 0.9 * cos(X);
    sX = 1;
    sY = 1;
  elseif n == 5 % oops
    fX = @(Y) 0.9 * tanh(Y);
    fY = @(X) 0.9 * cos(X);
    sX = 1;
    sY = 1;
    % using another implementation of the loss function can take us to another optimum...
    lossf = 'loss2';
  elseif n == 6
    fX = @(Y) 0.8 * Y;
    fY = @(X) -0.4 * X;
    sX = 0.5;
    sY = 1;
  elseif n == 7
    fX = @(Y) 0.4 * Y;
    fY = @(X) -0.4 * X;
    sX = 1;
    sY = 1;
  elseif n == 8
    fX = @(Y) 0.9 * tanh(Y);
    fY = @(X) 0.9 * sin(X);
    sX = 1;
    sY = 1;
  elseif n == 9
    fX = @(Y) 0.9 * tanh(Y);
    fY = @(X) 0.9 * tanh(X);
    sX = 1;
    sY = 1;
  elseif n == 10
    fX = @(Y) 0.4 * tanh(2*Y);
    fY = @(X) 0.4 * tanh(2*X);
    sX = 1;
    sY = 1;
  end

  % generate data
  EX = randn(N,1) * sX;
  EY = randn(N,1) * sY;
  %EX = 6*(rand(N,1)-0.5) * sX;
  %EY = 6*(rand(N,1)-0.5) * sY;
  [X,Y] = generate_data(N,fX,fY,EX,EY,iters);

  % set learning parameters
  pars = struct;
  pars.jitter = jit;
  pars.fix_log_lambda_X = []; % optimize
  pars.fix_log_lambda_Y = []; % optimize
  pars.fix_log_kappa_X = 2;   % start with fixed length scale (otherwise it might go to zero)
  pars.fix_log_kappa_Y = 2;   % start with fixed length scale (otherwise it might go to zero)
  pars.fix_log_sigma_X = [];  % optimize
  pars.fix_log_sigma_Y = [];  % optimize
  % check gradient, if N is small enough
  if N <= 100
    check_grad(@(hatXY) feval(lossf,hatXY,X,Y,pars), randn(2*N+6,1), 1e-7)
  end
  % random initialization
  hatXY0 = randn(2*N+6,1);
  % but set log length scales to 0
  hatXY0(2*N+1:2*N+6,1) = 0;
  % optimize!
  hatXY = minimize_lbfgsb(hatXY0,lossf,-1000,X,Y,pars);
  % we are going to do another optimization,
  % this time also optimizing the kappa's
  % reset optimized log length scales to 0
  hatXY(2*N+1:2*N+6,1) = 0;
  % now, all parameters will be optimized
  pars.fix_log_kappa_X = [];  % optimize
  pars.fix_log_kappa_Y = [];  % optimize
  % optimize again!
  hatXY = minimize_lbfgsb(hatXY,lossf,-1000,X,Y,pars);
  % in the final optimization, we set the jitter to finaljit
  % to get marginal likelihoods that can be better compared
  pars.jitter = finaljit;
  % optimize again!
  hatXY = minimize_lbfgsb(hatXY,lossf,-1000,X,Y,pars);
  % get optimized length scales
  lambda_X = exp(hatXY(2*N+1,1));
  lambda_Y = exp(hatXY(2*N+2,1));
  kappa_X = exp(hatXY(2*N+3,1));
  kappa_Y = exp(hatXY(2*N+4,1));
  sigma_X = exp(hatXY(2*N+5,1));
  sigma_Y = exp(hatXY(2*N+6,1));

  % evaluate loss function and derivative at the optimum
  [L,dL] = feval(lossf,hatXY,X,Y,pars);
  % check gradient at optimum if N is small enough
  if N <= 100
    check_grad(@(hatXY) feval(lossf,hatXY,X,Y,pars), hatXY, 1e-7)
  end

  % get hatX,hatY and alphaX,alphaY from solution
  % and encode the solution as input for both loss1 and loss2
  [KX,dKX] = gausskernel(Y,kappa_X,lambda_X);
  [KY,dKY] = gausskernel(X,kappa_Y,lambda_Y);
  KXjit = KX + eye(N) * pars.jitter;
  KYjit = KY + eye(N) * pars.jitter;
  if strcmp(lossf,'loss1')
    hatX = hatXY(1:N,1);
    hatY = hatXY(N+1:2*N,1);
    alphaX = KXjit \ hatX;
    alphaY = KYjit \ hatY;
    solXY1 = hatXY; % solution in loss1 parameterization
    solXY2 = hatXY; % solution in loss2 parameterization
    solXY2(1:N,1) = alphaX;
    solXY2(N+1:2*N,1) = alphaY;
  else
    alphaX = hatXY(1:N,1);
    alphaY = hatXY(N+1:2*N,1);
    hatX = KXjit * alphaX;
    hatY = KYjit * alphaY;
    solXY1 = hatXY; % solution in loss1 parameterization
    solXY1(1:N,1) = hatX;
    solXY1(N+1:2*N,1) = hatY;
    solXY2 = hatXY; % solution in loss2 parameterization
  end
  % evaluate both loss functions and their gradients at the optimum
  % they should both have zero gradient and the loss functions should
  % be identical
  [L1,dL1] = feval('loss1',solXY1,X,Y,pars);
  [L2,dL2] = feval('loss2',solXY2,X,Y,pars);

  % calculate HSIC p-value for independence of estimated noises
  p = fasthsic(X-hatX,Y-hatY);

  % write results to text file
  fid = fopen(sprintf('%s/exp%d_%d.txt',outputdir,n,N),'w');
  fprintf(fid,'Optimized loss:           %e\n',L);
  fprintf(fid,'Optimized loss1:          %e\n',L1);
  fprintf(fid,'Optimized loss2:          %e\n',L2);
  fprintf(fid,'Norm gradient 1:          %e\n',norm(dL1));
  fprintf(fid,'Norm gradient 2:          %e\n',norm(dL2));
  fprintf(fid,'Optimized lambda_X:       %e\n',lambda_X);
  fprintf(fid,'Optimized lambda_Y:       %e\n',lambda_Y);
  fprintf(fid,'Optimized kappa_X:        %e\n',kappa_X);
  fprintf(fid,'Optimized kappa_Y:        %e\n',kappa_Y);
  fprintf(fid,'Optimized sigma_X:        %e\n',sigma_X);
  fprintf(fid,'Optimized sigma_Y:        %e\n',sigma_Y);
  fprintf(fid,'p-value for independence: %e\n',p);
  fclose(fid);

  % reconstruct data from fitted model
  % we use linear interpolation for simplicity 
  % (better would be to use the GP predictive distribution)
  hatfX = @(YY) interpolate(Y, hatX, YY);
  hatfY = @(XX) interpolate(X, hatY, XX);
  %EXrec = randn(N,1) * sigma_X;
  %EYrec = randn(N,1) * sigma_Y;
  EXrec = X - hatX;
  EYrec = Y - hatY;
  [Xrec,Yrec] = generate_data(N,hatfX,hatfY,EXrec,EYrec,iters);

  % generate plots
  figure;
  subplot(3,5,1);
  plot(X,Y,'.');
  xlabel('X');
  ylabel('Y');
  xlim([-4,4]);
  ylim([-4,4]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);
  title('Data');
  subplot(3,5,2);
  [dum,ind]=sort(X);
  plot(X(ind),fY(X(ind)),'b-',X(ind),hatY(ind),'r-');
  xlabel('X');
  ylabel('Y');
  xlim([-4,4]);
  ylim([-4,4]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);
  title('X -> f_Y(X)');
  subplot(3,5,3);
  [dum,ind]=sort(Y);
  plot(Y(ind),fX(Y(ind)),'b-',Y(ind),hatX(ind),'r-');
  xlabel('Y');
  ylabel('X');
  xlim([-4,4]);
  ylim([-4,4]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);
  title('Y -> f_X(Y)');
  subplot(3,5,4);
  plot(X-hatX,Y-hatY,'r.');
  xlabel('E_X');
  ylabel('E_Y');
  xlim([-4,4]);
  ylim([-4,4]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);
  title(sprintf('Estimated noise',p));
  subplot(3,5,5);
  plot(Xrec,Yrec,'r.');
  xlabel('X');
  ylabel('Y');
  xlim([-4,4]);
  ylim([-4,4]);
  set(gca,'XTick',[]);
  set(gca,'YTick',[]);
  title('Reconstructed data');
  print('-depsc2',sprintf('%s/exp%d_%d.eps',outputdir,n,N));

  % save results
  save(sprintf('%s/exp%d_%d.mat',outputdir,n,N));

end
