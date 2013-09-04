function exp_simulatedSNPs() 
% function exp_simulatedSNPs()
%
% Experiment with synthetic data
% produces Fig. 3(a) of the paper
%
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

close all;

N=1000;
R_causal = zeros(N, 1);
R_noncausal = zeros(N, 1);
for i = 1:N
    i  
    [X_causal X_noncausal Y] = GenerateSimulatedData(); 
    
    % compute the purity ratio of P(Y|X) for the 2 simulation settings
    R_causal(i) = EstimatePairwisePurityRatio (X_causal, Y); % X_causal->Y
    R_noncausal(i) = EstimatePairwisePurityRatio (X_noncausal, Y); % X_noncausal<-Z->Y
end

file = sprintf('./results/exp_simulatedSNPs');

%save results
file1 = strcat(file,'.mat');
save(file1,'R_causal', 'R_noncausal')

%histogram of purity ratio for causal and non-causal setting
file2 = strcat(file,'_hist.eps');
histogram_purity_causal_noncausal(R_causal, R_noncausal)
exportfig(gcf, file2, 'width', 10,'height',8,'FontMode','fixed','FontSize',13,'LineMode','fixed','LineWidth',1.5,'Color','rgb','Bounds','tight');



