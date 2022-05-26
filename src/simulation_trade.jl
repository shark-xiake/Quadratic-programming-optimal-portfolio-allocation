include("estimate_cov.jl")
include("event.jl")
include("simulation_data.jl")
function simulation_trade(r_arr, p_arr, start::Int, test_interval::Int, win_len::Int, risk_free::Float64, asset::Float64, threshold::Float64)
    fraction_raw = single_win_frac(r_arr,start,win_len,risk_free)
    id_v = fra_filter(fraction_raw[1:end-1],0.0001)
    valid_fraction = fraction_raw[id_v]
    price = p_arr[win_len+start,id_v]
    stock_num = asset_allocate(asset,valid_fraction,price)
    #price=p_arr[win_len+2,id_v]
    asset_arr = [asset]
    for i = 1:test_interval
        if length(id_v) > 0
            price_n = p_arr[win_len+i+start,id_v]
            asset = total_asset(asset,stock_num,price_n,valid_fraction,risk_free)
        else
            asset = asset*(1+risk_free)
        end
        fraction_raw = single_win_frac(r_arr,start+i,win_len,risk_free)
        id_v = fra_filter(fraction_raw[1:end-1],threshold)
        valid_fraction = fraction_raw[id_v]
        price_s = p_arr[win_len+i+start,id_v]
        stock_num = asset_allocate(asset,valid_fraction,price_s)
        asset_arr = [asset_arr asset]
    end
    return asset_arr
end

function simulation_trade(r_arr, p_arr, start::Int, test_interval::Int, prior::Int, win_len::Int, risk_free::Float64, asset::Float64, acc::Float64, ftype::Int)
    fraction_raw = single_win_frac(r_arr,start,prior,risk_free)
    id_v = fra_filter(fraction_raw[1:end-1],0.0001)
    valid_fraction = fraction_raw[id_v]
    price = p_arr[win_len+start,id_v]
    stock_num = asset_allocate(asset,valid_fraction,price)
    asset_arr = [asset]
    for i = 1:test_interval
        if length(id_v) > 0
            price_n = p_arr[win_len+i+start,id_v]
            asset = total_asset(asset,stock_num,price_n,valid_fraction,risk_free)
        else
            asset = asset*(1+risk_free)
        end
        price_s = p_arr[win_len+i+start,id_v]
        if ftype == 1
            stock_num = asset_allocate(asset,valid_fraction,price_s)
        end
        asset_arr = [asset_arr asset]
    end
    return asset_arr
end



