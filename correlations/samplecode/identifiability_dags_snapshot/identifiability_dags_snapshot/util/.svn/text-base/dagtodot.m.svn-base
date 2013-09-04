function dagtodot(A,outfile,labels)
% function dagtodot(A,outfile,labels)
%
% Converts a (directed) adjacency matrix to a .dot file with optional node labels
% The resulting .dot file can be rendered using graphviz 
% (e.g., "dot -Tps outfile > outfile.eps")
%
% Input:  A:        adjacency matrix, where A(i,j)~=0 means i->j
%         outfile:  filename of .dot file that will be written
%         labels:   cell array of node labels (optional)
%
% Copyright (c) 2011  Joris Mooij  [joris.mooij@tuebingen.mpg.de]
% All rights reserved.  See the file COPYING for license terms.

  if nargin < 3
    labels=[];
  end
  os=fopen(outfile,'w');
  N = size(A,1);
  fprintf(os,'digraph G {\n');
  if ~isempty(labels)
    for i=1:N
      fprintf(os,'  %d [label=%s];\n',i,labels{i});
    end
  end
  for i=1:N
    for j=1:N
      if A(i,j)~=0
        fprintf(os,'  %d->%d',i,j);
        if A(i,j)>0 && A(i,j)<=1
          fprintf(os,sprintf('[color=grey%d]',round((1-A(i,j))*100)));
        end
        fprintf(os,';\n');
      end
    end
  end
  fprintf(os,'};\n');
  fclose(os);
end
