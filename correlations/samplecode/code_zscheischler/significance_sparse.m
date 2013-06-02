function [pval1 pval2 v1 v2 t1 t2] = significance_sparse(X,Y,N)
% does a significance test on the trace method with input X and Y 

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

if nargin==2
    N = 500;
end

% calculate covariances
Cx = cov(double(X)');
Cy = cov(double(Y)');

% get estimated tranfer matrices with dim. red. method
A1 = two_scale_lars_alasso(X,Y);
A2 = two_scale_lars_alasso(Y,X);

% get ranks
r1 = size(A1,1); r2=r1;

for i=1:N
    U1 = unimat(r1);
    U2 = unimat(r2);

    % do rotations on subspace and embed 
    Rot1 = U1*Cx*U1';
    Rot2 = U2*Cy*U2';
    v1(i) = (trace(A1'*A1*Rot1));
    v2(i) = (trace(A2'*A2*Rot2));
end
% get sample values
t1 = trace(A1'*A1*Cx);
t2 = trace(A2'*A2*Cy);

% count
pval1 = sum(v1>t1)/N;
pval2 = sum(v2>t2)/N;

