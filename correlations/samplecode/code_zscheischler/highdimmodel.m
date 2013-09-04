function [Xdata, Ydata, A, Cx, Ce, Edata] = highdimmodel(m,n,nsamples,noiselevel)

%--- Generate a random model ---
% Y=AX+E with certain noiselevel
% uses unimat(n) (creates a uniformly distributed random rotation matrix)

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

% Input covariance matrix Cx is randomly selected
U = unimat(n);
lam = abs(randn(n,1));
Cx = U*diag(lam)*U';
Bx = abs(sqrtm(Cx));


% Random transformation matrix A 
if m<n
    Atmp = diag(randn(m,1)); 
    Atmp(:,m+1:n) = zeros(m,n-m);
    A = unimat(m) * Atmp * unimat(n);
elseif m>n
    Atmp = diag(randn(n,1));
    Atmp(n+1:m,:) = zeros(m-n,n);
    A = unimat(m) * Atmp * unimat(n);
else
    A = unimat(m) * diag(randn(m,1)) * unimat(n) ;
end

% Noise covariance matrix Ce is randomly generated
T = unimat(m);
lam = abs(randn(m,1));
Ce = T * diag(lam) *T';
Be = abs(sqrtm(Ce));

%--- Generate the sample data ---

% The cause X and the noise E are gaussian with the above selected
% covariance matrices
Xdata = Bx * (randn(n,nsamples));
Edata = noiselevel * Be * randn(m,nsamples);

% The effect Y is given by the linear transform of X with additive
% independent noise
Ydata = (A * Xdata) + Edata; 

    
