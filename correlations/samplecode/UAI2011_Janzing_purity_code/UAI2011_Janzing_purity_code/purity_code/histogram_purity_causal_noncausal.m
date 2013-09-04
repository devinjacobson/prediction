function histogram_purity_causal_noncausal (R_causal, R_noncausal)
% function histogram_purity_causal_noncausal (R_causal, R_noncausal)
%
% Plots histogram of the purity ratios of P(Y|X) for the two simulation settings: 
% X->Y and X<-Z->Y (Fig. 3(a))
%
% INPUT:
% R_causal          Nx1 (N data points), negative logarithm of the purity ratio of P(Y|X) for the setting X->Y 
% R_noncausal       Nx1 (N data points), negative logarithm of the purity ratio of P(Y|X) for the setting X<-Z->Y
%
% Copyright (c) 2011  Eleni Sgouritsa
% All rights reserved.  See the file COPYING for license terms.
%

R = [exp(-R_causal) exp(-R_noncausal)];
hist(R);
h = findobj(gca,'Type','patch');
set(h(2),'FaceColor',[0 0 0],'EdgeColor',[0 0 0]);
set(h(1),'FaceColor',[0.5 0.5 0.5],'EdgeColor',[0.5 0.5 0.5]);
legend('X \rightarrow Y','X\leftarrow Z \rightarrow Y') 
xlabel('Purity ratio of P(Y|X)')
ylabel('Absolute frequency')
