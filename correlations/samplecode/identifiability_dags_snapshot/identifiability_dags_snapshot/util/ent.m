function [HX] = ent(X)
% function [HX] = ent(X)
%
% Estimate differential entropy of X
%
% Input:  X   vector of values
%
% Output: HX  estimate of differential Shannon entropy of X
%
% See (4) in A. Kraskov, H. Stoegbauer, and P. Grassberger (2003):
% Estimating Mutual Information. http://arxiv.org/abs/cond-mat/0305641v1
% (note that this article contains a sign error)
%
% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  [X1,indXs] = sort(X);
  N1 = length(X1);
  HX = 0.0;
  for i = 1:N1-1
    dX = X1(i+1) - X1(i);
    if dX ~= 0.0
      HX = HX + log(abs(dX));
    end
  end
  HX = HX / (N1 - 1) + psi(N1) - psi(1);
return
