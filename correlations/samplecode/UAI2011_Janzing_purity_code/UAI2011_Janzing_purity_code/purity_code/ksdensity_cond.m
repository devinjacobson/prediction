function [yi f] = ksdensity_cond(X, Y)
% function [yi f] = ksdensity_cond(X, Y)
%
% Estimates the probability density of Y conditioned on the state of X
%
% INPUT:
%   X               Nx1 (N data points)
%   Y               Nx1 (N data points)
%
% OUTPUT:
%   yi              vector 1x1000 with equally spaced y values
%   f               matrix (states of X x 1000) 
%                   every row contains the density values evaluated at the
%                   points in yi for a certain x
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

Xvals=unique(X, 'rows');
rangeX = size(Xvals,1);
for i=1:rangeX
    Inds = find(ismember(X, Xvals(i,:),'rows'));
    Y_cond = Y(Inds);
    step = (max(Y)-min(Y))/1000;
    yi = min(Y):step:max(Y);
    [f(i, :) u] = ksdensity(Y_cond, yi, 'npoints', 1000);  
end
