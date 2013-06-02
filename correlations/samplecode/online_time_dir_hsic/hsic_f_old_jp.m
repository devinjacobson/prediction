function result=hsic_f(x1,eps1,distrapprox)
%jonas'version
%result: p-value
%strange median
%-please cite
% Peters, J., D. Janzing, A. Gretton and B. Schölkopf: Detecting the Direction of Causal Time Series. Proceedings of the 26th International Conference on Machine Learning (ICML 2009), 801-808.
% (Eds.) Danyluk, A., L. Bottou, M. L. Littman, ACM Press, New York, NY, USA
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
%Copyright (C) 2010 Jonas Peters
%
%    This file is part of time_direction.
%
%    time_direction is free software: you can redistribute it and/or modify
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
len2=length(x1);

%compute norm
x1norm=get_norm2(x1,x1);
eps1norm=get_norm2(eps1,eps1);

%compute kernel matrices
%using rule of thumb

sigma=sqrt(0.5*median(median(x1norm)));
K1=gausskernel(x1norm,sigma);

sigma=sqrt(0.5*median(median(eps1norm)));
L1=gausskernel(eps1norm,sigma);


%%%%%%%%
%HSIC_b
%%%%%%%%
H=eye(len2)-1/len2*ones(len2);
%HSIC1=1/(len2^2)*trace(K1*H*L1*H)

K1n=H*K1*H+10^(-12)*eye(len2);
L1n=H*L1*H+10^(-12)*eye(len2);
for uu=1:len2
    for vv=(uu+1):len2
        K1n(uu,vv)=K1n(vv,uu);
        L1n(uu,vv)=L1n(vv,uu);
    end
end
K1chol=chol(K1n);
L1chol=chol(L1n);
HSIC1=1/(len2^2)*trace(K1chol'*(K1chol*L1chol')*L1chol);


if distrapprox==0 %gamma approximation
    %%%%%%%%
    %mean_H0
    %%%%%%%%
    mux1=1/(len2*(len2-1))*(sum(sum(K1))-len2);
    mueps1=1/(len2*(len2-1))*(sum(sum(L1))-len2);
    mean1_h0=1/len2*(1+mux1*mueps1-mux1-mueps1);

    %%%%%%%%
    %var_H0
    %%%%%%%%
    var1_h0=(2*(len2-4)*(len2-5))/(len2*(len2-1)*(len2-2)*(len2-3))*1/((len2-1)^2)*trace(K1chol'*(K1chol*K1chol')*K1chol)*1/((len2-1)^2)*trace(L1chol'*(L1chol*L1chol')*L1chol);

    %%%%%%%%%
    %gamma distribution
    %%%%%%%%%
    alpha1=(mean1_h0^2)/(var1_h0);
    beta1=len2*var1_h0/mean1_h0;

    quantile1=cdf('gam',len2*HSIC1,alpha1,beta1);
else %sampling
    nperm=distrapprox;
    for i111=1:nperm
        eps1p=eps1(randperm(length(eps1)));
        eps1normp=get_norm2(eps1p,eps1p);
       
        sigma=sqrt(0.5*median(median(eps1normp)));
        L1=gausskernel(eps1normp,sigma);
        
        H=eye(len2)-1/len2*ones(len2);

        K1n=H*K1*H+10^(-12)*eye(len2);
        L1n=H*L1*H+10^(-12)*eye(len2);
        for uu=1:len2
            for vv=(uu+1):len2
                K1n(uu,vv)=K1n(vv,uu);
                L1n(uu,vv)=L1n(vv,uu);
            end
        end
        K1chol=chol(K1n);
        L1chol=chol(L1n);
        HSIC1p(i111)=1/(len2^2)*trace(K1chol'*(K1chol*L1chol')*L1chol);
    end
    var1_h0=var(HSIC1p);
    quantile1=sum(HSIC1p<HSIC1)/nperm;
    
end

result=1-quantile1;
