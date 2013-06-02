function res=plot_fct_dens_cyclic(x, X_values, X_new, y, Y_values, fct, p_val, level, dir,force_fct_plot)
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

if dir==0
    col1='b';
    col2='r';
else
    col1='r';
    col2='b';
end
% subplot(2,1,1);
% plot(zeros(length(X_values),1),X_values,'o','MarkerSize',14,'LineWidth',2,'Color',col1)
% hold on;
% plot(ones(length(Y_values),1),Y_values,'o','MarkerSize',14,'LineWidth',2,'Color',col2)
% axis([-0.1 1.1 -0.1+min([X_values;Y_values]) max([X_values;Y_values])+0.1])
% if (p_val>level) | (force_fct_plot==1)
%     for i=X_new
%         line([0,1],[X_values(i)-0.03,fct(i)],'Color','b','LineWidth',2);
%         hold on;
%     end
% end
% hold off;

yhat=fct(X_new);
eps=mod(y-yhat,max(y)-min(y)+1);
eps_values=unique(eps);
for i=1:length(X_values)
    for j=1:length(eps_values)
        p_x_eps(i,j)=sum((x==X_values(i)).*(eps==eps_values(j)));
    end
end

p_x_eps=p_x_eps./((sum(p_x_eps')'*ones(1,length(eps_values))));
p_x_eps(:,(length(eps_values)+1):(length(eps_values)+1))=zeros;

hilf=p_x_eps';
% subplot(2,1,2)
bar(hilf(:));
set(gca,'XTick',size(hilf,1)*ones(1,size(hilf,2))*gallery('triw',size(hilf,2),1),'XTickLabel',{});
if dir==0
    title('X->Y');xlabel('X values');ylabel('number of eps values');
else
    title('Y->X');xlabel('Y values');ylabel('number of eps_{tilde} values');
end

