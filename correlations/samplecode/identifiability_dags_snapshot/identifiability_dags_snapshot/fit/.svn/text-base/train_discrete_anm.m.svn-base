function result = train_discrete_anm(X, Y, pars)
% function result = train_discrete_anm(X, Y, pars)
%
% tries to fit a discrete additive noise model (ANM) from X to Y. (was fit_discrete_mv.m before)
%
% Uses: matlab stats and bsmart?? (Why?)
%       1: /kyb/agbs/jpeters/Desktop/code/matlab_packages/bsmart/layout/arrow.m
%       1: /kyb/agbs/jpeters/Desktop/code/matlab_packages/bsmart/textbox.m
%       1: /kyb/agbs/jpeters/Desktop/svn/nonlinngam/code-extern/stats/distchck.m
%       1: /kyb/agbs/jpeters/Desktop/svn/nonlinngam/code/util/gamcdf.m
%       1: /kyb/agbs/jpeters/Desktop/svn/nonlinngam/code/discrete_anm/chi_sq_quant.m
%       1: /kyb/agbs/jpeters/Desktop/svn/nonlinngam/code/discrete_anm/plot_fct_dens.m
%
% 
% INPUT:   X                Nxd matrix of training inputs (N data points, d dimensions)
%          Y                Nx1 matrix of training outputs (N data points)
%          pars             parameters
%            .level           significance level for the independence test (e.g. 0.05),
%            .doplots         0 means no plots, 1 means do plots
%            .dir             This is only for the plots: If dir==0 the title says 'X->Y', otherwise it says 'Y->X'. 
%
% OUTPUT:  result
%	     .model         contains the parameter of the fitted model, namely 
%	       .fct
%	       .X_values
%	       .dim_X
%	       .X_old
%	       .Y_values
%	     .p_val	    p-value of the final residuals		
%
%
%
%-please cite
% Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, 
% in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, 
% JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
% Copyright (c) 2010-2011  Jonas Peters [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.



%%%%%%%%%%
%parameter
%%%%%%%%%%
level=pars.level;
doplots=pars.doplots;
dir=pars.dir;

num_iter=10;
num_pos_fct=min(max(Y)-min(Y),20);


dim_X=size(X,2);
samplesize=size(X,1);

%rescaling: 
for i=1:dim_X
    [X_values_old{i} aa X_old(:,i)]=unique(X(:,i));
end
%X_old(:,i) is between 1 and #distinct values of X(:,i)

X_new2=sum(X_old.*(ones(samplesize,1)*10.^(2*((dim_X-1):(-1):0))),2);
%X_new2 merges X_old(:,1):X_old(:,dim_X)

[X_values aa X_new]=unique(X_new2);
%X_new is between 1 and #distinct combinations of X(:,:)

Y_values=min(Y):1:max(Y);Y_values=Y_values';
%Y_values are everything between Y_min and Y_max


if size(X_values,1)==1|size(Y_values,1)==1
    fct=ones(length(X_values),1)*Y_values(1);
    p_val=1;
else
    p=hist3([X_new2 Y], {X_values Y_values});
    %[Y_values'; p]

    fct=[];
    for i=1:length(X_values)
        [a b]=sort(p(i,:));
        for k=1:size(p,2)
            if k~=b(length(b))
                p(i,k)=p(i,k)+1/(2*abs(k-b(length(b))));
            else
                p(i,k)=p(i,k)+1;
            end
        end
        [a b]=sort(p(i,:));
        cand{i}=b;
        fct=[fct;Y_values(b(length(b)))];
    end
    
    yhat=fct(X_new);
    eps=Y-yhat;
    if length(unique(eps))==1
        display('Warning!! there is a deterministic relation between X and Y');
        p_val=1;
    else
        p_val=chi_sq_quant(eps,X_new2,length(unique(eps)),length(X_values));
    end
    if doplots==1
        %fct
        %p_val
        display(['fitting ' int2str(dir+1) '. direction']);
        figure(dir+1);
        plot_fct_dens(X_new2, X_values, X_new, Y, Y_values, fct, p_val, level, dir,1);
        pause
    end
    i=0;
    while (p_val<level) & (i<num_iter)
        for j_new=randperm(length(X_values))
            for j=1:(num_pos_fct+1)
                pos_fct{j}=fct;
                pos_fct{j}(j_new)=Y_values(cand{j_new}(length(cand{j_new})-(j-1)));
                yhat=pos_fct{j}(X_new);
                eps=Y-yhat;
                [p_val_comp(j) p_val_comp2(j)]=chi_sq_quant(eps,X_new2,length(unique(eps)),length(X_values));
            end
    %        [p_val_comp;p_val_comp2]
            %[aa j_max]=min(p_val_comp2);
            [aa j_max]=max(p_val_comp);
            if aa<1e-3
                [aa j_max]=min(p_val_comp2);
            end
            fct=pos_fct{j_max};    
            yhat=fct(X_new);
            eps=Y-yhat;
            p_val=chi_sq_quant(eps,X_new2,length(unique(eps)),length(X_values));
            if doplots==1
                display(['fitting ' int2str(dir+1) '. direction']);
                figure(dir+1);
                plot_fct_dens(X_new2, X_values, X_new, Y, Y_values, fct, p_val, level, dir,1);
            end
        end
        i=i+1;
    end
    fct=fct+round(mean(eps));
    if doplots==0.5
        figure(dir+1);
        plot_fct_dens(X_new2, X_values, X_new, Y, Y_values, fct, p_val, level, dir,0);
    end
end


result.pval=pval;
result.eps=eps;
result.Ytrain=yhat;
result.model.fct=fct;
