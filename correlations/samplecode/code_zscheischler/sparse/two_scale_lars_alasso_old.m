% given X and Y, suppose we would like to find the transformation matrix
% from X to Y
function A = two_scale_lars_alasso(X,Y)
% Input: X is n-by-k, and Y is m-by-k.
% Output: A is m-by-n.

[n,k] = size(X);
[m,k] = size(Y);
d1 = floor(3*k/5);
A = zeros(m,n);
for i = 1:m
    % step 1: LARS for pre-selection of the features
    beta = lars(X', Y(i,:)', 'lars', -1 * d1);
    % step 2: Quick IC (BIC-like Adaptive Lasso) for further model
    % selection
    Ind = find(beta(d1,:));
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