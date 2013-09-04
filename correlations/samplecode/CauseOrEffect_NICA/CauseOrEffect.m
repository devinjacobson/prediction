function CauseOrEffect(x)
% function CauseOrEffect(x)
% Use of constrained nonlinear ICA for distinguishing cause from effect.
% Version 1.0, May. 15 2009
% PURPOSE:
%       to find which one of xi (i=1,2) is the cause. In particular, this 
%       function does 1) preprocessing to make xi rather clear to Gaussian,
%       2) learn the corresponding 'disturbance' under each assumed causal
%       direction, and 3) performs the independence tests to see if the 
%       assumed cause if independent from the learned disturbance.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS:
%       x (T*2): has two rows, each of them corresponds to a continuous 
%       variable. T is the sample size.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% OUTPUTS:
%       The statistical tests results will be printed by this function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Kun Zhang (Email: kzhang@tuebingen.mpg.de)
% This software is for non commercial use only. It is freeware but not in the public 
% domain.
% If you find any bugs, please report them to me. Thanks a lot!

% We are given x
% To avoid local optima and accelerate the learning process, we first try
% to transform the data to make them seem regular.
% The automatic procedure will be provided in future. 
% Currently this procedure is done by you...
fprintf('Please use nonlinear transformations to make the transformed variables closer to Gaussian before running the program.\n');

%% If you want to test other data sets, please let 'data' contain the original
% data and 'temp' contain the transformed data.
data = x';
temp = x'; 
% Now let's see if x1 -> x2 is plausible
fprintf('To see if x1 -> x2...\n');
[y12, net, SNR, fx1_12, fx2_12] = NICA_MND_pnl_noinput(temp([2,1],:));
% the corresponding disturbance
e2_12 = fx1_12 + fx2_12;
MI(1) = information(y12(1,:), y12(2,:));

% Then test if x1 <- x2 holds
fprintf('To see if x1 <- x2...\n');
[y21, net, SNR, fx1_21, fx2_21] = NICA_MND_pnl_noinput(temp);
e1_21 = fx1_21 + fx2_21;
MI(2) = information(y21(1,:), y21(2,:));

% statistical independence tests
alpha = 0.01;
fprintf('Performing independence tests...\n');
if length(x) > 2000
    params.sigx = -1;
    params.sigy = -1;
    if length(x) > 5000
        I_tmp = randperm(length(x));
        % to test if x1 -> x2
        [thresh12,testStat12,params] = hsicTestGamma(y12(1,I_tmp(1:5000))',y12(2,I_tmp(1:5000))',alpha,params);
        % to test if x2 -> x1
        [thresh21,testStat21,params] = hsicTestGamma(y21(1,I_tmp(1:5000))',y21(2,I_tmp(1:5000))',alpha,params);
    else
        % to test if x1 -> x2
        [thresh12,testStat12,params] = hsicTestGamma(y12(1,:)',y12(2,:)',alpha,params);
        % to test if x2 -> x1
        [thresh21,testStat21,params] = hsicTestGamma(y21(1,:)',y21(2,:)',alpha,params);
    end
else
    params.shuff = 200;
    params.sigx = -1;
    params.sigy = -1;
    % x1 -> x2?
    [thresh12,testStat12] = hsicTestBoot(y12(1,:)',y12(2,:)',alpha,params);
    % x2 -> x1?
    [thresh21,testStat21] = hsicTestBoot(y21(1,:)',y21(2,:)',alpha,params);
end

% print the results
fprintf('Under x1->x2, estimated mutual information = %d; \nat significance level alpha = 0.01, threshold = %d, and testStat = %d.\n',...
    MI(1), thresh12,testStat12);
fprintf('Under x1<-x2, estimated mutual information = %d; \nat significance level alpha = 0.01, threshold = %d, and testStat = %d.\n',...
    MI(2), thresh21,testStat21);
fprintf('\n Note: You can see which causal direction is plausible. The smaller the statistic, the more independent the cause and disturbance are.\n');

figure, subplot(2,3,1), plot(data(1,:), -fx2_12, '.'); title('x_1 -> x_2'); 
ylabel('g_1(x_1)'), xlabel('x_1');
subplot(2,3,2), plot(data(2,:), fx1_12, '.'); title('x_1 -> x_2'); 
ylabel('g_2(x_2)'), xlabel('x_2');
subplot(2,3,3), plot(data(1,:), e2_12, '.'); title('x_1 -> x_2'); 
ylabel('estimated disturbance'), xlabel('x_1');

subplot(2,3,4), plot(data(2,:), -fx2_21, '.'); title('x_2 -> x_1'); 
ylabel('g_2(x_2)'), xlabel('x_2');
subplot(2,3,5), plot(data(1,:), fx1_21, '.'); title('x_2 -> x_1'); 
ylabel('g_1(x_1)'), xlabel('x_1');
subplot(2,3,6), plot(data(2,:), e1_21, '.'); title('x_2 -> x_1'); 
ylabel('estimated disturbance'), xlabel('x_2');
