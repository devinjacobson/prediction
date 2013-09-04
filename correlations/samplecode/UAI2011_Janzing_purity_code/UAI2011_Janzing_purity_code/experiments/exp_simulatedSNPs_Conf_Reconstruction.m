function exp_simulatedSNPs_Conf_Reconstruction() 
% function exp_simulatedSNPs_Conf_Reconstruction()
%
% Experiment with synthetic data
% produces Fig. 3(b-d) of the paper
%
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%


close all;
    
[X_causal X_noncausal Y] = GenerateSimulatedData();

file = sprintf('./results/exp_simulatedSNPs_SingleRun');

%Unobserved
file1 = strcat(file,'_Unobserved.eps');
[yiC fC] = ksdensity_cond(X_causal, Y);   
cond_distr_plot(yiC, fC, 'Z');
exportfig(gcf, file1, 'width', 10,'height',8,'FontMode','fixed','FontSize',14,'LineMode','fixed','LineWidth',1.5,'Color','rgb','Bounds','tight');
%Observed
file2 = strcat(file,'_Observed.eps');
[yiNC fNC] = ksdensity_cond(X_noncausal, Y);   
cond_distr_plot(yiNC, fNC, 'X');
exportfig(gcf, file2, 'width', 10,'height',8,'FontMode','fixed','FontSize',14,'LineMode','fixed','LineWidth',1.5,'Color','rgb','Bounds','tight');
%Reconstructed
file3 = strcat(file,'_Reconstructed.eps');
[yiR fR] = ReconstructBinaryConf(X_noncausal, Y);
cond_distr_plot(yiR, fR, 'Z');
exportfig(gcf, file3, 'width', 10,'height',8,'FontMode','fixed','FontSize',14,'LineMode','fixed','LineWidth',1.5,'Color','rgb','Bounds','tight');

     