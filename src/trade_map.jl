using CSV,DataFrames
path_dir="result/sw_1458_"
#result_dir="result/sw_1458_"
ftype = 3
num_res = 30
res_path = string(path_dir,1,"_","res",ftype,".csv")
df_res = CSV.File(res_path) |> DataFrame
arr_res = Matrix(df_res)
res_ls = Vector{AbstractArray}(undef, num_res)
res_ls[1] = arr_res
for i in 2:num_res
    res_path = string(path_dir,i,"_","res",ftype,".csv")
    df_res = CSV.File(res_path) |> DataFrame
    arr_res = Matrix(df_res)
    res_ls[i] = arr_res
end
final_matrix =Matrix{Float64}(undef,8,30)
for i in 1:length(res_ls)
    tem = res_ls[i][end,:] ./ res_ls[i][1,:]
    final_matrix[:,i]=tem
end
title=Vector{Symbol}(undef,num_res)
for i in 1:num_res
    title[i]=Symbol("sample",i)
end
res_df = DataFrame(final_matrix,title)
res_path = string(path_dir,"final",ftype,".csv")
CSV.write(res_path, res_df)




