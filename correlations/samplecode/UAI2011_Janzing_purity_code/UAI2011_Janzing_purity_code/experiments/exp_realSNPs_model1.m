function exp_realSNPs_model1()
% function exp_realSNPs_model1()
%
% Experiment with real SNPs and synthetic phenotype
% produces Fig. 4 of the paper
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

close all;

snps_mat = 'snps_nordborg_selection.mat';
snps = load(snps_mat);
snps = snps.x;
% -1/1 encoding
snps(snps==0) = -1;
Nsnps = size(snps,2);
SampleSize = size(snps, 1);

N=1000;
eps = 0.7;
delta = 1;

R_causal = zeros(N, 1);
R_noncausal = zeros(N, 1);
for i = 1:N
    i  
  
    index = 21:Nsnps-21;
    index = index(randperm(length(index))); % randomize
    i_x_causal = index(1);%pick causal snp
    X_causal = snps(:,i_x_causal);
    i_x_noncausal = i_x_causal + delta; % pick non causal snp next to the causal one
    X_noncausal = snps(:,i_x_noncausal);

    w1 = randn(1);
    E_Y = eps*randn(SampleSize,1);
    Y = w1*X_causal + E_Y;

    % compute the purity ratio of P(Y|X) and the correlation between 
    % X and Y for the 2 settings
    R_causal(i) = EstimatePairwisePurityRatio (X_causal, Y);
    [Corr pval] = corrcoef(X_causal, Y);
    Corr_causal(i) = abs(Corr(1,2));
    pval_causal(i) = pval(1,2);
    [R_noncausal(i)] = EstimatePairwisePurityRatio (X_noncausal, Y);
    [Corr pval] = corrcoef(X_noncausal, Y);
    Corr_noncausal(i) = abs(Corr(1,2));
    pval_noncausal(i) = pval(1,2);   
    
end

file = sprintf('./results/exp_realSNPs_model1'); 

%save results
file1 = strcat(file,'.mat');
save(file1,'R_causal', 'Corr_causal', 'pval_causal', 'R_noncausal', 'Corr_noncausal', 'pval_noncausal')

% scatter plot correlation-purity
file3 = strcat(file,'.eps');
scatterplot_corr_purity_causal_noncausal (R_causal, R_noncausal, Corr_causal, Corr_noncausal);
exportfig(gcf, file3, 'width', 12,'height',8,'FontMode','fixed','FontSize',13,'LineMode','fixed','LineWidth',1.5,'Color','rgb','Bounds','tight');