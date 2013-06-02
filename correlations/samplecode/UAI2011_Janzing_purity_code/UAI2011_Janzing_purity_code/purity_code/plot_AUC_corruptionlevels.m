function plot_AUC_corruptionlevels (corruption, AUC_pure, AUC_corr)
% function plot_AUC_corruptionlevels (corruption, AUC_pure, AUC_corr)
%
% Plot AUC as a function of the corruption level using correlation and
% purity
% Produces plot of Fig. 5
%
% INPUT:
% corruption     vector with corruption levels
% AUC_pure       vector of AUC values using purity
% AUC_corr       vector of AUC values using correlation
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

figure;
plot(corruption, AUC_pure, '-+', 'Color', [0 0 0])
hold on
plot(corruption, AUC_corr, '-+', 'Color', [0.5 0.5 0.5])
legend('-log(purity ratio)','correlation','Location', 'SouthEast');
xlabel('corruption level')
ylabel('Area under ROC curve (AUC)');
set(gca,'xtick',[0,0.1,0.2,0.3, 0.4, 0.5]);
hold off