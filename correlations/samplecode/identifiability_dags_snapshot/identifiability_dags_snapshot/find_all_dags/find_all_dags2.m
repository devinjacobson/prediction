function [causalorder_final,num_diff_dags,dags,residuals_final] = find_all_dags2(X,fitmethod,parsf,ind_test,parsi,alpha,res)
% function [causalorder_final,num_diff_dags,dags,residuals_final] = find_all_dags2(X,fitmethod,parsf,ind_test,parsi,alpha,res)
%
% Assuming that the data comes from a functional model from an IFMOC,
% find_all_dags2 finds all DAGs that are consistent with the data.
%
% INPUT:  X              should be N*d matrix (N = number of data points,
%                        d = number of variables);
%         fitmethod      function handle to the regression method (e.g., 'train_gp' or 'train_linear')
%         parsf          parameters for the regression method (can be empty);
%         ind_test       function handle to the independence test (e.g., 'indtest_corr', 'indtest_hsic', or 'indtest_chisq')
%         parsi          parameters for the independence test (can be empty);
%         alpha          threshold for each independence test (e.g., 0.05);
%         res            residuals for all fits (optional; will be calculated
%                        using fitmethod if unspecified or empty)
%
% OUTPUT: num_diff_dags        the number of different DAGs that the algorithm could fit to the data
%         causalorder_final    num_diff_dags-cell a causal ordering compatible with the dat
%         dags                 num_diff_dags-cell of the Directed Acyclic Graphs found by the algorithm
%         residuals_final      num_diff_dags-cell of N*d matrices containing the corresponding residuals
%
% Copyright (c) 2008-2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
%               2010-2011  Jonas Peters [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

if nargin < 7
  res = [];
end

n = size(X,2); %number of nodes
akt=1; %we are investigating the akt'th possible DAG
in_total=1; %... out of in_total many
jj{1}=n;
pars{1} = [1:n];
causalorder{1} = zeros(n,1);
residuals{1} = X;

while akt <=in_total
  for j=jj{akt}:-1:1
      if length(pars{akt}) > 1
          p = [];
          for i_=1:length(pars{akt})
              i = pars{akt}(i_);
              pabit = set2n(pars{akt}) - 2^(i-1); 
              pa = n2set(pabit);
              if ~isempty(res)
                  residua(:,i) = res{akt}(:, (i-1)*2^n + pabit + 1); 
              else
		      fitresult = feval(fitmethod, X(:,pa), X(:,i), parsf);
                  residua(:,i) = fitresult.eps;
              end
          p(i_) = feval(ind_test,X(:,pa),residua(:,i),[],parsi);
          end
          if max(p) < alpha
              p
              causalorder{akt}
              pars{akt}
              'Code can be improved here. It should cancel akt and go to akt+1.'
          else
              if ~isequal(residuals{akt}(:,pars{akt}),X(:,pars{akt}))
                  display('There is a bug somewhere.')
              end
              [maxp,i__{akt}] = max(p);
              p(i__{akt})=-1;
              while max(p)>alpha
                  in_total=in_total+1;
                  [maxp,i__{in_total}] = max(p);
                  p(i__{in_total})=-1;
                  jj{in_total}=j-1;
                  residuals{in_total}=residuals{akt};
            	  causalorder{in_total}=causalorder{akt};
                  pars{in_total}=pars{akt};
                  i = pars{in_total}(i__{in_total});
                  causalorder{in_total}(j) = i;
                  residuals{in_total}(:,i)=residua(:,i);
                  pars{in_total} = setxor(pars{in_total},i);
              end
              i = pars{akt}(i__{akt});
              causalorder{akt}(j) = i;
              residuals{akt}(:,i)=residua(:,i);
              pars{akt} = setxor(pars{akt},i);
          end
      else
          maxp = 1.0;
          i__{akt} = 1;
          i = pars{akt}(i__{akt});
          causalorder{akt}(j) = i;
          pars{akt} = setxor(pars{akt},i);
      end

  end
  akt=akt+1; 
end

fprintf('found %d DAGs...\n',in_total);
fprintf('remove all DAGs, for which noise is still dependent...\n');
% remove all hypotheses, for which the noise is still dependent.
%Jonas: For me it is not clear that it is necessary.
remove=[];
for akt=1:in_total
    zz=0;p=0;
    for u=1:(n-1)
        for uu=(u+1):n
            zz=zz+1;
            p(zz) = feval(ind_test,residuals{akt}(:,u),residuals{akt}(:,uu),[],parsi);
        end
    end
    if min(p)<alpha
        remove=[remove, akt]; 
    end
end

if ~isempty(remove)
    fprintf('hypotheses');
    fprintf(' %d ',remove);
    fprintf('removed\n');
end

in_total=in_total-length(remove);
zz=0;
for u=1:in_total
    while sum((u+zz)==remove)==1
        zz=zz+1;
    end
    causalorder_new{u}=causalorder{u+zz};
    residuals_new{u}=residuals{u+zz};
end


fprintf('removing arrows that are not necessary...\n');

dag{1} = zeros(n,n);
for akt=1:in_total
  dag{akt} = zeros(n,n);
  for j=2:n
      i = causalorder_new{akt}(j);
      pars_i = causalorder_new{akt}(1:(j-1)); %current parents from i. do we need all of them?
      k_ = 1;
      while k_ <= length(pars_i)
          k = pars_i(k_);
          pa = setdiff(pars_i,k);
          pabit = set2n(pa);
          if ~isempty(res)
              tresiduals = res{akt}(:, (i-1)*2^n + pabit + 1);
          else
          fitresult = feval(fitmethod, X(:,pa), X(:,i), parsf);
	      tresiduals = fitresult.eps;
          end
          p = feval(ind_test,residuals_new{akt}(:,causalorder_new{akt}(1:(j-1))),tresiduals,[],parsi);
          if p > alpha
              % removing k from pars_i
              pars_i = setdiff(pars_i, k);
              residuals_new{akt}(:,i) = tresiduals;
          else
              k_ = k_ + 1;
          end
      end
      if length(pars_i)>0
          dag{akt}(pars_i, i) = 1;
      end
  end
end
% res(:,(i-1)*2^n+pabit+1) = fit_helper(X(:,pa),X(:,i),fitmethod);

fprintf('removing multiple DAGs...\n');
if in_total>0
    %remove all multiple dags
    num_diff_dags=1;
    dags{1}=dag{1};
    causalorder_final{1}=causalorder_new{1};
    residuals_final{1}=residuals_new{1};
    for i=2:in_total
        j=1;
        while ~isequal(dag{i},dags{j}) && j<=(num_diff_dags-1)
            j=j+1;
        end
        if j==num_diff_dags && ~isequal(dag{i},dags{j})
            num_diff_dags=num_diff_dags+1;
            dags{num_diff_dags}=dag{i};
            causalorder_final{num_diff_dags}=causalorder_new{i};
            residuals_final{num_diff_dags}=residuals_new{i};
        end
    end
    fprintf('At the end %d DAG(s) remained.\n',num_diff_dags);
else
    causalorder_final=[];
    num_diff_dags=0;
    dags=[];
    residuals_final=[];
    fprintf('No dag was found!!\n');
end
  
return
