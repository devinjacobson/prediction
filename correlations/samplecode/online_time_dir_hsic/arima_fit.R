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
num<-100
split_len<-1000
file_format<-1	#1-> R-files and 2-> txt-files

coef<-list()
diff<-1:2*num
for (k in 1:num){

if (file_format ==1){ 
	load(paste('~/raw_data/ts_',k,'.dat',sep=""))}
else{
	data<-scan(paste('~/raw_data/ts_',k,'.txt',sep=""))}
laenge<-length(data)
datats<-ts(data)
minaic<-100000
modeltmp<-0
modeltmp2<-0
for (i2 in 1:2){
    for (i in 1:4){
	for (j in 0:4){
		try(modeltmp<-arima(datats,c(i,i2-1,j),method="ML",optim.control=list(maxit=1000)),silent=FALSE)
		    if (is(modeltmp,"Arima")){
               		if (modeltmp$aic+i2 < minaic){
			minaic<-modeltmp$aic+i2
			coef[k]<-list(modeltmp$coef)
			diff[k]<-i2
			loglike<-modeltmp$loglik
			res<-modeltmp$residuals}}}}}


if (is(modeltmp,"Arima")){
sink()
sink(paste('~/fitted_residuals/ts_',k,'_forw.txt',sep=""))
show(diff[k])
show(res)}

data2<-data[length(data):1]
datats2<-ts(data2)
minaic<-100000
for (i2 in 1:2){
    for (i in 1:4){
	for (j in 0:4){
		try(modeltmp2<-arima(datats2,c(i,i2-1,j),method="ML",optim.control=list(maxit=1000)),silent=FALSE)
		    if (is(modeltmp2,"Arima")){
			if (modeltmp2$aic+i2 < minaic){
			minaic<-modeltmp2$aic+i2
			coef[k+num]<-list(modeltmp2$coef)
			diff[k+num]<-i2
			loglike<-modeltmp2$loglik
			res<-modeltmp2$residuals}}}}}


if (is(modeltmp2,"Arima")){
sink()
sink(paste('~/fitted_residuals/ts_',k,'_backw.txt',sep=""))
show(diff[k+num])
show(res)}

rm(time,data,data2)

}
sink()
sink(paste('~/fitted_residuals/coef.txt',sep=""))
show(coef)
