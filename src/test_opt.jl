include("sampler_data.jl")
include("simulation_data.jl")
include("scs_opt.jl")
# sample data and compute fraction of klley
#data_path = "~/bear/data";
#file_name = "/price_df_clean.tsv"
#print(map(x->string(x, x), ARGS))
file_path = ARGS[1] #input parameter
#file_path = string(data_path,file_name)
#file_path = "../data/price_df_clean.tsv"
fraction_ans=vec([0.07294861233792801 0.004453078156777527 0.43252428519703084 0.42412574886791193 0.06594827544035185])
println(file_path)
df = CSV.File(file_path) |> DataFrame;
rename!(df,:Column1=>:time);
df_value = Matrix(df[:,2:end]);
price=df_value[1,:];
r_data=(df_value[2:end,:]-df_value[1:end-1,:])./df_value[1:end-1,:];

println("simulation simple return  data ")
spl = get_return_data(r_data)
sample_p=copy(spl.sample_r);

println("tanform simple return  to price ")
return_price(sample_p,price);
sim_price=[price sample_p']';

println("get log return data ")
log_p=log.(df_value);
log_price=log_p[1,:];

println("simulation log return  data ")
log_r=log_p[2:end,:]-log_p[1:end-1,:];
spl_log = get_return_data(log_r)
sim_mean_log=DataFrames.mean(spl_log.sample_r,dims=1)

println("initialize sampler of price data ")
spl_pb = sampler_ins(df_value)
spl_pb.sample_r[1,:].= df_value[1,:]
println("simulation price data with boundary ")
boundary=0.1
sample_price_bou!(spl_pb,boundary)

println("tanform log return to price ")
sim_logp=copy(spl_log.sample_r);
log_return_price(sim_logp,log_price);
sim_log_p=[log_price sim_logp']';# generative log return and tanform to price
sim_price_log=exp.(sim_log_p);
#sim_log_p2=log.(sim_price_log);
sta1 = check_sample_transform(spl_log, sim_price_log, 1.0e-16,"log")
#sim_return_log_mean=DataFrames.mean(spl_log.sample_r,dims=1)
#sim_return_test2=DataFrames.mean((sim_log_p2[2:end,:] .-sim_log_p2[1:end-1,:]),dims=1)
#sta1=isapprox(sim_return_test2,sim_return_log_mean,atol=1.0e-16)
println("sample transform is ",sta1)

cash = 0.0001;
threshold=0.0001;
exp_return = spl.mvn.μ
exp_cov = spl.mvn.Σ
fraction=frac_opt(cash, threshold, exp_return', exp_cov)
fraction=vec(fraction);
b=fraction.>=threshold;
index_asset=findall(b);
fraction_e=fraction[index_asset]
answer=norm2(fraction_e .-fraction_ans)
println("fraction optimization is ",isapprox(answer,0))

#id_efficient=fra_efficient(fraction_or,0.0001);
#stocks=names(df)[2:end];
#column=[stocks; "cash"];# add cash to stock list
#selected_stock=column[id_efficient]
## get result fraction
#fraction=fraction_or[id_efficient]
#println(fraction)