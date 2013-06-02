%jonas 2010-11-17
%idea: how often is faithfulness violated?
%
%      X1    
%     /  \ 
%    X2   X3
%     \   /
%       X4
%
% Copyright (c) 2010-2011  Jonas Peters  [jonas.peters@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms. 


all_cond_ind=[2 3 1; 3 2 1];
all_partind=[1 4];
all_ind=[];

num_exp=500;
samplevec=[100 500 1000 5000 10000 50000 100000 500000];
alpha=0.05;
pars.alpha=alpha;
pars.width=0;

%gapvec=0.01:0.02:0.3;
gapvec=0.1:0.2:2.0;

for i1=1:length(samplevec)
    samples=samplevec(i1);
    gap=gapvec(1);
    seq=1:4;
    non_faithful_theo0=zeros(num_exp,1);
    non_faithful_emp0=zeros(num_exp,1);
    non_faithful_theo1=zeros(num_exp,1);
    non_faithful_emp1=zeros(num_exp,1);
    non_faithful_theo2=zeros(num_exp,1);
    non_faithful_emp2=zeros(num_exp,1);
    for exp=1:num_exp

        corr_emp=zeros(4,4);
        corr_theo=zeros(4,4);

        coef_noise=0.5*rand(4,1);
        coef=sign(randn(4,1)).*(5*rand(4,1)+gap);
    %     coef=[1.5 0.9 -0.3 0.8];
    %     coef_noise=[.5 .5 .5 .5];
        x=[];
        x(:,1)=coef_noise(1)*randn(samples,1);
        x(:,2)=coef(1)*x(:,1)+coef_noise(2)*randn(samples,1);
        x(:,3)=coef(2)*x(:,1)+coef_noise(3)*randn(samples,1);
        x(:,4)=coef(3)*x(:,2)+coef(4)*x(:,3)+coef_noise(4)*randn(samples,1);

        var_theo(1)=coef_noise(1)^2;
        var_theo(2)=coef(1)^2*var_theo(1)+coef_noise(2)^2;
        var_theo(3)=coef(2)^2*var_theo(1)+coef_noise(3)^2;
        corr_theo(1,2)=coef(1)*sqrt(var_theo(1))/sqrt(var_theo(2));
        corr_theo(1,3)=coef(2)*sqrt(var_theo(1))/sqrt(var_theo(3));
        corr_theo(2,3)=coef(1)*coef(2)*var_theo(1)/sqrt(var_theo(2)*var_theo(3));
        var_theo(4)=coef(3)^2*var_theo(2)+coef(4)^2*var_theo(3)+coef_noise(4)^2+2*coef(3)*coef(4)*sqrt(var_theo(2)*var_theo(3))*corr_theo(2,3);
        corr_theo(1,4)=(coef(3)*sqrt(var_theo(2))*corr_theo(1,2)+sqrt(var_theo(3))*coef(4)*corr_theo(1,3))/sqrt(var_theo(4));
        corr_theo(2,4)=(coef(3)*sqrt(var_theo(2))+coef(4)*sqrt(var_theo(3))*corr_theo(2,3))/sqrt(var_theo(4));
        corr_theo(3,4)=(coef(4)*sqrt(var_theo(3))+coef(3)*sqrt(var_theo(2))*corr_theo(2,3))/sqrt(var_theo(4));


        corr_theo=corr_theo+corr_theo';
        corr_emp=mycorr(x);
%        corr_emp=corr(x);

%	corr_theo
%	corr_emp
%	pause

        % [var_theo; var(x)]

        %test all partial correlations given one
        for k=1:4
	    partcorr_theo(:,:,k)=-zeros(4,4);
	    partcorr_emp(:,:,k)=-zeros(4,4);
        end
	for i=1:3
            for j=(i+1):4
                for k=1:4
                    if length(unique([i,j,k]))==3
                        [partcorr_emp(i,j,k) pval1(i,j,k)]=mypartialcorr(x(:,i),x(:,j),x(:,k));
                        partcorr_theo(i,j,k)=(corr_theo(i,j)-corr_theo(i,k)*corr_theo(j,k))/(sqrt(1-corr_theo(i,k)^2)*sqrt(1-corr_theo(j,k)^2));
                        if (pval1(i,j,k)>alpha)|(partcorr_theo(i,j,k)==0)
                            if ~ismember([i j k],all_cond_ind,'rows')
                                fprintf('found something unfaithful at ')
                                fprintf('variables %i and %i given %i \n',i,j,k);
                                fprintf('theor. corr.: %d, empir. corr.: %d, empir. p-value: %d. \n \n',partcorr_theo(i,j,k), partcorr_emp(i,j,k),pval1(i,j,k));
                                if partcorr_theo(i,j,k)==0
                                    non_faithful_theo1(exp)=1;
                                end
                                if pval1(i,j,k)>alpha
                                    non_faithful_emp1(exp)=1;
                                end
                            end
                        end
                    end
                end
            end
        end
        for k=1:4
            partcorr_theo(:,:,k)=partcorr_theo(:,:,k)'+partcorr_theo(:,:,k);
        end
	partcorr2_theo=-ones(4,4);
        %test all partial correlations given two 
        for i=1:3
            for j=(i+1):4
                cond_set=seq(seq~=i&seq~=j);
                [a pval2(i,j)]=mypartialcorr(x(:,i),x(:,j),x(:,cond_set));
                partcorr2_theo(i,j)=(partcorr_theo(i,j,cond_set(1))-partcorr_theo(i,cond_set(2),cond_set(1))*partcorr_theo(j,cond_set(2),cond_set(1)))/(sqrt(1-partcorr_theo(i,cond_set(2),cond_set(1))^2)*sqrt(1-partcorr_theo(j,cond_set(2),cond_set(1))^2));
    %             test(i,j)=(partcorr_theo(i,j,cond_set(2))-partcorr_theo(i,cond_set(1),cond_set(2))*partcorr_theo(j,cond_set(1),cond_set(2)))/(sqrt(1-partcorr_theo(i,cond_set(1),cond_set(2))^2)*sqrt(1-partcorr_theo(j,cond_set(1),cond_set(2))^2));
                if (pval2(i,j)>alpha)|(partcorr2_theo(i,j)==0)
                    if ~ismember([i j],all_partind,'rows')
                        fprintf('found something unfaithful at ')
                        fprintf('variables %i and %i given both ohters \n',i,j);
                        fprintf('theor. corr.: %d, empir. corr.: %d, emp. p-value: %d. \n \n',partcorr2_theo(i,j), a, pval2(i,j));
                        if partcorr2_theo(i,j)==0
                            non_faithful_theo2(exp)=1;
                        end
                        if pval2(i,j)>alpha
                            non_faithful_emp2(exp)=1;
                        end
                    end
                end
            end
        end


        %test all correlations
        for i=1:3
            for j=(i+1):4
                [a pval0(i,j)]=mycorr(x(:,i),x(:,j));
                if (pval0(i,j)>alpha)|(corr_theo(i,j)==0)
                    if ~ismember([i j],all_ind,'rows')
                        fprintf('found something unfaithful at ')
                        fprintf('variables %i and %i \n',i,j);
                        fprintf('theor. corr.: %d, empir. corr.: %d, emp. p-value: %d. \n \n',corr_theo(i,j), a, pval0(i,j));
                        if corr_theo(i,j)==0
                            non_faithful_theo0(exp)=1;
                        end
                        if pval0(i,j)>alpha
                            non_faithful_emp0(exp)=1;
                        end
                    end
                end
            end
        end



    end

    
    nft0(i1)=sum(non_faithful_theo0);
    nft1(i1)=sum(non_faithful_theo1);
    nft2(i1)=sum(non_faithful_theo2);
    nfe0(i1)=sum(non_faithful_emp0);
    nfe1(i1)=sum(non_faithful_emp1);
    nfe2(i1)=sum(non_faithful_emp2);
    nft_total(i1)=sum(max([non_faithful_theo0';non_faithful_theo1';non_faithful_theo2']));
    nfe_total(i1)=sum(max([non_faithful_emp0';non_faithful_emp1';non_faithful_emp2']));
    
    fprintf('unfaithful correlations, conditioned on ...\n');
    fprintf('0 variables: %d theoretical, %d empirical \n', sum(non_faithful_theo0), sum(non_faithful_emp0));
    fprintf('1 variable: %d theoretical, %d empirical \n', sum(non_faithful_theo1), sum(non_faithful_emp1));
    fprintf('2 variables: %d theoretical, %d empirical \n', sum(non_faithful_theo2), sum(non_faithful_emp2));

    fprintf('in total: %d theoretical, %d empirical \n', nft_total(i1), nfe_total(i1));

end


fontsizee = 23;
figure1 = figure('XVisual',...
    '0x23 (TrueColor, depth 32, RGB mask 0xff0000 0xff00 0x00ff)');

% Create axes
axes1 = axes('Parent',figure1,'XMinorTick','on','FontSize',fontsizee);
plot(samplevec, nfe_total/num_exp,'-^','LineWidth',4, 'MarkerSize',14,'Color','k');
hold on
plot(samplevec, nfe2/num_exp,'--*', 'LineWidth',2,'MarkerSize',14,'Color',[0.502 0.502 0.502]);
plot(samplevec, nfe1/num_exp,'--o', 'LineWidth',2,'MarkerSize',14,'Color',[0.502 0.502 0.502]);
plot(samplevec, nfe0/num_exp,'--sq', 'LineWidth',2,'MarkerSize',14,'Color',[0.502 0.502 0.502]);
%plot(samplevec, nft_total,'-bx','LineWidth',3);
xlabel('sample size', 'FontSize',fontsizee)
ylabel(['proportion how often' ,sprintf('\n'), 'faithfulness was missed'],'FontSize',fontsizee)
%legend('emp. correlations','emp. partial correlations (given one var)', 'emp. partial correlations (given two vars)', 'in total (emp.)', 'in total (theor.)') 
legend('in total', 'due to partial corr. (given two vars)', 'due to partial corr. (given one var)', 'due to correlations') 

