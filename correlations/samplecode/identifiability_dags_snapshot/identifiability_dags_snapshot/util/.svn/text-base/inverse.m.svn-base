function finv = inverse(x,fx,y)
% function finv = inverse(x,fx,y)
%
% Given the function x->f(x) = fx, calculates finv = f^{-1}(y)
% f is assumed to be monotonically increasing.
%
% Input:  x     vector of values
%         fx    vector of corresponding function values
%         y     vector of "test" function values to be inverted
%
% Output: finv  vector of inverse function values at y
%
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

N = length(x);

% sort [x,fx] ascendingly according to x
[dummy idx] = sort(x);
x = x(idx);
fx = fx(idx);

xmin = x(1);
xmax = x(N);
ymin = fx(1);
ymax = fx(N);

finv = zeros(length(y),1);
for i=1:length(y)
  if y(i) < ymin
    finv(i) = xmin;
  elseif y(i) > ymax
    finv(i) = xmax;
  else
    % binary search
    low = 1; % y(i) >= fx(low)
    up = N;  % y(i) <= fx(up)

    while (up - low) > 1
      mid = low + floor((up - low) / 2);
      if fx(mid) < y(i)
        low = mid;
      elseif fx(mid) > y(i)
        up = mid;
      else
        low = mid;
        up = mid;
      end
    end

    if (up==low)
      finv(i) = x(low);
    else
      finv(i) = (y(i) - fx(low)) / (fx(up) - fx(low)) * (x(up) - x(low)) + x(low);
    end
  end
end

return
