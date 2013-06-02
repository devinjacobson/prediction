function [goodCh, numGoodCh] = unWhiten(i, meanEeg, Sph, A, goodCh, numGoodCh, goodObs, numGoodObs, numIC);

global x s;

% PCA dimension expansion ----------------------------------------------------------

if ~isempty(numIC)

	% Do PCA expansion - May change # good channels
	
end

% Unwhiten & Uncenter the EEG ------------------------------------------------------

x(goodCh{i}, goodObs{i}) = inv(Sph) * x(goodCh{i}, goodObs{i}) + repmat(meanEeg, 1, numGoodObs(i));

% Uncenter the IC ------------------------------------------------------------------

s = s + inv(A) * repmat(meanEeg, 1, numGoodObs(i));

