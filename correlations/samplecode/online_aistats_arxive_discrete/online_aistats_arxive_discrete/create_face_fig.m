load('data/faces')
sex_guess=faces(:,1);
par=faces(:,3);
X=par;
Y=sex_guess;
[X_values aa X_new]=unique(X);
Y_values=min(Y):1:max(Y);Y_values=Y_values';
plot_fct_dens_cyclic_extra(X, X_values, X_new, Y, Y_values, zeros(15,1), 0, 0.05, 0,1);