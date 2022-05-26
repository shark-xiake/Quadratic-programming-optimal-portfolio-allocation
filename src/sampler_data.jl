using CSV, DataFrames
using Distributions

struct Sampler{T <: AbstractFloat ,S <: Integer}
    # prameter sample　data　
    mu :: Vector{T}
    cov :: Matrix{T}
    col :: S # number of simulated stock
    row :: S # number of simulated points
    mvn :: MvNormal
    sample_r :: Matrix{T} 
end 

function Sampler(
    mu :: Vector{T},
    cov_r:: Matrix{T},
    row :: Integer) where T <: AbstractFloat
    mvn = MvNormal(mu,cov_r)
    col = length(mu)
    sample_r = Matrix{T}(undef, row, col)
    Sampler(mu,cov_r,col,row,mvn,sample_r)
end

function sample_return!(spl::Sampler)
    # simulate return data according to Sampler.mvn
    length = spl.row
    for i=1:length
        spl.sample_r[i,:] .= rand(spl.mvn)
    end
end
