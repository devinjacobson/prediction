% idee: dag: faithfull, generic (ueberall)
% 
%      1  
%    /  \ 
%   2 -> 3
%    \  /
%      4
%
% Copyright (c) 2010-2011  Jonas Peters  [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms. 


true_dag=[0 1 1 0;0 0 1 1;0 0 0 1;0 0 0 0];
true_dag2=[0 -1 -1 0;0 0 -1 -1;0 0 0 -1;0 0 0 0];
samplesize=400;
num_exp=100;
alpha=0.05;

wrong_rfm=zeros(num_exp,1);
correct_rfm=zeros(num_exp,1);
wrong_rfm2=zeros(num_exp,1);
correct_rfm2=zeros(num_exp,1);
correct_pc_partial=zeros(num_exp,1);
correct_pc_hsic=zeros(num_exp,1);

for ex=1:num_exp
    tic
    ex
    
    %X=rand(samplesize,1)-0.5;
    %Y=X+rand(samplesize,1)-0.5;
    %Z=1.5*exp(-2*(X.^2))-Y+rand(samplesize,1)-0.5;
    %W=(Y+2).^2+2*Z+rand(samplesize,1)-0.5;

    a=sign(randn(5,1)).*(1*rand(5,1)+1*ones(5,1));
    X=rand(samplesize,1)-0.5;
    Y=a(1)*X+rand(samplesize,1)-0.5;
    Z=a(2)*exp(-2*(X.^2))+a(3)*Y+rand(samplesize,1)-0.5;
    W=a(4)*(Y+2).^2+a(5)*Z+rand(samplesize,1)-0.5;

    [causalorder_final,num_diff_dags(ex),dags,residuals_final] =find_all_dags2([X,Y,Z,W],'train_linear',[],'indtest_hsic',[],alpha);
    [causalorder_final2,num_diff_dags2(ex),dags2,residuals_final2] =find_all_dags2([X,Y,Z,W],'train_gp',[],'indtest_hsic',[],alpha);
        
    pars.width=0;pars.perm=500;
    %dag_rob_hsic=pc([X Y Z W],'indtest_kun',pars,2,alpha);
    dag_rob_hsic=pc([X Y Z W],'indtest_hsic',pars,2,alpha);
    dag_rob_partial=pc([X Y Z W],'indtest_corr',pars,2,alpha);
    
    if check_markov_equiv(dag_rob_hsic,true_dag2)==1
        correct_pc_hsic(ex)=1;
    end
    if check_markov_equiv(dag_rob_partial,true_dag2)==1
        correct_pc_partial(ex)=1;
    end
 
    if num_diff_dags(ex)==1
        if sum(sum(dags{1}==true_dag))==16
            correct_rfm(ex)=1;
        else
            wrong_rfm(ex)=1;
            wrong_dag{ex}=dags{1};
        end
    end

    if num_diff_dags2(ex)==1
        if sum(sum(dags2{1}==true_dag))==16
            correct_rfm2(ex)=1;
        else
            wrong_rfm2(ex)=1;
            wrong_dag2{ex}=dags2{1};
        end
    end

    toc
    sum([correct_pc_hsic, correct_pc_partial, correct_rfm, wrong_rfm, correct_rfm2, wrong_rfm2])
end

[correct_pc_hsic, correct_pc_partial, correct_rfm, wrong_rfm, correct_rfm2, wrong_rfm2]
sum([correct_pc_hsic, correct_pc_partial, correct_rfm, wrong_rfm, correct_rfm2, wrong_rfm2])



