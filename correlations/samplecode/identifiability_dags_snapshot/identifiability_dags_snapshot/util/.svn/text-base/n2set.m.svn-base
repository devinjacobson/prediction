function set = n2set(n)
% function set = n2set(n)
%
% Decodes an integer into a set
%
% Copyright (c) 2008-2010  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  set = [];
  for i=1:32
    if bitget(n,1) == 1
      set = [set i];
    end
    n = bitshift(n,-1);
  end

return
