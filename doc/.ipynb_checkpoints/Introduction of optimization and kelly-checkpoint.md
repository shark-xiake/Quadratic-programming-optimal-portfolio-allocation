- [1 The Kelly criterion for optimal portfolio allocation](#1-the-kelly-criterion-for-optimal-portfolio-allocation)
  - [1.1 Proof of the growth coefficient for one asset](#11-proof-of-the-growth-coefficient-for-one-asset)
    - [1.1.1 One interval](#111-one-interval)
    - [1.1.2 T intervals](#112-t-intervals)
  - [1.2 The growth coefficient for a portfolio of assets](#12-the-growth-coefficient-for-a-portfolio-of-assets)
- [2 Optimization solver of portfolio allocation](#2-optimization-solver-of-portfolio-allocation)
  - [2.1 Quadratic optimization of portfolio](#21-quadratic-optimization-of-portfolio)
  - [2.2 Solve QP by CVXOPT](#22-solve-qp-by-cvxopt)

# 1 The Kelly criterion for optimal portfolio allocation
Kelly规则是最大化 $`E\{log(X)\}`$, the expected value of the logarithm of the (random variable) capital X.

Thorp 推导出这规则等价于最大化资本增长系数（growth rate coefficient）的期望: $`E\{log(P_t/P_0)\}`$，而不是资本期望的最大化: $`E(P_t)`$ 。


参考：Chapter 8.4 The theory for a portfolio of securities of Thorp_2007.

For a portfolio, 增长系数(The growth coefficient)形式为:

$`g=\mu-\frac{1}{2}V`$

$`\mu`$为期望收益，V为方差表示风险因子.


## 1.1 Proof of the growth coefficient for one asset


### 1.1.1 One interval

资产回报的形式（Bertram-2010, Tsay 2010 Chapter 1.1 ). Let $`P_t`$ be the price of an asset at time index $`t`$.

Simple return $`R_t = \frac{P_t-P_{t-1}}{P_{t-1}}`$. 为单位资本单位时刻的增长率。

假设 a binomial distribution for returns， $`E(R_t)=m, Var(R_t)=s^2`$, $`\text{Prob}(R_t=m+s)=\text{Prob}(R_t=m-s)=0.5 `$ (based on Thorp_2007).

$`P_t = P_{t-1} + P_{t-1}*R_t = P_{t-1}(1+R_t)`$  

$`\begin{aligned}
    g=&E(log(P_t/P_{t-1})) =E(log(1+R_t))\\
      =&0.5log(1+m+s)+0.5log(1+m-s)\\
      =&0.5(log((1+m)^2-s^2))\\
      =&0.5(log((1+m)^2(1-\frac{s^2}{(1+m)^2}))\\
      =&log(1+m)+\frac{1}{2}log(1-\frac{s^2}{(1+m)^2})\\
      \approx & m-\frac{s^2}{2(1+m)^2}\\
        \end{aligned}`$
通过一阶泰勒展开

### 1.1.2 T intervals

对于给定初始单位资产价格$`P_0`$对于 T 时刻的价格有$`P_T`$  

则$`g=log P_T=log[(1+R_t[T])P_0]`$  

假设由初始0时刻的T个区间:

$`E(R_t)=m,Var(R_t)=s^2`$  

$`{1+R_t[T]}=\prod_{i=0}^{i=T-1}(1+R_{t-i})`$  

Assuming $`P_0=1`$,

$`\begin{aligned}
    g=&E(log(P_T))\\
    =&E(log(1+R_t[T]))\\
      =&E(\sum_{i=0}^{T}{log(1+R_{t-i})})\\
      =&Tlog((1+m)(1-\frac{s^2}{2(1+m)^2})\\
      =&T(m-\frac{s^2}{2(1+m)^2})\\
      \approx&Tm-\frac{Ts^2}{2(1+m)^2}\\
        \end{aligned}`$

$`E(R_t[T])=Tm,Var(R_t[T])=Ts^2`$
结合上式对一个区间进行Ｔ次分割则每个子区间: 

$`mean=\frac{m}{T}`$,$`var=\frac{s^2}{T}`$

得到:

$`\begin{aligned}
    g=&E(log(P_t/P_{t-1})) =E(log(1+R_t))\\
      \approx&m-\frac{s^2}{2(1+\frac{m}{T})^2}\\
        \end{aligned}`$  
$`\lim_{T \to \infty}\frac{m}{T}=0`$  

即:  

$`g=m-\frac{s^2}{2}`$  

标准化为:

$`g=\mu-\frac{1}{2}V`$

## 1.2 The growth coefficient for a portfolio of assets

基于kelly 规则要实现 The growth function 即g的最大化，在portfolio的优化问题需要考虑G的多元形式,
即对于n个股票则有:  

$`\mu=\sum^{n}_{i}{f_i}r_i`$，  
$` V=F^T\Sigma F`$，  
$` F^T=[f_1,...,f_n]`$，  
$` \Sigma=\text{Covariance}`$,

对于组合growth function则有一下形式：

$`g=\sum^{n}_{i=1}{f_i}r_i-\frac{1}{2}\sum^{n}_{i}\sum^{n}_{j}cov(r_i,r_j)f_i f_j`$  

# 2 Optimization solver of portfolio allocation

## 2.1 Quadratic optimization of portfolio

参考Quadratic optimization的标准型：  

Minimize:
$`\frac{1}{2}X^TQX+P^TX`$　　
subject to:　　
$`GX<=h,`$
$`AX=b`$

对于Kelly规则：
$`X=F=[f_0,...,f_n]`$  
$`P^T=-[r_0,...,r_n]`$


对于protfolio的优化就是得到下述约束问题的最优解

Maximize:
$`g=\sum^{n}_{i=1}{f_i}r_i-\frac{1}{2}\sum^{n}_{i}\sum^{n}_{j}cov(r_i,r_j)f_i f_j`$

subject to: $`\sum^{n}_{i=1}{f_i}=1 `$，  

$`f_i>=0,i=1,...,n`$，  

将上式转换为Quadratic optimization问题：  

Minimize:

$`-\sum^{n}_{i=1}{f_i}r_i+\frac{1}{2}\sum^{n}_{i}\sum^{n}_{j}cov(r_i,r_j)f_i f_j`$  

subject to: 

$`\sum^{n}_{i=1}{f_i}=1 `$  
$`-f_i<=0,i=1,...`$  



## 2.2 Solve QP by CVXOPT 

$`
  Q=  \begin{bmatrix}
   cov(r_0,r_0)      & cov(r_0,r_1)      & \cdots & cov(r_0,r_n)      \\
   cov(r_1,r_0)      & cov(r_1,r_1)      & \cdots & cov(r_1,r_n)      \\
   \vdots & \vdots & \ddots & \vdots \\
   cov(r_n,r_0)      & cov(r_n,r_1)      & \cdots & cov(r_n,r_n)      \\
  \end{bmatrix}
`$

$`
  G= - \begin{bmatrix}
   1      & 0      & \cdots & 0      \\
   0      & 1      & \cdots & 0      \\
   \vdots & \vdots & \ddots & \vdots \\
   0      & 0      & \cdots & 1      \\
  \end{bmatrix}
`$

$`h^T=[0,...,0]`$

$`A=[1,...,1]`$

$`b=1`$  

将所有numpy array 转换为CVXOPT (Python package) matrix调用sol=solvers.qp(Q,p,G, h, A, b)可解
sol['x']即为所解结果。

sol['Y']即为标准式r=cash return,sol['primal objective']与解的可靠性有关