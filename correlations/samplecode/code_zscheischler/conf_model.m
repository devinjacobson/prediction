function [X Y] = conf_model(n, nsamples,cx,cy)
% Confounde model
% X=AZ+E, Y=BZ+F (X,Y,Z variables, E,F noise variables, A,B matrices)
% fitting a model from X to Y should reveal dependences between \Sigma_X
% and the noise variable

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

% define Z, A, B, E, F
if nargin==2
    cx = 1;
    cy = 1;
end

% Z
U = unimat(n);
lam = abs(randn(n,1));
Cz = U*diag(lam)*U';
Bz = abs(sqrtm(Cz));
Z = Bz * (randn(n,nsamples));

% A
A = unimat(n) * diag(randn(n,1)) * unimat(n) ;

% B
B = unimat(n) * diag(randn(n,1)) * unimat(n) ;

% E 
U = unimat(n);
lam = abs(randn(n,1));
Ce = U * diag(lam) *U';
Be = abs(sqrtm(Ce));
E = sqrt(cx) * Be * randn(n,nsamples);

% F 
U = unimat(n);
lam = abs(randn(n,1));
Ce = U * diag(lam) *U';
Bf = abs(sqrtm(Ce));
F = sqrt(cy) * Bf * randn(n,nsamples);

% X
X = A * Z + 0*E;

% Y
Y = B * Z + 0*F;
