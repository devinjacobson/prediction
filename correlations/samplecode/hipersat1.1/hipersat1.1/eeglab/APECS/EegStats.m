function[kurt, meanKurt, stdKurt, negent, meanNegent, stdNegent] = EegStats(i, numGoodCh, numGoodObs, ...
	kurt, meanKurt, stdKurt, negent, meanNegent, stdNegent);
	
global s;

randn('state', 0);

kurt(1:numGoodCh, i) = ((mean(s .^ 4, 2) - 3) .^ 2) ./ 100;
meanKurt(i)          = mean(kurt(1:numGoodCh, i));
stdKurt(i)           = std(kurt(1:numGoodCh, i), 1);

negent(1:numGoodCh, i) = ((mean(log(cosh(s)), 2) - mean(log(cosh(randn(numGoodCh, numGoodObs))), 2)) .^ 2) * 100;
meanNegent(i)          = mean(negent(1:numGoodCh, i));
stdNegent(i)           = std(negent(1:numGoodCh, i), 1);
