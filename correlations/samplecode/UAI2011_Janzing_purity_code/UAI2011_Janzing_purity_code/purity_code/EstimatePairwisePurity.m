function  MinRatioMat = EstimatePairwisePurity(X, Y)
% function MinRatioMat = EstimatePairwisePurity(X, Y)
%
% Estimates the ratios min_y(p(y|x)/p(y|x')) for all pairs (x,x')
%
% INPUT:
%   X               Nx1 (N data points)
%   Y               Nx1 (N data points)
%
% OUTPUT:
%   MinRatioMat     MxM matrix (M #unique x values) containing the ratios for all pairs (x,x')
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.

[yi f] = ksdensity_cond(X, Y);

Xvals=unique(X, 'rows');
rangeX = size(Xvals,1);

for i=1:rangeX
    for j=1:rangeX
        if(i~=j)
        Ratio = f(i, :)./f(j, :);
        [ratio] = min(Ratio(:));
        MinRatioMat(i,j) = ratio;
        end
    end
end




