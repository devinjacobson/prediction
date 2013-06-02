function [meanEeg, Sph, goodCh, numGoodCh] = whiten(i, numIC, goodCh, numGoodCh, goodObs, numGoodObs);

global x

% Compute mean of each data row ------------------------------------------------

meanEeg = mean(x(goodCh{i}, goodObs{i}), 2);

% Compute eigenvectors and eigenvalues of data's covariance matrix -------------

[V, D] = eig(cov(x(goodCh{i}, goodObs{i})', 1));

% PCA dimension reduction ------------------------------------------------------

if ~isempty(numIC)

	% Do PCA Reduction - May change # good channels
	
end
            
% Compute Sphering matrix, Sph -------------------------------------------------

Sph = inv(sqrt(D)) * V';

% Center and whiten data -------------------------------------------------------

x(goodCh{i}, goodObs{i}) = Sph * (x(goodCh{i}, goodObs{i}) - repmat(meanEeg, 1, numGoodObs(i)));
