% This algorithm tries to detect the true direction of time series.
% Therefore it does an independence test between the fitted residuals
% (create them by doing an ARIMA fit using the code arimafit.R)
% and the time series values.
%
%
% If the residuals seem to be gaussian or one of both directions leads to 
% independent or dependent noise, we do not decide.
%
% The output are the two matrices classified_matrix and
% cor_classified_matrix, both depend on alpha and delta (alpha takes all
% values from alphavec, delta takes all values from diffbound_vec.
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
numts=10;
plotssigma=0;
plotseps=0;
plotts=0;
scattereps=0;

load_ts_from=1;     % 0: txt-files, 1: R-files
take_x_diff=0;      % shall we take the difference of time series values?

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
diffboundvec=0:0.02:0.2;
alphavec=0.005:0.005:0.1;

if kkern==0
    sigmavec=[0];
end



kt=zeros(5,numts,5,2);
sn=zeros(5,numts,5,2);
warn=[];
split=1;

%%%%%%%%%
%loading ...
%%%%%%%%%

for i4=1:numts
    %loading time series
    b=['~/raw_data/ts_' int2str(i4) '.txt'];
    if load_ts_from==0
        aa=importdata(b,' ',0);
        x1=aa';
    else
        aa=importdata(b,' ',4);
        aa2=aa.data';
        x1=aa2(1:sum(sum(1-isnan(aa2))))'; 
    end
    timeser{i4}=x1; % should be of size (length,1)
    
    
    %loading the residuals
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
end




for i4=1:numts
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

    sn(i4,split,1)=skewness(eps1sam);
    sn(i4,split,2)=skewness(eps2sam);
    kt(i4,split,1)=kurtosis(eps1sam)-3;
    kt(i4,split,2)=kurtosis(eps2sam)-3;

    p_forw(i4,split)=hsic_f_old_jp(eps1sam,x1sam,0);
    p_backw(i4,split)=hsic_f_old_jp(eps2sam,x2sam,0);
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
        title(['Plot of ' int2str(i4) filen{i4} ' split ' int2str(split) ' forwards'])
        subplot(diffordernum,2,2);
        plot(x2,'Color','red');
        axis([[xlim*[1;0] length(x2)] ylim])
        title(['Plot of ' int2str(i4) filen{i4} ' split ' int2str(split) ' backwards'])
        if cell2mat(difforder)=='52'
            subplot(diffordernum,2,3);
            plot(firstdiff(x1),'Color','blue');
            axis([[xlim*[1;0] length(x1)] ylim])
            title(['Plot of differenced ' int2str(i4) filen{i4} ' split ' int2str(split) ' forwards'])
            subplot(diffordernum,2,4);
            plot(-firstdiff(x2),'Color','red');
            axis([[xlim*[1;0] length(x2)] ylim])
            title(['Plot of -differenced ' int2str(i4) filen{i4} ' split ' int2str(split) ' backwards'])
       end
    end
i4
end


%auswertung

classified_matrix=-ones(length(diffboundvec),length(alphavec));
cor_classified_matrix=-ones(length(diffboundvec),length(alphavec));
diffb_counter=0;
alpha_counter=0;
res=-100*ones(numts,1);
for diffbound=diffboundvec
    diffb_counter=diffb_counter+1;
    alpha_counter=0;
    for alpha=alphavec
        alpha_counter=alpha_counter+1;
        for i4=1:numts
            for split=1:1 
                if (p_backw(i4,split)>p_forw(i4,split))&&(p_backw(i4,split)-p_forw(i4,split)>diffbound)
                    res(i4,split)=-1;
                elseif (p_backw(i4,split)<p_forw(i4,split))&&(p_forw(i4,split)-p_backw(i4,split)>diffbound)
                    res(i4,split)=1;
                else
                    res(i4,split)=0;
                end
                if (p_forw(i4,split)>alpha) && (p_backw(i4,split)>alpha)
                    res(i4,split)=0; %both direction possible
                end
                if (p_forw(i4,split)<alpha) && (p_backw(i4,split)<alpha)
                    res(i4,split)=2; %no direction possible
                end

                if normality_test==1
                    JBstat(1)=len/6*(sn(i4,split,1)^2+0.25*kt(i4,split,1)^2);
                    JBstat(2)=len/6*(sn(i4,split,2)^2+0.25*kt(i4,split,2)^2);
                    if and((cdf('chi2',JBstat(1),2)<=0.99),(cdf('chi2',JBstat(2),2)<=0.99))==1
                        res(i4,split)=3; %normal distribution
                    end
                end
            end %split
            classified(i4)=sum(abs(res(i4,:))==1);
            cor_classified(i4)=sum(res(i4,:)==1);
        end
        classified_matrix(diffb_counter,alpha_counter)=sum(classified)/numts;
        cor_classified_matrix(diffb_counter,alpha_counter)=sum(cor_classified)/sum(classified);
    end
end


figure
axes('FontSize',12)
imagesc(alphavec,diffboundvec,classified_matrix)
%brighten(0.5)
ylabel('\delta','fontsize',12)
xlabel('\alpha','fontsize',12)
% set(gca,'XTick',[2 4 6 8 10 12 14 16 18 20],'YTick',[1 3 5 7 9 11])
% set(gca,'XTickLabel',{'1';'2';'3';'4';'5';'6';'7';'8';'9';'10'})
% set(gca,'YTickLabel',{'0';'4';'8';'12';'16';'20'})
colorbar('FontSize',12)
title(['proportion of classified time series (out of ' int2str(numts) ')'])

figure
axes('FontSize',12)
imagesc(alphavec,diffboundvec,cor_classified_matrix)
%brighten(0.5)
ylabel('\delta','fontsize',12)
xlabel('\alpha','fontsize',12)
% set(gca,'XTick',[2 4 6 8 10 12 14 16 18 20],'YTick',[1 3 5 7 9 11])
% set(gca,'XTickLabel',{'1';'2';'3';'4';'5';'6';'7';'8';'9';'10'})
% set(gca,'YTickLabel',{'0';'4';'8';'12';'16';'20'})
colorbar('FontSize',12)
title('proportion of correctly classified time series')
