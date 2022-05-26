using CSV, DataFrames
using LinearAlgebra
using MultivariateStats
using Distributions
using Plots
include("estimate_cov.jl")
include("simulation_data.jl")
include("scs_opt.jl")
#df = CSV.File("../data/price_df_clean.tsv") |> DataFrame;
using ArgParse
function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--base"
            help = "price data path"
        "--l"
            help = "length of data"
            arg_type = Int
        "--n"
            help = "number of samples"
            arg_type = Int
        "--o"
            help = "output path of data"
    end
    return parse_args(s)
end
function main()
    parsed_args = parse_commandline()
    base = parsed_args["base"]
    l = parsed_args["l"]
    n = parsed_args["n"]
    out_path = parsed_args["o"]
    df = CSV.File(base) |> DataFrame;
    rename!(df,:Column1=>:time);
    df_value = Matrix(df[:,2:end]);
    price = df_value[1,:];
    r_data = (df_value[2:l,:]-df_value[1:l-1,:])./df_value[1:l-1,:]
    stocks = stocks=names(df)[2:end]
    for i =1:n
        spl = get_return_data(r_data)
        sample_p = copy(spl.sample_r)
        fileorder = string(l,"_",i)
        r_name = string("sr","_",l,"_",i,".csv")
        p_name = string("sp","_",l,"_",i,".csv")
        sample_p = copy(spl.sample_r)
        return_price(sample_p,price)
        sim_price = [price sample_p']'
        p_path = string(out_path,p_name)
        r_path = string(out_path,r_name)
        println("r_data size=",size(r_data))
        df_sample_r = DataFrame(spl.sample_r,stocks)
        df_sim_price = DataFrame(sim_price,stocks);
        CSV.write(p_path, df_sim_price)
        CSV.write(r_path, df_sample_r)
    end
end
main()