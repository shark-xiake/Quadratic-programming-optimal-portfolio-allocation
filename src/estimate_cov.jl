using CSV, DataFrames
using LinearAlgebra
using Convex, SCS
function opt_solver(exp_r,cov_f)#fix fault of Semidefinite matrix
    n = length(exp_r)
    x = Variable(n)
    x_lower = 0.0
    x_upper = 1
    ret  = dot(x,exp_r)
    #risk = quadform(x,cov_f)
    P = real(sqrt(Matrix(cov_f)))
    risk= square(norm2(P * x)) # norm2 of second_order_cone/norm2.jl
    qp_min = -ret+0.5*risk
    p = minimize(qp_min,
                  sum(x) == 1,
                  x_lower <= x,
                  x <= x_upper );
    solve!(p, () -> SCS.Optimizer(verbose=false),verbose=false);
    x.value
    return x.value
end

function fra_efficient(frac_or,threshold)
    b=frac_or.>=threshold
    index_asset=findall(b)
    return index_asset
end 

function single_win(df_v,test_start,win_len,risk_free)
    window=get_win(df_v,test_start,win_len);
    cov_or=cov(window);
    mu=DataFrames.mean(window,dims=1);
    mu_c=hcat(mu,risk_free);
    cov_rf=cov_addcash(cov_or);
    fraction_or=vec(opt_solver2(mu_c,cov_rf));
    return fraction_or
end 

function total_asset(asset,stock_vol,new_price,rate)
    stock_asset=stock_account(stock_vol,new_price)
    cash_balance=cash_account(asset-stock_asset,rate)
    total_asset=stock_asset+cash_balance
    return total_asset  
end

function asset_allocate(asset,fraction,price)
    stock_asset=asset*fraction;
    stock_vol=stock_asset./ price
    return stock_vol
end

function stock_account(stock_vol,new_price)
    stock_asset=sum(stock_vol.*new_price)
    return stock_asset
end

function cash_account(cash,rate)
    cash=cash*(1+rate)
    return cash
end

