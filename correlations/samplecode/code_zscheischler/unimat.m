function Onew = unimat(n)
% subgroup algorithm for generating uniformly 
% distributed orthogonal matrices
% according to P.Diaconis and M.Shahshahani 1987

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

theta = 2*pi*rand();
r = randperm(2);
if (r(1) == 1)  
    b = -1;
else
    b = 1;
end

Oold = [cos(theta) sin(theta); -b*sin(theta) b*cos(theta)];
for i=3:n
    z = randn(1,i);
    v = z / norm(z);
    e1 = zeros(1,i);
    e1(1) = 1;
    x = (e1 - v) / norm(e1-v);
    H = eye(i) - 2*(x'*x);
    Gamma = zeros(i);
    Gamma(1,1) = 1;
    Gamma(2:i,2:i) = Oold;
    Onew = H * Gamma;
    Oold = Onew;
end
if n==2 
    Onew = Oold;
end
if n==1 
    Onew = 1;
end

