%idee: dag: non-faithfull, generic (ueberall)
%ergebnis: ?
%
%   1
%  /  \
% 3 <- 2
% |
% 4
% Copyright (c) 2010-2011  Jonas Peters  [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms. 


true_dag=[0 1 1 0;0 0 1 0;0 0 0 1;0 0 0 0];
true_dag2=[0 -1 -1 0;0 0 -1 0;0 0 0 -1;0 0 0 0];


samplesize=400;
alpha=0.05;
pars.width=0;
num_exp=100;

correct_pc=zeros(num_exp,1);
correct_rfm=zeros(num_exp,1);
wrong_rfm=zeros(num_exp,1);
 
for exp=1:num_exp

    N_X=rand(samplesize,1);
    N_Y=rand(samplesize,1);
    N_Z=rand(samplesize,1);
    N_W=rand(samplesize,1);

    X=0.5*N_X;
    Y=1.5*X+0.5*N_Y;
    Z=-2*Y+3*X+0.5*N_Z;
    W=1.8*Z+0.5*N_W;

%     dag_rob=pc([X Y Z W],'indtest_corr',pars,2,alpha);
    dag_rob=pc([X Y Z W],'indtest_hsic',pars,2,alpha);
    [causalorder_final,num_diff_dags(exp),dags,residuals_final] =find_all_dags2([X,Y,Z,W],'train_linear',[],'indtest_hsic',[],alpha);

    

    if check_markov_equiv(dag_rob,true_dag2)==1
        correct_pc(exp)=1;
    end

    if num_diff_dags(exp)==1
        if sum(sum(dags{1}==true_dag))==16
            correct_rfm(exp)=1;
        else
            wrong_rfm(exp)=1;
            wrong_dag{exp}=dags{1};
        end
    end

end

[num_diff_dags', correct_pc, correct_rfm, wrong_rfm]
sum([num_diff_dags', correct_pc, correct_rfm, wrong_rfm])

