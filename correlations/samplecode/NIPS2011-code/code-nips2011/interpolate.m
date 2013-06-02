function fxx = interpolate(x,fx,xx)
% function fxx = interpolate(x,fx,xx)
%
% Given the function x->f(x) = fx, calculates fxx = f(xx)
%
% Input:  x   vector of values
%         fx  vector of corresponding function values
%         xx  vector of "test" values
%
% Output: fxx vector of interpolated function values at xx
%
% Copyright (c) 2011  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

N = length(x);

% sort [x,fx] ascendingly according to x
[dummy idx] = sort(x);
x = x(idx);
fx = fx(idx);

xmin = x(1);
xmax = x(N);
ymin = fx(1);
ymax = fx(N);

fxx = zeros(length(xx),1);
for i=1:length(xx)
  if xx(i) < xmin
    fxx(i) = ymin;
  elseif xx(i) > xmax
    fxx(i) = ymax;
  else
    % binary search
    low = 1; % xx(i) >= x(low)
    up = N;  % xx(i) <= x(up)

    while (up - low) > 1
      mid = low + floor((up - low) / 2);
      if x(mid) < xx(i)
        low = mid;
      elseif x(mid) > xx(i)
        up = mid;
      else
        low = mid;
        up = mid;
      end
    end

    if (up==low)
      fxx(i) = fx(low);
    else
      fxx(i) = (xx(i) - x(low)) / (x(up) - x(low)) * (fx(up) - fx(low)) + fx(low);
    end
  end
end

return
