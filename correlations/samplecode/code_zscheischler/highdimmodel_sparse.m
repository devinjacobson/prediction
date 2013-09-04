function [Xdata, Ydata, A, Cx, Ce, Edata] = highdimmodel_sparse(m,n,nsamples,noiselevel, zerolevel)

%--- Generate a sparse random model ---
% Y=AX+E with certain noiselevel
% uses unimat(n) (creates a uniformly distributed random rotation matrix)

% Input covariance matrix Cx is randomly selected

Bx = randn(m,m);
Cx = Bx * Bx';

% Random transformation matrix A 

% if m<n
%     Atmp = diag(randn(m,1)); 
%     Atmp(:,m+1:n) = zeros(m,n-m);
%     A = unimat(m) * Atmp * unimat(n);
% elseif m>n
%     Atmp = diag(randn(n,1));
%     Atmp(n+1:m,:) = zeros(m-n,n);
%     A = unimat(m) * Atmp * unimat(n);
% else
A = unimat(m) * diag((-0+1*randn(m,1))) * unimat(n) ;
% end
% A=zeros(m,n);
if nargin < 5
    K = floor(0.8 * n);
else
    K = floor(zerolevel * n); % number of non-zero entries in each row
end

for i=1:n
    %     Arow = rand(1,n);
    %     A(i,Arow < 0.85) = 0;
    perm1 = randperm(n);
    %     A(i, perm1(1:K)) = randn(1,K);
    A(i, perm1(1:K)) = 0;
end
%Azeros = rand(m,n);
%A(Azeros<0.7) = 0;


% Noise covariance matrix Ce is randomly generated
Be = randn(m,m);
Ce = Be * Be';
%Ce = noiselevel^2 * Be * Be';

%--- Generate the sample data ---

% The cause X and the noise E are gaussian with the above selected
% covariance matrices

% Xdata = Bx * (randn(n,nsamples));
Xdata =  (randn(n,nsamples));

% isotropic noise
Edata = noiselevel * ones(n,n) * randn(m,nsamples);
%c = 10*randn(m,1);

% The effect Y is given by the linear transform of X with additive
% independent noise
%A(:,2:2:end)=0;
Ydata = (A * Xdata) + Edata; %+ repmat(c,1,nsamples);
%Axdata = (A * Xdata);

