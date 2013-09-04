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
clear all;
get_tage;tage=mod(1:10000,365)';
load('data/temp')
counter=0;
rand('seed',1)
for i=500:500:9500
    counter=counter+1
    if i==9500
        i=9162;
    end
     [fct_fw_monate, p_fw_monate(counter)]=fit_discrete(monate(1:i),round(1*temp(1:i)),0.05,0,1);
     [fct_bw_monate, p_bw_monate(counter)]=fit_discrete_cyclic(round(1*temp(1:i)),monate(1:i),0.05,0,1);
%    [fct_fw_monate10, p_fw_monate10(counter)]=fit_discrete(monate(1:i),round(10*temp(1:i)),0.0001,0,1);
%    [fct_bw_monate10, p_bw_monate10(counter)]=fit_discrete_cyclic(round(10*temp(1:i)),monate(1:i),0.0001,0,1);
end
plot(p_fw_monate,'x');
hold on
plot(p_bw_monate,'o');
hold off
