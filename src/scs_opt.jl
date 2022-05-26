using Convex, SCS
# fix covariance with return cash
function cov_addcash(cov_r)
    # fix covariance matrix with return of cash 
    n=size(cov_r)[1]
    zero1=zeros(1,n)
    cov_f=vcat(cov_r,zero1);
    zero1=hcat(zero1,0)
    cov_f=hcat(cov_f,zero1')
    return cov_f
end

# using SCS get result
# compute the result of the kelly
function opt_solver(exp_r,cov_f)
    # exp_r is a nx1 column vector.
    # cov_f is a nxn square symmetric positive definite matrix.
    n=length(exp_r)
    x = Convex.Variable(n)
    x_lower=0.0
    x_upper=1
    ret  = dot(x,exp_r)
    #risk = Convex.quadform(x,cov_f)
    P = real(sqrt(Matrix(cov_f)))
    risk= square(norm2(P * x)) # norm2 of second_order_cone/norm2.jl
    qp_min = -ret+0.5*risk
    p = Convex.minimize(-ret+0.5*risk,
                  sum(x) == 1,
                  x_lower <= x,
                  x <= x_upper );
    Convex.solve!(p, () -> SCS.Optimizer(verbose=false),verbose=false);
    return x.value
end

function fra_efficient!(frac_or,threshold)
    # find fraction >= threshold
    frac_or[frac_or.< threshold] .=0
    f_stock=sum(frac_or[1:end-1])
    if f_stock > 1
        frac_or.= frac_or./f_stock
        frac_or[end]=0
    elseif f_stock <1
        frac_or[end] = 1-f_stock+frac_or[end]
    elseif f_stock ==1
        frac_or[end]=0
    end
end

function frac_opt(cash_return, threshold, exp_return, exp_cov)
    exp_r_cash=hcat(exp_return,cash_return);
    exp_cov_cash=cov_addcash(exp_cov);
    result_opt=opt_solver(exp_r_cash,exp_cov_cash)
    fraction_or=vec(result_opt);
    fra_efficient!(fraction_or,threshold)
    return fraction_or
end