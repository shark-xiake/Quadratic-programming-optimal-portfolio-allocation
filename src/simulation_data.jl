using LinearAlgebra
include("sampler_data.jl")
function sampler_ins(r_data:: Matrix{T})where T <: AbstractFloat
    #extract distribution from data,and initialize sampler
    r_mean=DataFrames.mean(r_data,dims=1);
    exp_return = vec(r_mean)
    r_res=r_data.-r_mean;
    r_length=size(r_data)[1]
    exp_cov=(r_res'*r_res)/(r_length-1.0);
    spl=Sampler(exp_return,exp_cov,r_length);
    return spl
end

function get_return_data(r_data:: Matrix{T})where T <: AbstractFloat
    spl=sampler_ins(r_data)
    sample_return!(spl)
    return spl
end

function return_price(return_df, price)
    # transform return data to price data
    length=size(return_df)[1]
    return_df[1,:] .=price.* return_df[1,:] .+ price 
    for i=2:length
        return_df[i,:] .=return_df[i-1,:].* return_df[i,:] .+ return_df[i-1,:]       
    end
end

function log_return_price(log_return, log_price)
    # transform log return data to log price data
    length=size(log_return)[1]
    log_return[1,:] .=log_return[1,:] .+ log_price 
    for i=2:length
        log_return[i,:] .=log_return[i,:] .+ log_return[i-1,:]
    end
end

function sample_price_bou!(spl::Sampler,boundry::AbstractFloat)
    # simulate price data with boundry
    len = spl.row
    for i=2:len
        #println(i)
        finish_sam=[]
        while length(finish_sam) < spl.col
            tem_sample = rand(spl.mvn)
            tem = (tem_sample -spl.sample_r[i-1,:])./ spl.sample_r[i-1,:]
            tem_ab = abs.(tem)
            b = tem_ab .< boundry
            index_t =findall(b)
            eff_index = setdiff(index_t,finish_sam)
            spl.sample_r[i,eff_index].= tem_sample[eff_index]
            finish_sam = [finish_sam ;eff_index]
        end
    end
end

function check_sample_transform(spl, sim_price, accuracy,r)
    # transform log return data to log price data
    sim_return_mean=DataFrames.mean(spl.sample_r,dims=1)
    if r == "log"
        sim_log_p=log.(sim_price);
        sim_return_mean2=DataFrames.mean((sim_log_p[2:end,:] .- sim_log_p[1:end-1,:]),dims=1)
    else
        sim_return_mean2 = DataFrames.mean((sim_price[2:end,:] .- sim_price[1:end-1,:]) ./ sim_price[1:end-1,:],dims=1)
    end
    status = isapprox(sim_return_mean ,sim_return_mean2 ,atol = accuracy)
    return status
end