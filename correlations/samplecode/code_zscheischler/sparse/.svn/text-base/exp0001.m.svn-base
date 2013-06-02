% test Kun's sparcity method on simulated sparse data

clear all
alpha = 0.01;
N = 50;
% dim=[10,16,22,28,35,40,50,70];
dim=[10,25,40];
nl = 1;
eps = 0.0;

for i=dim
    i
    for ex=1:N
        [X, Y, A] = highdimmodel_sparse(i,i,floor(i/2),nl);
        [pval1(ex) pval2(ex)] = significance_sparse(X, Y);
%         Cx = cov(double(X)');
%         Cy = cov(double(Y)');
%         A1 = two_scale_lars_alasso(X,Y);
%         A2 = two_scale_lars_alasso(Y,X);
%         d1(ex) = log(trace(A1*Cx*A1')/i)-log(trace(A1*A1')/i)-log(trace(Cx)/i);
%         d2(ex) = log(trace(A2*Cy*A2')/i)-log(trace(A2*A2')/i)-log(trace(Cy)/i);
    end
    right(i) = sum(pval1 < alpha) + sum(pval1 > (1-alpha));
    wrong(i) = sum(pval2 < alpha) + sum(pval2 > (1-alpha));
   % right(i) = sum(abs(d2)>(abs(d1) + eps));
   % wrong(i) = sum(abs(d1)>(abs(d2) + eps));
end

%% plotting
figure

axes('LineWidth',5,'FontSize',16);
%    subplot(1,1,j)
plot(dim,right(dim)/N*100,'g','LineWidth',5)
hold on
plot(dim,wrong(dim)/N*100,'r','LineWidth',5)
legend('right','wrong','location','East')
ylabel('% of p-values below 0.01')
xlabel('dimension')
