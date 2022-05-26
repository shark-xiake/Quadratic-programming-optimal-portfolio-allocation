include("simulation_trade.jl")
price_dir = "data/sp_1458_"
return_dir = "data/sr_1458_"
res_dir = "result/sp_1458_"

for i in 1:1
    price_path = string(price_dir,i,".csv")
    return_path= string(return_dir,i,".csv")
    df_r = CSV.File(return_path) |> DataFrame
    df_p = CSV.File(price_path) |> DataFrame
    r_arr = Matrix(df_r)
    p_arr = Matrix(df_p)
    ftype = 3
    start = 1
    test_interval = 900
    risk_free = 0.0001
    prior = 1200
    asset = 100000.
    threshold = 0.00001
    asset_arr = Matrix{Float64}(undef,8,901)
    asset_arr = Matrix{Float64}(undef,8,901)
    len_ls = Vector(60:20:200)
    res_path = string(res_dir,i,"_","res",ftype,".csv")
    for i in Vector(1:length(len_ls))
    #for i in Vector(1:length(len_ls))
        if ftype==3
            tem = simulation_trade(r_arr, p_arr, start+200-len_ls[i], test_interval, len_ls[i], risk_free, asset, threshold)
        else
            tem = simulation_trade(r_arr, p_arr, start+200-len_ls[i], test_interval, prior, len_ls[i], risk_free, asset, threshold, ftype)
        end
            asset_arr[i,:] = vec(tem);
    end
    name_len =string.(len_ls)
    res_df = DataFrame(asset_arr',name_len)
    CSV.write(res_path, res_df)
end