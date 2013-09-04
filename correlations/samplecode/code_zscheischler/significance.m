function [pval1 pval2 v1 v2 d1 d2] = significance(X,Y,N)
% does a significance test on the trace method with input X and Y and N rotations
% here rows are dimensions and columns are samples

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

if nargin==2
    N = 500;
end

% calculate covariances
Cx = cov(X');
Cy = cov(Y');

% tracemethod which outputs deltas d1 and d2
[d1 d2, A1, A2] = twocause(X,Y);

% get rank
r1 = rank(Cx);
r2 = rank(Cy);

% get basis vectors 
[E1,S1] = svds(Cx,r1);
[E2,S2] = svds(Cy,r2);

A11=A1'*A1;
A22=A2'*A2; 

for i=1:N
    U1 = unimat(r1);
    U2 = unimat(r2);
    
    % do rotations on subspace end embed   
    Rot1 = E1*U1*S1*U1'*E1';
    Rot2 = E2*U2*S2*U2'*E2';
    v1(i) = (trace(A11*Rot1));
    v2(i) = (trace(A22*Rot2));
end

% get sample value
t1 = trace(A1'*A1*Cx);
t2 = trace(A2'*A2*Cy);

% count
pval1 = sum(v1>t1)/N;
pval2 = sum(v2>t2)/N;
