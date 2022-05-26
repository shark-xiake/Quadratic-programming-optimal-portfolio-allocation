include("scs_opt.jl")
exp_return=[0.0008 0.0009 0.0013 0.0011 0.0011];
exp_cov=[0.00041772   0.000138318  0.000129704  0.000143973  9.89771e-5
0.000138318  0.000537623  0.000188453  0.000264726  0.000215266
0.000129704  0.000188453  0.000963778  0.000320292  0.000473726
0.000143973  0.000264726  0.000320292  0.000619363  0.000324656
9.89771e-5   0.000215266  0.000473726  0.000324656  0.000977346];
cash = 0.0001;
threshold=0.0001;

#exp_r_cash=hcat(exp_return,cash);
#exp_cov_cash=cov_addcash(exp_cov);
#result_opt=opt_solver(exp_r_cash,exp_cov_cash)
#fraction_or=vec(result_opt);
fraction=frac_opt(cash, threshold, exp_return, exp_cov)
#threshold=0.0001
#id_efficient=fra_efficient(fraction_or,threshold); # 筛选 fraction 大于 threshold 的有效 fraction id
#fraction=fraction_or[id_efficient] # 有效　fraction >= threshold
println(sum(fraction))