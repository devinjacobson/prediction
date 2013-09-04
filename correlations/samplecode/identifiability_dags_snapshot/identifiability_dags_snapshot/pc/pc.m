function g = pc(X,cond_ind_test,pars,maxFanIn,alpha)
% function g = pc(X,cond_ind_test,pars,maxFanIn,alpha)
% applies the PC algorithm (including Meek's Rule)
%
% INPUTS:
% X             - n x p matrix of n observation of p variables 
% alpha         - significance level for conditional independence tests
% cond_ind_test - function handle that computes p-values for X ind. Y given Z: 
%                 (p_val = cond_ind_test(X, Y, Z, pars))
% pars          - contains some parameters for the conditional independence test
% maxFanIn      - on how many variables do we condition at most?
%
% OUTPUTS:
% g             - p x p matrix representing a mixed graph where g(i,j) = -1 indicates
%                 i -> j and g(i,j)=g(j,i)=1 indicates i - j
%
% EXAMPLE:
% ==========
% % generate data from the model
% %      1   2
% %    /  \ /
% %   3 -> 4
% % PC recovers the true Markov Equivalence Class
% % (arrows pointing downwards)
% samplesize=1000;
% alpha=0.05;
% X=rand(samplesize,1)-0.5;
% Y=rand(samplesize,1)-0.5;
% Z=0.5*X+rand(samplesize,1)-0.5;
% W=X+1.5*Z-1.9*Y+rand(samplesize,1)-0.5;
% dag=pc([X Y Z W],'indtest_corr',[],2,alpha);
% dag
% ==========
% 
%Copyright (C) 
%               2010-2011 Jonas Peters
%		2010-2011 Robert Tillman 
%
%    This file is part of pc.
%
%    discrete_anm is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    discrete_anm is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with discrete_anm.  If not, see <http://www.gnu.org/licenses/>.


% number of variables
n = size(X,2);

% construct complete (fully connected) graph
g = ones(n,n)-eye(n);

% witness set
witness = zeros(n,n,n);

% stores the combinations that were already tested (with rejected
% independence)
already_checked=[];

% find graph skeleton
for s=0:(maxFanIn+1) % iteratively increase size of conditioning setu
    for i=1:n
        
        % nodes adjacent to i
        adjSet = find(g(i,:)~=0);
        if (length(adjSet)<=s)
            continue;
        end
        
        % test whether i ind j | s
        for j=adjSet
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % if (j<i)
            %     continue;
            % end
            % Jonas Peters (7.3.2011): This was a bug!?
            % The problem is that adjSet need not to be the same for i and j.
            % Then it sometimes happens that for adjSet_i with i<j we cannot find a suitable
            % subset to separate X_i and X_j, but in adjSet_j we could.
            % Example (arrows pointing downwards).
            % X1    X2   X3  
            %  \   /  \ /
            %    Y1   Y2
            %     \   /
            %       Z
            % At some point adjSet_X1 = {Y1, Z}
            % and adjSet_Z = {X1, X3, Y1, Y2}
            % We cannot separate X1 and Z using adjSet_Z.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        
            % unconditional test
            if (s==0)
                % if independent
                if ismember([i,j,zeros(1,n-2)],already_checked,'rows')
                    p_val=0;
                    fprintf('%d notind %d has already been checked\n', i,j);
                else
                    p_val = feval(cond_ind_test, X(:,i), X(:,j), [], pars);
                    if  p_val > alpha
                        fprintf('%d ind %d with p-value %d\n', i,j,p_val);
                        g(i,j)=0;
                        g(j,i)=0;
                    else
                        already_checked=[already_checked;j,i,zeros(1,n-2)];
                        fprintf('%d notind %d with p-value %d\n', i,j,p_val);
                    end
                end
                continue;
            end
            
            % conditional test
            combs = nchoosek(adjSet(adjSet~=j),s);
            for k=1:size(combs,1);
                condSet = combs(k,:);
                % if independent
                condSet_string='{';
                for i2=1:(length(condSet)-1)
                    condSet_string=[condSet_string,int2str(condSet(i2)),', '];
                end
                condSet_string=[condSet_string,int2str(condSet(length(condSet))),'}'];
                if ismember([i,j,condSet,zeros(1,n-2-length(condSet))],already_checked,'rows')
                    p_val=0;
                    fprintf('%d notind %d | %s has already been checked\n', i,j,condSet_string);
                else
                    p_val = feval(cond_ind_test, X(:,i), X(:,j), X(:,condSet), pars);
                    if p_val > alpha
                        fprintf('%d ind %d | %s with p-value %d\n', i,j,condSet_string, p_val);
                        witness(i,j,condSet) = ones(1,s);
                        witness(j,i,condSet) = ones(1,s);
                        g(i,j)=0;
                        g(j,i)=0;
                    else
                        fprintf('%d notind %d | %s with p-value %d\n', i,j,condSet_string, p_val);
                        already_checked=[already_checked;j,i,condSet,zeros(1,n-2-length(condSet))];
                    end
                end
            end
        end
    end
end

% mark immoralities
adjMatrix = g;
for i=1:n
    adj = find(adjMatrix(:,i)==1);
    c = length(adj);
    for j=1:(c-1)
        for k=(j+1):c
            
            % check if moral
            if (adjMatrix(adj(j), adj(k))~=0)
                continue;
            end
            
            % check to see if in witness set
            if (witness(adj(j), adj(k), i)==1)
                continue;
            end
            
            % orient immorality
            g(adj(j),i)=-1;
            g(i,adj(j))=0;
            g(adj(k),i)=-1;
            g(i,adj(k))=0;
            
        end
    end
end

% meeks rules - adapted from version in BNT
g = meeks(g,adjMatrix);
