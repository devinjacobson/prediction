function cond_distr_plot(yi, f, nameX)%(X, Y, nameX)
% function cond_distr_plot(yi, f, nameX)
%
% Plots a conditional P(Y|X) (for Fig, 3(b-d))
%
% INPUT:
% yi              vector 1x1000 with equally spaced y values
% f               matrix (states of X x 1000) 
%                 every row contains the density values evaluated at the
%                 points in yi for a certain x
%
% nameX:          name for X (default: 'X')
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

if nargin < 3
    nameX = 'X';
end

%[yi f] = ksdensity_cond(X, Y);   
      
figure;
range = size(f,1);%length(unique(X));
for i=1:range
    plot(yi, f(i,:), '-' ,'LineWidth',4, 'color', [(i-1)/range (i-1)/range (i-1)/range]);
    hold on;
end
lab1 = sprintf('P(Y|%s=0)', nameX);
lab2 = sprintf('P(Y|%s=1)', nameX);
hleg = legend(lab1,lab2);
xlabel('Y')
ylabel('Conditional Probability') 
hold off;
