function exp_realSNPs_model2()  %corresponding to Fig. 5 of the paper
% function exp_realSNPs_model2()
%
% Experiment with real SNPs and synthetic phenotype 
% (high correlation between the phenotype and the non-causal SNPs)
% produces Fig. 5 of the paper
%
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

corruption = [0 0.1 0.2 0.3 0.4 0.5];
N=1000;
eps = 0.7;
delta = 20;

R_causal = zeros(N, 1);
R_noncausal = zeros(N, 1);
for k = 1:length(corruption)
    k
    for i = 1:N
        i  
        corruption_level = corruption(k);  
        
        index = 21:Nsnps-21;
        index = index(randperm(length(index))); % randomize
        i_x_causal = index(1);%pick causal snp
        X_causal = snps(:,i_x_causal);    
        i_x_noncausal = i_x_causal + delta; % pick non causal SNP (far from the causal one)
        X_noncausal = snps(:,i_x_noncausal); 

        V_causal = X_noncausal;
        %add noise
        I_flip = rand(length(V_causal),1)<corruption_level;
        %flip them:
        V_causal(I_flip) = V_causal(I_flip)*(-1); 

        w1 = randn(1);
        w2  = 2*randn(1);
        E_Y = eps*randn(SampleSize,1);
        Y = w1*X_causal + w2*V_causal + E_Y;
    
        % compute the purity ratio of P(Y|X) and the correlation between 
        % X and Y for the 2 settings
        R_causal(i) = EstimatePairwisePurityRatio (X_causal, Y);
        [Corr pval] = corrcoef(X_causal, Y);
        Corr_causal(i) = abs(Corr(1,2));
        pval_causal(i) = pval(1,2);
        R_noncausal(i) = EstimatePairwisePurityRatio (X_noncausal, Y);
        [Corr pval] = corrcoef(X_noncausal, Y);
        Corr_noncausal(i) = abs(Corr(1,2));
        pval_noncausal(i) = pval(1,2);    
    end

    % compute AUC
    t = [ones(N, 1); zeros(N, 1)];
    y_p=[R_causal;R_noncausal];
    [tp_p, fp_p]=roc(t,y_p);
    AUC_pure(k) = auroc(tp_p, fp_p);
    y_c=[Corr_causal';Corr_noncausal'];
    [tp_c, fp_c]=roc(t,y_c);
    AUC_corr(k) = auroc(tp_c, fp_c);

    % plot AUC
    figure;
    plot(fp_p,tp_p, 'LineWidth',4, 'Color', [0 0 0]);
    hold on;
    plot(fp_c,tp_c, 'LineWidth',4, 'Color', [0.5 0.5 0.5]);
    hold off;
    xlabel('FPR');
    ylabel('TPR');
    title('PURITY AND CORRELATION ROC CURVES');
    legend(sprintf('purity        : AUC = %.2f', AUC_pure(k)), sprintf('correlation: AUC = %.2f', AUC_corr(k)), 'Location', 'SouthEast');
 
end

% AUC for different corruption levels
file = sprintf('./results/exp_realSNPs_model2'); 
file2 = strcat(file,'_AUC_corruptionPlot.eps');
plot_AUC_corruptionlevels (corruption, AUC_pure, AUC_corr);
exportfig(gcf, file2, 'width', 10,'height',8,'FontMode','fixed','FontSize',13,'LineMode','fixed','LineWidth',1.5,'Color','rgb','Bounds','tight');

    

    

