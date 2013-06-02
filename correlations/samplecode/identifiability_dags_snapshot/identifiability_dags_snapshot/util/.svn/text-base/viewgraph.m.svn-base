function viewgraph(A,labels)
% function viewgraph(A,labels)
%
% Visualizes symmetric adjacency matrix with optional node labels;
% assumes that neato (graphviz) and gv are installed.
%
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  graphtodot(A,'.viewgraph.dot.tmp',labels);
  system('neato -T ps .viewgraph.dot.tmp | gv -');
  system('rm .viewgraph.dot.tmp');
end
