% given X and Y, suppose we would like to find the transformation matrix
% from X to Y
function A = two_scale_lars_alasso(X,Y)
% Input: X is n-by-k, and Y is m-by-k.
% Output: A is m-by-n.

[n,k] = size(X);
[m,k] = size(Y);
d1 = floor(2*k/3);
A = zeros(m,n);
Xn = diag(1./ sqrt(sum(X'.^2)) ) * X;
for i = 1:m
    % step 1: LARS for pre-selection of the features
    %     beta = lars(Xn', Y(i,:)', 'lars', -1 * d1);% old code; seeming to be wrong
    stopCriterion = {};
    stopCriterion{1,1}='maxKernels';
    stopCriterion{1,2}=d1;  % Stop when size of active set is 100.
    sol = lars(Y(i,:)', Xn', [], 'lars', stopCriterion);
    % step 2: Quick IC (BIC-like Adaptive Lasso) for further model
    % selection
%     Ind = find(beta(d1,:));
    Ind = sol(1,d1+1).active_set;
    %     % if we would like to find a consistent esitimate of A under the
    %     % sparsity condition:
    %     [beta_al2, beta_new_n2, beta2_al2, beta2_new_n2] =...
    %         betaAlasso_grad_2step(X(Ind,:),Y(i,:),0,log(k));
    %     A(i,Ind) = beta_al2';
    % otherwise we just find the estimate of A in the reduced space:
    A(i,Ind) = Y(i,:) * X(Ind,:)' * inv(X(Ind,:) * X(Ind,:)');
    
    fprintf('.');
    if ~mod(i,20)
        fprintf('%d', i);
    end
end
fprintf('\n');