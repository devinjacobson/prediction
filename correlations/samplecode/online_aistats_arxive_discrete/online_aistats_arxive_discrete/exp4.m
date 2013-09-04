%X should be a vector 4177x1 containing the sex of abalone (0,1 or 2)
%abalone should be a 4177x9 matrix, containing length, diameter and height
%     of abalone (in mm) as cols 2,3,4.
%
%
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
rand('seed',1)
load('data/abalone')
%
counter=0;
for i=1000:500:1000
    counter=counter+1;
    if i==0
        i=100;
    elseif i==4500
        i=4177;
    end
    [fct_fw, p1(counter), fct_bw, p_bw1(counter)]=fit_both_dir_discrete(abalone(1:i,1),0,round(100*abalone(1:i,2)),0,0.05,0);
    [fct_fw, p2(counter), fct_bw, p_bw2(counter)]=fit_both_dir_discrete(abalone(1:i,1),0,round(100*abalone(1:i,3)),0,0.05,0);
    [fct_fw, p3(counter), fct_bw, p_bw3(counter)]=fit_both_dir_discrete(abalone(1:i,1),0,round(100*abalone(1:i,4)),0,0.05,0);
    [fct_bw_cyc, p_bw1_cyc(counter)]=fit_discrete_cyclic(round(100*abalone(1:i,2)),abalone(1:i,1),0.05,0,1);
    [fct_bw_cyc, p_bw2_cyc(counter)]=fit_discrete_cyclic(round(100*abalone(1:i,3)),abalone(1:i,1),0.05,0,1);
    [fct_bw_cyc, p_bw3_cyc(counter)]=fit_discrete_cyclic(round(100*abalone(1:i,4)),abalone(1:i,1),0.05,0,1);
end
