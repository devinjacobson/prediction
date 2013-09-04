function ind = argmin(X)
% function ind = argmin(X)
%
% Returns index of minimal value of X(:)
%
% Input:  X     matrix of values
%
% Output: ind   linear index of minimal value of X(:)
%
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  [val,ind] = min(X(:))
end
