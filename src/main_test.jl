include("simulation_trade.jl")
using ArgParse
function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--price_path"
            help = "price data path"
        "--return_path"
            help = "return data path"
        "--out_path"
            help = "output data path"
        "--ftype"
            help = "type of simulation. 1,2 for fix covariance;
            3 with dynamic covariance "
            arg_type = Int
            default = 1
        #"--flag1"
        #    help = "a positional argument"
        #    required = true
    end
    return parse_args(s)
end
function main()
    parsed_args = parse_commandline()
    price_path = parsed_args["price_path"]
    return_path = parsed_args["return_path"]
    out_path = parsed_args["out_path"]
    ftype = parsed_args["ftype"][1]
    #price_path = "./data/price_df_clean.tsv"
    df = CSV.File(price_path) |> DataFrame
    rename!(df,:Column1=>:time)
    #return_path = "./data/df_sim_r.csv"
    df_r = CSV.File(return_path) |> DataFrame
    r_arr = Matrix(df_r)
    pr_value = Matrix(df[:,2:end])
    println("transform price data ")
    price = pr_value[1,:]
    p_arr = copy(r_arr)
    return_price(p_arr,price)
    p_arr =[price p_arr']'
    println("simulation trade")
    start = 1;
    test_interval = 900;
    risk_free = 0.0001
    prior = 1200
    asset = 100000.
    threshold = 0.00001
    asset_arr = Matrix{Float64}(undef,8,901)
    len_ls = Vector(60:20:200)
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
    #CSV.write("./data/asset_res2.csv", res_df)
    CSV.write(out_path, res_df)
end
main()

#price_path = ARGS[1]
#return_path = ARGS[2]
#out_path = ARGS[3]
#ftype = ARGS[4][1]
##price_path = "./data/price_df_clean.tsv"
#df = CSV.File(price_path) |> DataFrame
#rename!(df,:Column1=>:time)
##return_path = "./data/df_sim_r.csv"
#df_r = CSV.File(return_path) |> DataFrame
#out_path = ARGS[3]
#
#r_arr = Matrix(df_r)
#pr_value = Matrix(df[:,2:end])
#
#println("transform price data ")
#price = pr_value[1,:]
#p_arr = copy(r_arr)
#return_price(p_arr,price)
#p_arr =[price p_arr']'
#
#println("simulation trade")
#start = 1;
#test_interval = 900;
#risk_free = 0.0001
#prior = 1200
#asset = 100000.
#threshold = 0.00001
#asset_arr = Matrix{Float64}(undef,8,901)
#len_ls = Vector(60:20:200)
#for i in Vector(1:length(len_ls))
##for i in Vector(1:length(len_ls))
#    tem = simulation_trade(start+200-len_ls[i], test_interval, prior,  len_ls[i], risk_free, asset, threshold, ftype)
#    asset_arr[i,:] = vec(tem);
#end
#name_len =string.(len_ls)
#res_df = DataFrame(asset_arr',name_len)
##CSV.write("./data/asset_res2.csv", res_df)
#CSV.write(out_path, res_df)