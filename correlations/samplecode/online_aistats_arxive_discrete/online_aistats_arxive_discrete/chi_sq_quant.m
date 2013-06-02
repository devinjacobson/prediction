function [result T]=chi_sq_quant(x,y,num_states_x,num_states_y)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%-please cite
% Jonas Peters, Dominik Janzing, Bernhard Schoelkopf (2010): Identifying Cause and Effect on Discrete Data using Additive Noise Models, 
% in Y.W. Teh and M. Titterington (Eds.), Proceedings of The Thirteenth International Conference on Artificial Intelligence and Statistics (AISTATS) 2010, 
% JMLR: W&CP 9, pp 597-604, Chia Laguna, Sardinia, Italy, May 13-15, 2010,
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
%Copyright (C) 2010 Jonas Peters
%
%    This file is part of discrete_anm.
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
[a b x]=unique(x);
[a b y]=unique(y);
x=x-min(x);y=y-min(y);

%for i=1:num_states_x
%    for j=1:num_states_y
%        n_mat(i,j)=sum((x==i-1).*(y==j-1));
%    end
%end

if num_states_x==1|num_states_y==1
    result=1;
    T=0;
else
    n_mat=hist3([x y], {0:(num_states_x-1) 0:(num_states_y-1)});
    %sum(sum(n_mat~=n_mat2))

    p=sum(n_mat,2);
    w=sum(n_mat,1);
    nullerp=sum(p==0);
    nullerw=sum(w==0);
    for i=1:num_states_x
        for j=1:num_states_y
            n_star(i,j)=(p(i)*w(j))/length(x);
            if n_star(i,j)>0
                tmp(i,j)=(n_mat(i,j)-n_star(i,j))^2/n_star(i,j);
            else
                tmp(i,j)=0;
            end
        end
    end
    T=sum(sum(tmp));
    % T=sum(sum(((n-n_star).^2)./n_star));
    result=1-chi2cdf(T,(num_states_x-1-nullerp)*(num_states_y-1-nullerw));
end
