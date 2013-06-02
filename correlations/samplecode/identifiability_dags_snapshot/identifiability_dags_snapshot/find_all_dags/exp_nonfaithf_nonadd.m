%idee: dag: non-faithfull, non-additive
%ergebnis: ?
%
%   1
%  /  \
% 3 <- 2
% Copyright (c) 2010-2011  Jonas Peters  [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms. 



true_dag=[0 1 1;0 0 1;0 0 0];
true_dag2=[0 -1 -1;0 0 -1;0 0 0];


samplesize=400;
num_exp=100;

correct_pc=zeros(num_exp,1);
correct_rfm=zeros(num_exp,1);
wrong_rfm=zeros(num_exp,1);
undec_rfm=zeros(num_exp,1);

alpha=0.05;pars.width=0;pars.perm=500;
    
 
for ex=1:num_exp
    ex
    
    N_X=rand(samplesize,1)-0.5;
    N_Y=rand(samplesize,1)-0.5;
    N_Z=rand(samplesize,1)-0.5;
    
    X=N_X;
    Y=X+0.5*N_Y;
    Z=(X-Y).*(0.5*N_Z);
    
    dag_rob=pc([X Y Z],'indtest_corr',pars,1,alpha);
    [causalorder_final,num_diff_dags(ex),dags,residuals_final] =find_all_dags2([X,Y,Z],'train_linear',[],'indtest_hsic',[],alpha);

    if check_markov_equiv(dag_rob,true_dag2)==1
        correct_pc(exp)=1;
    end

    if num_diff_dags(ex)==1
        if sum(sum(dags{1}==true_dag))==9
            correct_rfm(ex)=1;
        else
            wrong_rfm(ex)=1;
            wrong_dag{ex}=dags{1};
        end
    else
        undec_rfm(ex)=1;
    end
    
end

[num_diff_dags', correct_rfm, wrong_rfm, undec_rfm, correct_pc]
sum([num_diff_dags', correct_rfm, wrong_rfm, undec_rfm, correct_pc])

