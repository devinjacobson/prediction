function n = set2n(set)
% function n = set2n(set)
%
% Encodes a set into an integer
%
% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  n = sum(2.^(set-1));

return
