function [X_causal X_noncausal Y] = GenerateSimulatedData() % for Fig.3
% function [X_causal X_noncausal Y] = GenerateSimulatedData()
%
% Generates the synthetic data used for Fig. 3 of the paper
%
% OUTPUT:
%   X_causal            Nx1 (N data points)
%   X_noncausal         Nx1 (N data points)
%   Y                   Nx1 (N data points)
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

SampleSize = 1000;
eps2(1) = 0.28;
eps2(2) = 0.42;
mu(1) = -0.65;
mu(2) = 0.65;

min_pointsNum_perClass = 5;

    
    
    % Generate Cause
    regenerate = 1;
    while (regenerate==1)    
        regenerate=0;  
        marginalP = rand(1);
        Z = rand(SampleSize, 1)>marginalP;

        if(length(find(Z==0))<min_pointsNum_perClass || length(find(Z==1))<min_pointsNum_perClass)
            fprintf('Regenerate Cause because one class contains less than %d points\n', min_pointsNum_perClass);
            regenerate = 1;
            %break;
        end
    end
    
    % Generate Effect
    w1 = randn(1);
    compIds = round(rand(SampleSize,1))+1;
    E_Y = [mu(compIds)]' + [eps2(compIds)]'.*randn(SampleSize,1);
    Y = w1*Z + E_Y;
    
    % Generate NonCause
    idx_z0 = find(Z==0);
    idx_z1 = find(Z==1);
    transitionP = [rand(1); rand(1)];
    [n,x_z0] = histc(rand(1, length(idx_z0)),[0 transitionP(1) 1]);
    [n,x_z1] = histc(rand(1, length(idx_z1)),[0 transitionP(2) 1]);
    X = zeros(SampleSize,1);
    X(idx_z0) = x_z0;
    X(idx_z1) = x_z1;
    
    
    X_causal = Z;
    X_noncausal = X;
      

