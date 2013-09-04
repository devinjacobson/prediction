function viewgraph(A,labels)
% function viewgraph(A,labels)
%
% Visualizes (directed) adjacency matrix with optional node labels;
% assumes that dot (graphviz) and gv are installed.
%
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  dagtodot(A,'.viewgraph.dot.tmp',labels);
  system('dot -T ps .viewgraph.dot.tmp | gv -');
  system('rm .viewgraph.dot.tmp');
end
