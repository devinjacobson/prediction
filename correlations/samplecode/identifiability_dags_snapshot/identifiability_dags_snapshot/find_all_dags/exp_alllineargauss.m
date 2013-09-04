%idee: dag: faithfull, non-generic (ueberall)
%ergebnis: equivalenzklasse und alle markov graphen!?  
%
%   1    2
%  /  \ /
% 3 -> 4
% 
% Copyright (c) 2010-2011  Jonas Peters  [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms. 
 

true_dag=[0 0 1 1;0 0 0 1;0 0 0 1; 0 0 0 0];
true_dag2=-1*[0 0 1 1;0 0 0 1;0 0 0 1; 0 0 0 0];

samplesize=400;
alpha=0.05;
    
wrong_rfm=zeros(100,1);
correct_rfm=zeros(100,1);
correct_pc=zeros(100,1);

for exp=1:100

    N_X=randn(samplesize,1);
    N_Y=randn(samplesize,1);
    N_Z=randn(samplesize,1);
    N_W=randn(samplesize,1);
    
    X=0.5*N_X;
    Y=0.5*N_Y;
    Z=-X+0.1*N_Z;
    W=1.5*X-2*Y+Z+0.1*N_W;

    
    pars.width=0;pars.perm=500;
    dag_rob=pc([X Y Z W],'indtest_corr',pars,2,alpha);
    
    [causalorder_final,num_diff_dags,dags,residuals_final] =find_all_dags2([X,Y,Z,W],'train_linear',[],'indtest_corr',[],alpha);
    for i=1:num_diff_dags
        num_edges(i)=sum(sum(dags{i}));
    end
    if num_diff_dags>0
        [a b]=sort(num_edges);
        mindags=b(a==min(a)); %contains all indices for which dags{..} has the minimal number of edges

        for i=1:length(mindags)
            correct_mec(i)=check_markov_equiv(-1*dags{mindags(i)},true_dag2);
            causalorder_final{mindags(i)}
            dags{mindags(i)}
        end
        if sum(correct_mec)==length(mindags)
            correct_rfm(exp)=1;
        else
            for i=1:length(mindags)
                same_mec(i)=check_markov_equiv(-1*dags{mindags(i)},dags{mindags(1)});
            end
            if sum(same_mec)==length(mindags)
                wrong_rfm(exp)=1;
            end
        end
    end
            
    if check_markov_equiv(dag_rob, true_dag2)==1
        correct_pc(exp)=1;
    end
    clear correct_mec num_edges same_mec;
    
end

sum([correct_pc, correct_rfm, wrong_rfm])
