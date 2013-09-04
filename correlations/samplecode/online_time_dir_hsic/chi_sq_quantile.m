function result=chi_sq_quantile(x,y)
%-please cite
% Peters, J., D. Janzing, A. Gretton and B. Schölkopf: Detecting the Direction of Causal Time Series. Proceedings of the 26th International Conference on Machine Learning (ICML 2009), 801-808.
% (Eds.) Danyluk, A., L. Bottou, M. L. Littman, ACM Press, New York, NY, USA
%
%-if you have problems, send me an email:
%jonas.peters ---at--- tuebingen.mpg.de
%
%Copyright (C) 2010 Jonas Peters
%
%    This file is part of time_direction.
%
%    time_direction is free software: you can redistribute it and/or modify
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

    
a=round(0.5*sqrt(length(x)));b=a;
[n,C]=hist3([x y],[a b]);
s1=size(C{1});s2=size(C{2});
v=sum(n');
w=sum(n);
for i=1:a
    for j=1:b
        n_star(i,j)=(v(i)*w(j))/length(x);
    end
end
% n_star


while (sum(sum(n_star<1))>0) && (max(s1(2),s2(2))>2)
    [tmp1 col]=max(sum(n_star<1));
    [tmp2 row]=max(sum((n_star<1)'));
    if s1(2)==2
       C{2}(min(length(C{2}),col))=[];
    elseif s2(2)==2
       C{1}(min(length(C{1}),row))=[];
    elseif tmp1>tmp2
       C{2}(min(length(C{2}),col))=[];
    elseif tmp2>=tmp1
       C{1}(min(length(C{1}),row))=[];
    end

    clear n 
    [n,C]=hist3([x y],C);
    s1=size(C{1});s2=size(C{2});
%     asd=[s1(2) s2(2)]

    v=sum(n');
    w=sum(n);
    
    clear a b
    a=length(C{1});
    b=length(C{2});
    clear n_star
    for i=1:a
        for j=1:b
            n_star(i,j)=(v(i)*w(j))/length(x);
        end
    end
%    n_star
end
T=sum(sum(((n-n_star).^2)./n_star));
result=chi2cdf(T,(a-1)*(b-1));
