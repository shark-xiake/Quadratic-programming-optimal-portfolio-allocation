function get_win(df,start,len)
    win=df[start:start+len-1,:]
    return win
end

function fra_filter(frac_or,threshold)
    b=frac_or.>=threshold
    index_asset=findall(b)
    return index_asset
end

function cov_addcash(cov_r)
    # fix covariance matrix with return of cash 
    n=size(cov_r)[1]
    zero1=zeros(1,n)
    cov_f=vcat(cov_r,zero1);
    zero1=hcat(zero1,0)
    cov_f=hcat(cov_f,zero1')
    return cov_f
end

function single_win_frac(df_v,test_start,win_len,risk_free)
    window=get_win(df_v,test_start,win_len);
    cov_or=cov(window);
    mu=DataFrames.mean(window,dims=1);
    mu_c=hcat(mu,risk_free);
    cov_rf=cov_addcash(cov_or);
    fraction_raw=vec(opt_solver(mu_c,cov_rf));
    return fraction_raw
end

function total_asset(asset,stock_num,new_price,eff_fra,rate)
    stock_asset=stock_account(stock_num,new_price)
    #print("stock_asset=",stock_asset,"\n")
    cash_balance=cash_account(asset,eff_fra,rate)
    total_asset=stock_asset+cash_balance
    return total_asset  
end

function asset_allocate(asset,fraction,price)
    stock_asset=asset*fraction;
    stock_num=stock_asset./ price
    return stock_num
end

function stock_account(stock_num,new_price)
    stock_asset= stock_num'*new_price
    return stock_asset
end

function cash_account(asset,eff_frac,rate)
    fra=1-sum(eff_frac)
    cash=asset*fra
    return cash
end