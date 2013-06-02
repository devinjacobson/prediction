%iter_mean and
%iter_sd give the number of functions checked by our method (mean and standard deviation).
%
%The other two numbers are theoretical values that can be computed easily.
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
counter=1;
for i=3:2:20
    pars.p_X=ones(1,i)*1/i;
    pars.X_values=[(-(i-1)/2):1:((i-1)/2)]';
 %%%%
 %N1, left picture
 %%%%
%     pars2.p_n=[0.05 0.3 0.3 0.3 0.05];
%     pars2.n_values=[-2;-1;0;1;2];
 %%%%
 %N2, right picture
 %%%%
    pars2.p_n=[0.05 0.18 0.18 0.18 0.18 0.18 0.05];
    pars2.n_values=[-3;-2;-1;0;1;2;3];
    for j=1:100
        [X Y p]=add_noise_exp3a(2000,@(x) round(0.5*x.^2),'custom',pars,'custom',pars2, 'fct');
        while p<0.05
            [X Y p]=add_noise_exp3a(2000,@(x) round(0.5*x.^2),'custom',pars,'custom',pars2, 'fct');
        end
        [fct_fw p_val_fw iter_tmp(j) num_x_val_tmp(j)]=fit_discrete_exp3a(X,Y,0.048,0,0);
        check(j)=length(unique(fct_fw-round(0.5*(pars.X_values).^2)));
    end
%     iter_mean(counter)=mean(iter_tmp*num_x_val_tmp(1));
%     iter_sd(counter)=sqrt(var(iter_tmp*num_x_val_tmp(1)));
    iter_mean(counter)=mean(iter_tmp);
    iter_sd(counter)=sqrt(var(iter_tmp));
    [iter_tmp;check]
    [iter_mean(counter) iter_sd(counter)]
    checker(counter)=sum(check);
    counter=counter+1;
%    pause
end
display('done')
checker


in_total5=(round(0.5*(1:9).^2)+1+4).^(2*(1:9)+1);
in_total7=(round(0.5*(1:9).^2)+1+6).^(2*(1:9)+1);

emp_supported5=5.^(2*(1:9)+1);
emp_supported7=7.^(2*(1:9)+1);

figure1=figure(1);
axes1=axes('Parent',figure1,'YScale','log','YMinorTick','on');
box('on');
hold('all');

% Create semilogy
semilogy(3:2:19,in_total7,'DisplayName','in total','MarkerSize',10,'Marker','o','LineWidth',2,'LineStyle',':',...
    'Color',[0 0 0]);
semilogy(3:2:19,emp_supported7,'DisplayName','empirically supported','MarkerSize',10,'Marker','x','LineWidth',2,'LineStyle',':',...
    'Color',[0 0 0]);
errorbar(3:2:19,iter_mean,iter_sd,'DisplayName','checked by algorithm','LineWidth',2,'LineStyle',':','Color',[0 0 0]);
% Create xlabel
xlabel({'number of X values'});
% Create ylabel
ylabel({'number of functions'});
% Create legend
legend1 = legend(axes1,'show');
set(legend1,'Position',[0.1794 0.7291 0.1598 0.1202]);

hold off

    
