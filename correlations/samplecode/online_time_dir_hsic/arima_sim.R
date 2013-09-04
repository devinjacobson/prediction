#-please cite
# Peters, J., D. Janzing, A. Gretton and B. Schölkopf: Detecting the Direction of Causal Time Series. Proceedings of the 26th International Conference on Machine Learning (ICML 2009), 801-808.
# (Eds.) Danyluk, A., L. Bottou, M. L. Littman, ACM Press, New York, NY, USA
#
#-if you have problems, send me an email:
#jonas.peters ---at--- tuebingen.mpg.de
#
#Copyright (C) 2010 Jonas Peters
#
#    This file is part of time_direction.
#
#    time_direction is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    discrete_anm is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with discrete_anm.  If not, see <http://www.gnu.org/licenses/>.    
len<-200
num<-10
pvec<-0.15
for (p in 1:length(pvec)){
	pval<-pvec[p]
	for (k in 1:num){		
		
		#simulate time series and save the values
		eps<-abs(rnorm(len,0,1))^pval*sign(rnorm(len,0,1))
		data<-arima.sim(n = len, list(ar = c(0.9,-0.3), ma = c(-0.2,0.5)),innov=eps)
		save(data,file=paste('~/raw_data/ts_',k,'.dat',sep=""))
		sink()
		sink(paste('~/raw_data/ts_',k,'.txt',sep=""))
		show(data)
}}
