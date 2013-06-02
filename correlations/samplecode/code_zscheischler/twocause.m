function [delta1, delta2, A1, A2] = twocause(X,Y)
% Implementation of the trace method including the small sample case
%   Input
%       X,Y     Data matrices with [dim, samples]
%
%   Output
%       d1      Delta_{X \to Y}
%       d2      Delta_{Y \to X}
%   if |d1| < |d2| + \eps 
%	X --> Y 
%

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

% calculate covariance matrizes
Cx = cov(X');
Cy = cov(Y');
tmp = cov([X' Y']);
s1 = size(Cx);
s2 = size(Cy);
Cxy = tmp(1:s1,s1+1:end);
Cyx = Cxy';

% calculate pseudoinverses
pCx = pinv(Cx);
pCy = pinv(Cy);

% calculate estimators for A
A1 = Cyx*pCx;
A2 = Cxy*pCy;

% get rank
r1 = trace(Cx*pCx);
r2 = trace(Cy*pCy);

% calculate deltas
delta1 = log(trace(A1*Cx*A1')/s1(1)) - log(trace(A1*A1')/r1) - log(trace(Cx)/s1(1));
delta2 = log(trace(A2*Cy*A2')/s2(1)) - log(trace(A2*A2')/r2) - log(trace(Cy)/s2(1));

end
