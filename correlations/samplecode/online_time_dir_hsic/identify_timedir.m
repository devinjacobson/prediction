function [res p_forw p_backw]=identify_timedir(ts_data,res_data, alpha, delta, num_ts)
% INPUT
%
% ts_data is either
%     0: load from txt-files
%     1: load from R-files
%     a (nx1) vector consisting of the time series data.
%
% res_data is either
%     1: load from R-files
%     a (nx2) vector consisting of the residuals (1.col: forward, 2.col: backward).
%
% 
% num_ts: if ts_data and res_data = 0, one can load a whole set of time series
%     (from 1 to num_ts). Otherwise set num_ts=1
%
% alpha is the significance level for the independence test (often
% alpha=0.05)
%
% delta is the minimum difference in p-values for both directions: if the 
% difference is smaller, the method does not decide (often delta=0.1)
%
% 
%
%
% OUTPUT
%
% p_forw and p_backw contain the p-values for both directions
% 
% res gives the result of the method:
% 1: The method infers the correct time direction,
%-1: the method infers the wrong time direction,
% 0: the method does decide because the difference in p values is too small,
% 2: the method does decide because the model does not fit in any direction,
% 3: the method does decide because the residuals seem to be normal.
%
%
%
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

%%%%%%%%%%%%%
%parameters
%%%%%%%%%%%%%
plotssigma=0;
plotseps=0;
plotts=0;
scattereps=0;

normality_test=0;   %0: do not test for normality
                    %1: do test for normality
kkern=1;            %1: gausskern    
                    %2: polkern
nperm=0;            %0:         use a gamma approximation for the distr. of hsic
                    %e.g. 104:  approximate the distr. of hsic by shuffling the data points
sigmavec=[0];       %0: choose the bandwidth of the gaussian kernel to be the median (rule of thumb)
poldeg=9;







windowlen=1;
mindist=1;          %at most 500 samples are considered
if kkern==0
    sigmavec=[0];
end
take_x_diff=0;


kt=zeros(5,num_ts,5,2);
sn=zeros(5,num_ts,5,2);
warn=[];


%%%%%%%%%
%loading ...
%%%%%%%%%
for i4=1:num_ts
    %loading time series
    b=['~/raw_data/ts_' int2str(i4) '.txt'];
    if ts_data==0
        aa=importdata(b,' ',0);
        x1=aa';
        timeser{i4}=x1; % should be of size (length,1)
    elseif ts_data==1
        aa=importdata(b,' ',4);
        aa2=aa.data';
        x1=aa2(1:sum(sum(1-isnan(aa2))))'; 
        timeser{i4}=x1; % should be of size (length,1)
    else
        timeser{1}=ts_data;
    end

    %loading residuals
    if res_data==1
        b=['~/fitted_residuals/ts_' int2str(i4) '_forw.txt'];
        aa=importdata(b,' ',5);
        aa2=aa.data';
        eps1=aa2(1:sum(sum(1-isnan(aa2))))';
        residual1{i4}=eps1;
        aa_diff=importdata(b,' ',0);
        difforder1(i4)=aa_diff.data;

        b=['~/fitted_residuals/ts_' int2str(i4) '_backw.txt'];
        aa=importdata(b,' ',5);
        aa2=aa.data';
        eps2=aa2(1:sum(sum(1-isnan(aa2))))';
        residual2{i4}=eps2;
        aa_diff=importdata(b,' ',0);
        difforder2(i4)=aa_diff.data;
    else
        residual1{1}=res_data(:,1);
        residual2{1}=res_data(:,2);
        difforder1(1)=0;
        difforder2(1)=0;
    end
end



%analysis
for i4=1:num_ts
    clear x1 x2 eps1 eps2 hsicdiff ctmp ctmp2 tmp b
    eps1=residual1{i4};
    eps2=residual2{i4};
    x1=timeser{i4};
    x2=x1(length(x1):(-1):1);
    len=length(x1);
    
    %taking differences
    if (difforder1(i4)=='2')&&(take_x_diff==1)
        eps1=eps1(3:length(eps1));
        x1=firstdiff(x1);
        x1=x1(1:(length(x1)-1));
    end
    if (difforder2(i4)=='2')&&(take_x_diff==1)
        eps2=eps2(3:length(eps2));
        x2=firstdiff(x2);
        x2=x2(1:(length(x2)-1));
    end
    if difforder2(i4)~=difforder1(i4)
        %display('warning!!!!!!');
        warn=[warn;k];
    end

    %%%%%%%%%%
    %parameters & samples
    %%%%%%%%%%%
    dist=max(ceil(len/500),mindist);
    samples=(1:dist:(len-windowlen-dist*1))';
    samples=samples+dist;

    samplesmat=samples;
    for j=1:(windowlen-1)
        samplesmat=[samplesmat samples+j];
    end
    len2=length(samples);
    x1sam=x1(samplesmat);
    x2sam=x2(samplesmat+len-samples(length(samples))+1-samples(1));
    eps1sam=eps1(samples+windowlen);
    eps2sam=eps2(samples+windowlen+len-samples(length(samples))+1-samples(1));

    sn(i4,1)=skewness(eps1sam);
    sn(i4,2)=skewness(eps2sam);
    kt(i4,1)=kurtosis(eps1sam)-3;
    kt(i4,2)=kurtosis(eps2sam)-3;

    p_forw(i4)=hsic_f_old_jp(eps1sam,x1sam,0);
    p_backw(i4)=hsic_f_old_jp(eps2sam,x2sam,0);
%     p_forw(i4,split)=chi_sq_quantile(eps1sam,x1sam);
%     p_backw(i4,split)=chi_sq_quantile(eps2sam,x2sam);

    %plotting
    if plotseps==1
         figure(2);
         [f,xi] = ksdensity(eps1); 
         subplot(1,2,1)
         [aaa,aaa2]=hist(eps1,20);
         hist(eps1,20);
         hold on
         plot(xi,length(eps2)*(aaa2(2)-aaa2(1))*pdf('Normal',xi,0,sqrt(var(eps1))),'LineStyle','--', 'LineWidth',2,'Color','red');
         hold off

         [f,xi] = ksdensity(eps2); 
         subplot(1,2,2)
         [aaa,aaa2]=hist(eps2,20);
         hist(eps2,20)
         hold on
         plot(xi,length(eps2)*(aaa2(2)-aaa2(1))*pdf('Normal',xi,0,sqrt(var(eps2))),'LineStyle','--','LineWidth',2,'Color','red');
         hold off
    end
    if scattereps==1
        figure(3)
        scatter(x1sam,eps1sam);
        figure(4)
        scatter(x2sam,eps2sam);
        pause
    end

    if plotts==1
        figure(1);
        diffordernum=1;
        if cell2mat(difforder)=='2'
            diffordernum=1;
        end
        subplot(diffordernum,2,1);
        plot(x1,'Color','blue');
        axis([[xlim*[1;0] length(x2)] ylim])
        title(['Plot of ' int2str(i4) filen{i4} 'forwards'])
        subplot(diffordernum,2,2);
        plot(x2,'Color','red');
        axis([[xlim*[1;0] length(x2)] ylim])
        title(['Plot of ' int2str(i4) filen{i4} 'backwards'])
    end
%i4
end



%auswertung
classified=-1;
cor_classified=-1;
res=-100*ones(num_ts,1);
diffbound=delta;
for i4=1:num_ts
    if (p_backw(i4)>p_forw(i4))&&(p_backw(i4)-p_forw(i4)>diffbound)
        res(i4)=-1;
    elseif (p_backw(i4)<p_forw(i4))&&(p_forw(i4)-p_backw(i4)>diffbound)
        res(i4)=1;
    else
        res(i4)=0;
    end
    if (p_forw(i4)>alpha) && (p_backw(i4)>alpha)
        res(i4)=0; %both direction possible
    end
    if (p_forw(i4)<alpha) && (p_backw(i4)<alpha)
        res(i4)=2; %no direction possible
    end

    if normality_test==1
        JBstat(1)=len/6*(sn(i4,1)^2+0.25*kt(i4,1)^2);
        JBstat(2)=len/6*(sn(i4,2)^2+0.25*kt(i4,2)^2);
        if and((cdf('chi2',JBstat(1),2)<=0.99),(cdf('chi2',JBstat(2),2)<=0.99))==1
            res(i4)=3; %normal distribution
        end
    end
end
classified=sum(abs(res)==1)/num_ts
cor_classified=sum(res==1)/(classified*num_ts)
