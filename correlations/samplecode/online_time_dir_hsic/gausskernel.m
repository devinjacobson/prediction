function result=gausskernel(A,sigma)
%spaltenvektoren als eingabe
%rbf
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
result=exp(-A/(2*sigma^2));

%polynomial
%result=((x*y')+1)^2;
