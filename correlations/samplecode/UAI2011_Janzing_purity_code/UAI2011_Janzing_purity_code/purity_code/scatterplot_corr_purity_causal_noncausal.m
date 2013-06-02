function scatterplot_corr_purity_causal_noncausal (R_causal, R_noncausal, Corr_causal, Corr_noncausal)
% function  scatterplot_corr_purity_causal_noncausal (R_causal, R_noncausal, Corr_causal, Corr_noncausal)
%
% Scatter plot 
% x-axes:  correlation between X and Y
% y-axes:  the purity ratio of P(Y|X)
% for the two simulation settings: X->Y and X<-Z->Y (for Fig, 4) 
%
% INPUT:
% R_causal          Nx1 (N data points), negative logarithm of the purity ratio of P(Y|X) for the setting X->Y 
% R_noncausal       Nx1 (N data points), negative logarithm of the purity ratio of P(Y|X) for the setting X<-Z->Y
% Corr_causal       Nx1 (N data points), correlation between X and Y for the setting X->Y 
% Corr_noncausal    Nx1 (N data points), correlation between X and Y for the setting X<-Z->Y
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

figure;
hold on;
plot(Corr_causal,R_causal,'+','Color', [0 0 0])
plot(Corr_noncausal,R_noncausal,'+','Color', [0.5 0.5 0.5])
legend('X \rightarrow Y','X\leftrightarrow Z \rightarrow Y','Location', 'NorthWest');
xlabel('r^2(X,Y)')
ylabel('- log(purity ratio) of P(Y|X)');
