function [x,y,X,Y] = simplex(func, x, opts, varargin)
%
% SIMPLEX - multidimensional unconstrained non-linear optimsiation
%
%    X = SIMPLEX(FUNC,X) finds a local minumum of a function, via a function
%    handle FUNC, starting from an initial point X.  The local minimum is
%    located via the Nelder-Mead simplex algorithm [1], which does not require
%    any gradient information.
%
%    [X,Y] = SIMPLEX(FUNC,X) also returns the value of the function, Y, at
%    the local minimum, X.
%
%    X = SIMPLEX(FUNC,X,OPTS) allows the optimisation parameters to be
%    specified via a structure, OPTS, with members
%
%       opts.Chi         - Parameter governing expansion steps
%       opts.Delta       - Parameter governing size of initial simplex.
%       opts.Gamma       - Parameter governing contraction steps.
%       opts.Rho         - Parameter governing reflection steps.
%       opts.Sigma       - Parameter governing shrinkage steps.
%       opts.MaxIter     - Maximum number of optimisation steps.
%       opts.MaxFunEvals - Maximum number of function evaluations.
%       opts.TolFun      - Stopping criterion based on the relative change in
%                          value of the function in each step.
%       opts.TolX        - Stopping criterion based on the change in the
%                          minimiser in each step.
%
%    OPTS = SIMPLEX() returns a structure containing the default optimisation
%    parameters, with the following values:
%
%       opts.Chi         = 2
%       opts.Delta       = 0.01
%       opts.Gamma       = 0.5
%       opts.Rho         = 1
%       opts.Sigma       = 0.5
%       opts.MaxIter     = 400
%       opts.MaxFunEvals = 1000
%       opts.TolFun      = 1e-6
%       opts.TolX        = 1e-6
%
%    X = SIMPLEX(FUNC,X,OPTS, P1, P2, ...) allows addinal parameters to be
%    passed to the function to be minimised.
%
%    [X,Y,XX,YY] = SIMPLEX(FUNC, X) also returns in XX all of the values of
%    X evaluated during the optimisation process and in YY the corresponding
%    values of the function.
%
%    References:
%
%       [1] J. A. Nelder and R. Mead, "A simplex method for function
%           minimization", Computer Journal, 7:308-313, 1965.

%
% File        : simplex.m
%
% Date        : Friday 5th January 2007
%
% Author      : Dr Gavin C. Cawley
%
% Description : Simple implementation of the Nelder-Mead simplex optimisation
%               algorithm [1].  Similar to the fminsearch routine from the
%               MATLAB optimisation toolbox.
%
% References  : [1] J. A. Nelder and R. Mead, "A simplex method for function
%                   minimization", Computer Journal, 7:308-313, 1965.
%
% History     : 05/01/2007 - v1.00
%
% Copyright   : (c) Dr Gavin C. Cawley, January 2007.
%
%    This program is free software; you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation; either version 2 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program; if not, write to the Free Software
%    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
%

% use default optimisation parameters if none given

if nargin < 3

   opts.Chi         = 2;
   opts.Delta       = 0.01;
   opts.Gamma       = 0.5;
   opts.Rho         = 1;
   opts.Sigma       = 0.5;
   opts.MaxIter     = 400;
   opts.MaxFunEvals = 1000;
   opts.TolFun      = 1e-6;
   opts.TolX        = 1e-6;

end

% return structure containing default optimisation parameters

if nargin == 0

   x = opts;

   return

end

% get initial parameters

x = x(:);
n = length(x);
x = repmat(x', n+1, 1);
y = zeros(n+1, 1);

% form initial simplex

for i=1:n

   x(i,i) = x(i,i) + opts.Delta;   
   y(i)   = func(x(i,:), varargin{:});

end

y(n+1) = func(x(n+1,:), varargin{:});
X      = x;
Y      = y;
count  = n+1;

format = '  % 4d        % 4d     % 12f     %s\n';
fprintf(1, '\n Iteration   Func-count    min f(x)    Procedure\n\n');
fprintf(1, format, 1, count, min(y), 'initial');

% iterative improvement

for i=2:opts.MaxIter

   x(end, :)

   % order

   [y,idx] = sort(y);
   x       = x(idx,:);

   % reflect

   centroid = mean(x(1:end-1,:));
   x_r      = centroid + opts.Rho*(centroid - x(end,:));
   y_r      = func(x_r, varargin{:});
   count    = count + 1;
   X        = [X ; x_r];
   Y        = [Y ; y_r];

   if y_r >= y(1) & y_r < y(end-1)

      % accept reflection point

      x(end,:) = x_r;
      y(end)   = y_r;
      fprintf(1, format, i, count, min(y), 'reflect');

   else

      if y_r < y(1)

         % expand

         x_e   = centroid + opts.Chi*(x_r - centroid);
         y_e   = func(x_e, varargin{:});
         count = count + 1;
         X     = [X ; x_e];
         Y     = [Y ; y_e];

         if y_e < y_r

            % accept expansion point

            x(end,:) = x_e;
            y(end)   = y_e;
            fprintf(1, format, i, count, min(y), 'expand');

         else

            % accept reflection point

            x(end,:) = x_r;
            y(end)   = y_r;
            fprintf(1, format, i, count, min(y), 'reflect');

         end

      else 

         % contract

         shrink = 0;

         if y(end-1) <= y_r & y_r < y(end)

            % contract outside

            x_c   = centroid + opts.Gamma*(x_r - centroid);
            y_c   = func(x_c, varargin{:});
            count = count + 1;
            X     = [X ; x_c];
            Y     = [Y ; y_c];

            if y_c <= y_r
            
               % accept contraction point

               x(end,:) = x_c;
               y(end)   = y_c;
               fprintf(1, format, i, count, min(y), 'contract outside');

            else

               shrink = 1;

            end

         else

            % contract inside

            x_c   = centroid + opts.Gamma*(centroid - x(end,:));
            y_c   = func(x_c, varargin{:});
            count = count + 1;
            X     = [X ; x_c];
            Y     = [Y ; y_c];

            if y_c <= y(end)
            
               % accept contraction point

               x(end,:) = x_c;
               y(end)   = y_c;
               fprintf(1, format, i, count, min(y), 'contract inside');

            else

               shrink = 1;

            end

         end

         if shrink
         
            % shrink

            for j=2:n+1

               x(j,:) = x(1,:) + opts.Sigma*(x(j,:) - x(1,:));
               y(j)   = func(x(j,:), varargin{:});
               count  = count + 1;
               X      = [X ; x(j,:)];
               Y      = [Y ; y(j)];

            end

            fprintf(1, format, i, count, min(y), 'shrink');

         end

      end

   end

   % evaluate stopping criterion

   if max(abs(min(x) - max(x))) < opts.TolX

      fprintf(1, 'optimisation terminated sucessfully (TolX criterion)\n'); 

      break;

   end

   if abs(max(y) - min(y))/max(abs(y))  < opts.TolFun

      fprintf(1, 'optimisation terminated sucessfully (TolFun criterion)\n'); 

      break;

   end 

end

if i == opts.MaxIter

   fprintf(1, 'Warning : maximim number of iterations exceeded\n'); 

end

% update model structure

[y, idx] = min(y);
x        = x(idx,:);

% bye bye...

