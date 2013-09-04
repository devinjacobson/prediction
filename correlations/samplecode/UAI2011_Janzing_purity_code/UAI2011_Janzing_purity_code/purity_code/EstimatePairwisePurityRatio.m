function  R = EstimatePairwisePurityRatio(X, Y) 
% function R = EstimatePairwisePurityRatio(X, Y)
%
% Estimates the purity ratio of P(Y|X): max_(x,x'){min_y(p(y|x)/p(y|x'))}
%
% INPUT:
%   X               Nx1 (N data points)
%   Y               Nx1 (N data points)
%
% OUTPUT:
%   R               negative logarithm of the purity ratio
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.


MinRatioMat = EstimatePairwisePurity(X, Y);
R = max(MinRatioMat(:));

R = -log(R);


