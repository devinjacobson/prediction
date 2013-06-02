function graphtodot(A,outfile,labels)
% function graphtodot(A,outfile,labels)
%
% Converts a symmetric adjacency matrix to a .dot file with optional node 
% labels. The .dot file can be rendered using graphviz 
% (e.g., "neato -Tps outfile > outfile.eps")
%
% Input:  A:        adjacency matrix, where A(i,j)~=0 means i->j
%         outfile:  filename of .dot file that will be written
%         labels:   cell array of node labels (optional)
%
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  if ~exist('labels')
    labels=[];
  end
  N = size(A,1);
  os = fopen(outfile,'w');
  fprintf(os,'graph G {\n');
  if ~isempty(labels)
    for i=1:N
      fprintf(os,'  %d [label=%s];\n',i,labels{i});
    end
  end
  for i=1:N
    for j=i+1:N
      if A(i,j)~=0 || A(j,i)~=0
	fprintf(os,'  %d--%d;\n',i,j);
      end
    end
  end
  fprintf(os,'};\n');
  fclose(os);
end
