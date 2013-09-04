function [yi f_conf] = ReconstructBinaryConf(X, Y)
% function [yi f_conf] = ReconstructBinaryConf(X, Y)
%
% Reconstructs binary confounder Z for the setting X<-Z->Y.
%
% INPUT:
%   X               Nx1 (N data points)
%   Y               Nx1 (N data points)
%
% OUTPUT:
%   yi              vector 1x1000 with equally spaced y values
%   f               matrix (2x1000) with the density values evaluated at the points in
%                   yi for Z=0 and Z=1
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

[yi f] = ksdensity_cond(X, Y);
MinRatioMat = EstimatePairwisePurity(X, Y);

%select pair closest to purity
min_criterion = 100;
for i=1:size(MinRatioMat,1)
    for j=(i+1):size(MinRatioMat,1)
        r0 = MinRatioMat(i,j);
        r1 = MinRatioMat(j,i);
        l0 = 1/(1-r0);
        l1 = r1/(r1-1);
        criterion = l0-l1;
        if(min_criterion>criterion)
            min_criterion=criterion;
            lambda0 = l0;
            lambda1 = l1;
            idx_x0 = i;
            idx_x1 = j;
        end
    end
end

%reconstruction
f_conf(1,:) = lambda0*f(idx_x0,:)+(1-lambda0)*f(idx_x1,:);
f_conf(2,:) = lambda1*f(idx_x0,:)+(1-lambda1)*f(idx_x1,:);
