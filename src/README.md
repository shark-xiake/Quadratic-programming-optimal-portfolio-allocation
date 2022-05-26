- [1. Sampler of data, solver of fraction in Julia](#1-sampler-of-data-solver-of-fraction-in-julia)

# 1. Sampler of data, solver of fraction in Julia

- scs_opt.jl：根据输入的期望收益与协方差矩阵计算 fraction。
- example.jl：是scs_opt.jl的调用例子，对stock组合的预期收益率与协方差矩阵，补充现金收益率，假定现金为无风险情况下调整协方差矩阵。
- sampler_data.jl：sample_return!()根据多元高斯simulation return 数据，return_price()将return数据转化成price。
- test_opt.jl：使用sampler_data.jl生成return,price数据，同时使用scs_opt.jl求解。
