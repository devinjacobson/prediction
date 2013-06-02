% This MatLab script runs all experiments reported in
% J. Mooij, D. Janzing, T. Heskes, B. Schölkopf:
% "On Causal Discovery with Cyclic Additive Noise Models"
% Advances in Neural Information Processing Systems 24 (NIPS*2011)
%
% Copyright (c) 2011  Joris Mooij  <j.mooij@cs.ru.nl>
% All rights reserved.  See the file LICENSE for license terms.

outputdir = 'output/';
for i=1:6
  experiment(i,500,outputdir);
end
