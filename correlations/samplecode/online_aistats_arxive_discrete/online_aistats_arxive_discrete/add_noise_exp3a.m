function [X Y p]=add_noise_exp3a(num_samples, fct, X_distr, pars, n_distr, pars2, fct_kind)
%
%fct_kind can be 
%'fct'
%'vector'
%
%X distribution can be
%%bino-binornd
%%geo-geornd
%%hypergeo-hygernd
%%multin-mnrnd
%%negbin-nbinrnd
%%poisson-poissrnd
%%custom
%
% num_samples=200;
% fct=[0;3;4];
% fct_bw=[0;1;2;0;1];
% X_distr=[0.6 0.15 0.25];
% noise_distr=[0.6 0.1 0.1 0.1 0.1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%-please cite
% Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, 
% in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, 
% JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
%Copyright (C) 2010 Jonas Peters
%
%    This file is part of discrete_anm.
%
%    discrete_anm is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    discrete_anm is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with discrete_anm.  If not, see <http://www.gnu.org/licenses/>.    
    
switch lower(n_distr)
    case 'custom'
        tmp=0;
        for i=1:length(pars2.p_n)
            tmp=tmp+pars2.p_n(i);
            noise_cdf(i)=tmp;
        end
        eps=rand(num_samples,1);
        for i=1:num_samples
            eps(i)=sum(eps(i)>noise_cdf)+1;
        end
        eps=pars2.n_values(eps);
    case 'bino'
        eps=binornd(pars2.N,pars2.p,num_samples,1);
    case 'geo'
        eps=geornd(pars2.p,num_samples,1);
    case 'hypergeo'
        eps= hygernd(pars2.M,pars2.K,pars2.N,num_samples,1);
    case 'negbin'
        eps=nbinrnd(pars2.R,pars2.P,num_samples,1);
    case 'poisson'
        eps=poissrnd(pars2.lambda,num_samples,1);
end

switch lower(X_distr)
    case 'custom'
        tmp=0;
        for i=1:length(pars.p_X)
            tmp=tmp+pars.p_X(i);
            X_cdf(i)=tmp;
        end
        X=rand(num_samples,1);
        for i=1:num_samples
            X(i)=sum(X(i)>X_cdf)+1;
        end
        switch lower(fct_kind)
            case 'fct'
                X=pars.X_values(X);
                Y=fct(X)+eps;
            case 'vector'
                Y=fct(X)+eps;
                X=pars.X_values(X);
            end
    case 'bino'
        X=binornd(pars.N,pars.p,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'geo'
        X=geornd(pars.p,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'hypergeo'
        X= hygernd(pars.M,pars.K,pars.N,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'negbin'
        X= nbinrnd(pars.R,pars.P,num_samples,1)+1;
        Y=fct(X)+eps;
    case 'poisson'
        X= poissrnd(pars.lambda,num_samples,1)+1;
        Y=fct(X)+eps;
end

% chi_sq_quantile_discr(X,eps,num_states_X,num_states_Y)
% g_quantile(X,eps,num_states_X,num_states_Y)


% Xhat=fct_bw(Y+1);
% eps_bw=mod(X-Xhat,num_states_X);
% chi_sq_quantile_discr(Y,eps_bw,num_states_Y,num_states_X)
% g_quantile(Y,eps_bw,num_states_Y,num_states_X)

p=chi_sq_quant(eps,X,length(unique(eps)),length(unique(X)));
%p=chi_sq_quantile(eps,X)



%entropy
% for i=1:num_states_X
%     p(i)=sum(X==(i-1))/num_samples;
%     logp(i)=log(p(i))/log(2);
% end
% for i=1:num_states_Y
%     q(i)=sum(Y==(i-1))/num_samples;
%     logq(i)=log(q(i))/log(2);
% end
% p
% q
% entropyX=-sum(p.*logp)
% entropyY=-sum(q.*logq)
