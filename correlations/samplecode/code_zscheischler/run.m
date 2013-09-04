% significance test on simulated data (trace method)
% plots p-values of both directions for different dimensions in one plot

% Copyright (c) 2010-2011  Jakob Zscheischler [jakob.zscheischler@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

addpath('sparse/')
addpath('sparse/lars/')

%significance level
alpha = 0.005;

%number of experiments
N = 200;

% dimensions
dim=[6,8,10,12,14,16,18,20,22,24];

%noiselevel
nl = 0.3;

for i=dim
    i
    for ex=1:N
	% create data
        [X1, Y1] = highdimmodel(i,i,floor(i/2),0);
        [X2, Y2] = highdimmodel(i,i,floor(i/2),nl);
        [X3, Y3] = conf_model(i,floor(i/2));
        [X4, Y4] = highdimmodel_sparse(i,i,floor(i/2),1);

	%significance test
        [pval1(ex,1) pval2(ex,1)] = significance(X1, Y1, 1000);
        [pval1(ex,2) pval2(ex,2)] = significance(X2, Y2, 1000);
        [pval1(ex,3) pval2(ex,3)] = significance(X3, Y3, 1000);
        [pval1(ex,4) pval2(ex,4)] = significance_sparse(X4, Y4, 1000);
    end
    % calculating p-values
    for j=1:4
    right(i,j) = sum(pval1(:,j)<alpha) + sum(pval1(:,j)>(1-alpha));
    wrong(i,j) = sum(pval2(:,j)<alpha) + sum(pval2(:,j)>(1-alpha));
    end
end

%% plotting
figure
for j=1:4
    axes('LineWidth',5,'FontSize',16);
    axis([0 25 0 100])
    subplot(1,4,j)
    plot(dim,right(dim,j)/N*100,'g*-','LineWidth',3)
    hold on
    plot(dim,wrong(dim,j)/N*100,'ro--','LineWidth',3)
    legend('{X \rightarrow Y}','{Y \rightarrow X}','location','East')
    ylabel('% of p-values below 0.01','Fontsize',14)
    xlabel('dimension','Fontsize',14)
end
