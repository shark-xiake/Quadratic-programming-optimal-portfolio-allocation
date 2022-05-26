struct Order
    id_v :: Array{Int64,1}
    stock_f :: Array{Float64,1}
    cash_f :: Float64
end
order_ls=Vector{Order}(undef, test_interval);