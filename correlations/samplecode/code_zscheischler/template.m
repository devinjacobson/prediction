% template for applying the trace method

% Input: X and Y with (dimensions, samples) loaded in your workspace

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

% calculate the deltas for both directions
[d1 d2] = twocause(X,Y);
% if d1 is closer to zero suggest, X --> Y is suggested and vize versa 

% calculate p-values with 1000 random rotations
[p1 p2] = significance(X,Y,1000);
% p1 is the p-value for the direction X to Y and vice versa

% set some significance value alpha to calculate significance
alpha = 0.1;

% for X to Y
issignificant_XtoY = (p1>alpha) && (p1<(1-alpha));

% for Y to X
issignificant_YtoX = (p2>alpha) && (p2<(1-alpha));
