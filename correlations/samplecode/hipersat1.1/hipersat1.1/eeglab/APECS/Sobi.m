function [W] = Sobi(x, tau);

%   sobi.m

%       seungjin@postech.ac.kr
%
%       Last updated:
%       October 12 2004 (2005-03-30 RMF)

%       W: estimate of the inverse of mixing matrix
%       x: input data matrix (m x n)
%       tau: vector of time-lags

[m n] = size(x);
tol = 10^(-8.0);

if isempty(tau)
    
    tau = 1 : min(100, ceil(n/3));
       
end

numTau = length(tau);

% Compute time-delayed covariance matrices

CovX = zeros(m, numTau * m);

for i = 1:numTau
    
    ii = (i - 1) * m + 1 : i * m;
    CovX(:,ii) = stdcov(x, tau(i), n);
    
end

% Joint diagonalization

[W D] = rjd(CovX, tol);




function [C] = stdcov(x, tau, n);

%   stdcov.m
%
%       seungjin@postech.ac.kr
%
%       Last updated:
%       February 14 2001 (2005-03-30 RMF)
%
%       Function for calculating time-delayed covariance
%       matrix: symmetric version
%
%       C: time-delayed covariance matrix (symmetric part)
%       x: input data matrix
%       tau: current time lag
%       [m n] = size(x);

%%%%%%%%%%% Shift time axis + mean correct %%%%%%%%%%%%
%  
%C = ( x(:,1:n-tau) * x(:,tau+1:n)' ) ./ (n - tau);
%
%m1 = mean(x(:,1:n-tau), 2);
%m2 = mean(x(:,tau+1:n), 2);
%
%C = C - m1 * m2';
%
%%%%%% Symmetrize time-delayed covariance matrix %%%%%%
%
%C = 1/2 * (C + C');
%
%%%%%%%%%%%%%%%%%%%% Original Code %%%%%%%%%%%%%%%%%%%%
%
% [m n] = size(x);
% m1 = zeros(m,1);
% m2 = zeros(m,1);
%
% for i = 1:m
%
%    m1(i) = mean(x(i,1:n-tau));
%    m2(i) = mean(x(i,tau+1:n));
%
% end
%
% R = ( x(:,1:n-tau) * x(:,tau+1:n)' ) ./ (n - tau);
% C = R - m1 * m2';
% C = 1/2 * (C + C');
%
%%%%%%%%%%%%%%%%%%%%%%%% EEGLAB %%%%%%%%%%%%%%%%%%%%%%%
%
C = ( x(:,tau+1:n) * x(:,1:n-tau)' ) ./ (n - tau);
%
C = norm(C, 'fro') * C;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




function [W, A] = rjd(A, threshold);

%***************************************
% joint diagonalization (possibly
% approximate) of REAL matrices.
%***************************************
% This function minimizes a joint diagonality criterion
% through n matrices of size m by m.
%
% Input :
% * the  m by nm matrix A is the concatenation of n matrices
%   with size m by m. We denote A = [ A1 A2 .... An ]
% * threshold is an optional small number (typically = 1.0e-8 see below).
%
% Output :
% * W is a m by m orthogonal matrix.
% * A (overwritten) is now the concatenation of (quasi)diagonal m by m matrices:
%   D = [ D1 D2 ... Dn ] where A1 = W*D1*W',..., An =W*Dn*W'.
%
% The algorithm finds an orthogonal matrix W
% such that the matrices D1,...,Dn are as diagonal as possible,
% providing a kind of `average eigen-structure' shared
% by the matrices A1,..., An.
% If the matrices A1,..., An do have an exact common eigen-structure,
% i.e. a common othonormal set of eigenvectors, then the algorithm finds it.
% The eigenvectors THEN are the column vectors of W
% and D1, ...,Dn are diagonal matrices.
% 
% The algorithm implements a properly extended Jacobi algorithm.
% The algorithm stops when all the Givens rotations in a sweep
% have sines smaller than 'threshold'.
% In many applications, the notion of approximate joint diagonalization
% is ad hoc and very small values of threshold do not make sense
% because the diagonality criterion itself is ad hoc.
% Hence, it is often not necessary to push the accuracy of
% the rotation matrix W to the machine precision.
% It is defaulted here to the square root of the machine precision.
% 
%
% Author : Jean-Francois Cardoso. cardoso@sig.enst.fr
% This software is for non commercial use only.
% It is freeware but not in the public domain.
% A version for the complex case is available
% upon request at cardoso@sig.enst.fr
%-----------------------------------------------------
% Two References:
%
% The algorithm is explained in:
%
%@article{SC-siam,
%   HTML =	"ftp://sig.enst.fr/pub/jfc/Papers/siam_note.ps.gz",
%   author = "Jean-Fran\c{c}ois Cardoso and Antoine Souloumiac",
%   journal = "{SIAM} J. Mat. Anal. Appl.",
%   title = "Jacobi angles for simultaneous diagonalization",
%   pages = "161--164",
%   volume = "17",
%   number = "1",
%   month = jan,
%   year = {1995}}
%
%  The perturbation analysis is described in
%
%@techreport{PertDJ,
%   author = "{J.F. Cardoso}",
%   HTML =	"ftp://sig.enst.fr/pub/jfc/Papers/joint_diag_pert_an.ps",
%   institution = "T\'{e}l\'{e}com {P}aris",
%   title = "Perturbation of joint diagonalizers. Ref\# 94D027",
%   year = "1994" }
%
%
%

[m, nm] = size(A);

W = eye(m);

encore = 1;

while encore
    
    encore = 0;
    
    for p = 1 : m - 1
        
        for q = p + 1 : m
            
            %%%Computation of Givens rotations
        
            g = [ A(p,p:m:nm) - A(q,q:m:nm) ; A(p,q:m:nm) + A(q,p:m:nm) ];
            g = g * g';
            ton = g(1,1) - g(2,2);
            toff = g(1,2) + g(2,1);
            theta = 0.5 * atan2( toff , ton + sqrt(ton * ton + toff * toff) );
            c = cos(theta);
            s = sin(theta);
            encore = encore | (abs(s) > threshold);
        
            %%%Update of the A and W matrices 
        
            if (abs(s) > threshold)
            
                Mp = A(:,p:m:nm);
                Mq = A(:,q:m:nm);
                A(:,p:m:nm) = c * Mp + s * Mq;
                A(:,q:m:nm) = c * Mq - s * Mp;
                rowp = A(p,:);
                rowq = A(q,:);
                A(p,:) = c * rowp + s * rowq;
                A(q,:) = c * rowq - s * rowp;
                temp = W(:,p);
                W(:,p) = c * W(:,p) + s * W(:,q);
                W(:,q) = c * W(:,q) - s * temp;
            
            end
        
        end
        
    end
    
end

W = W';

%%%%%%% A Is Overwritten by Quasidiagonal D %%%%%%%%
