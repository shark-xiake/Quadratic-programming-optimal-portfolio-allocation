using CSV, DataFrames
using LinearAlgebra
using MultivariateStats
using Distributions
using Plots
include("estimate_cov.jl")
include("simulation_data.jl")
include("scs_opt.jl")
df = CSV.File("../data/price_df_clean.tsv") |> DataFrame;
df_r = CSV.File("../data/df_sim_r.csv") |> DataFrame;
rename!(df,:Column1=>:time);
pr_value=Matrix(df[:,2:end]);
df_v =Matrix(df_r);
price=pr_value[1,:];
df_p=copy(df_v);
return_price(df_p,price);
start = 1;
test_interval = 900;
win_len=60
risk_free=0.0001
asset=100000
fraction_or=single_win(df_v,start,win_len,risk_free)
id=fra_efficient(fraction_or[1:end-1],0.0001)
eff_fraction=fraction_or[id]
price=df_p[win_len+2,id]
asset_arr=[asset]
for i=1:test_interval
    fraction_or=single_win(df_v,start+i,win_len,risk_free)
    id=fra_efficient(fraction_or[1:end-1],0.0001)
    eff_fraction=fraction_or[id]
    if length(id)>0
        stock_vol=asset_allocate(asset,eff_fraction,price)
        price_n=df_p[win_len+i+2,id]
        asset=total_asset(asset,stock_vol,price_n,risk_free)
    else
        asset=asset*(1+risk_free)
    end
    #asset_arr=[asset_arr asset]
end