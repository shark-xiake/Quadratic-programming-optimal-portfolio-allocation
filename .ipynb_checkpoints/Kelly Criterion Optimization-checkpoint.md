# 1 Definitions
Given N stocks in a window of T days, $R_{it}$  is the return of the $`i`$th ($`i\in [0,...,N-1]`$) stock on the t-th ($`t \in [0,...,T-1]`$) day. 
We assume the return matrix can be explained by $`M`$ factors. F is the factor matrix of $`M \times T`$. $`\beta`$ is the loading matrix of $`N \times M`$.

$`
R = \mu + \beta*F + \epsilon
`$

# 1.1数据获取
以中证500为基准，选取192只标的股票作为股票池，抽取2015-01-01至2015-12-31的数据，剔除缺损数据大于10%的股票，使用fillna(method='ffill')与
fillna(method='bfill')进行数据补全后剔除方差为零的数据，最终剩余118个股票


# 2 模型的训练

将抽取的数据按照window_size, W=60， step=1, 进行窗口分割。
指定窗口 w, stock return matrix $`R_w`$， 进行PCA分解。保留计算结果中的10($`M=10`$)个特征向量 matrix, V, of dimension $`N \times M`$.

$`
\begin {aligned}
  V_w = [v_0,...,v_9], \\
  f_m = v_m*R_w
\end {aligned}
`$

加入常数项，得到 the w-th Factor matrix $`F_w`$ for the $`w`$th window. Note the $`\mu=\beta_{10}`$ is included in $`\beta`$ matrix, as the last $`\beta`$.

```math
F_w = [f_0,...,f_9, 1]
```

Via the least-squares regression, we obtain estimates for $`\hat \beta`$ and the residual $`\epsilon_i`$ of stock i, 

```math
\hat R_i=\sum^{10}_{m=0} \hat \beta_m *f_m,
\epsilon_i = R_i - \hat R_i, 

X^i_t=\sum^t_{k=0}\epsilon^i_k
```
建立其AR(1)模型

```math
X_i^t=a+b*X_i^{t-1} +\zeta
```

选定窗口的时间长度为 W=60, 即：

```math
\max(w)=60
```

检验每个股票AR(1)模型的b值与R2拟合程度选择交易的股票。
模型的训练完成。

# 3 交易过程：

## 3.1 model0
指定窗口 $`w`$, stock return matrix $`R[w]`$，在$`R[w2]`$上训练模型，$`R[w2]`$,$`w2=w+T`$上测试，
使用训练阶段生成的pca特征向量 $`V_w`$ 生成因子

```math
F_t = V_w*win\_list[w2],  (t \in [w2,...,w2+T-1])
```
进一步使用训练阶段得到的多因子模型的loading matrix $`\beta`$计算残差:

```math
F^t = [f^t_0,...,f^t_9,1], 

\hat R^t_i=\sum^{10}_{m=0} \hat \beta_m *f^t_m, 

\epsilon^i_t=\hat R^i_t-R^i_t, 
X^i_t=\sum^t_{k=0}\epsilon^i_k
```
保持训练阶段的AR(1)模型的参数a,b不变得到股票i在时刻T的交易信号

```math
M_i=\frac{a_i}{1-b_i}, s^i_t=\frac{X^i_t-M_i}{\sigma_{eq}}
```
根据$`s^i_t`$的大小进行交易
同时对AR(1)模型的$`R^2`$量检验拟合度

```math
\zeta^i_t=X^i_t-a-b*X_i^{t-1},

{R^i_t}^2=1-\frac{\sum^t_{k=t-T} {\zeta^i_k}^2}{\sum^t_{k=t-T} (X^i_k-\bar X^i)^2}
```

如果$`s^i_t < -1.25`$ 开始交易
如果$`s^i_t > -0.5`$ 关闭交易
如果$`R^2 <0.78`$ 关闭交易

## 3.2 model1

引入trade的概念，一个trade包括选股，生成trade，交易三个过程。
step1:指定窗口选股，参照model0的计算方式选取AR过程拟合度高及$`\beta`$值小的股票，作为候选股票。
step2:按照step=1滑动窗口，每滑动一次窗口就进行一次model0的训练过程，令：
```math
X^i_t=0, 

s^i_0=\frac{X^i_t-M_i}{\sigma_{eq}},

s^i_0=\frac{-M_i}{\sigma_{eq}}
```
如果候选股票的$`s^i_0 > -1.25`$且多因子阶段的拟合度高则为该股票生成trade，并开始交易。

step3:没有生成trade的候选股票继续执行step2.已生成trade的股票,使用建立trade时产生的模型参数，
按照model0的方式生成多因子阶段的残差项$`X^i_t$对信号进行校正跟踪：
```math
s^i_t=\frac{X^i_t-M_i}{\sigma_{eq}}
```
如果$`s^i_t < -1.25`$ 继续买进
如果$`s^i_t > -0.5`$ 关闭交易
信号跟踪过程中如果AR模型的拟合度太低则强制关闭交易。



# 4 结果分析


![](img/000685_9.png)

A1

![](img/000685_10.png)

A2

![](img/000685_29.png)

A3

Figure A: 000685在第9，10,29窗口的 signal，price,kappa，return的变化
由图A1和图A2可以看到图像的训练数据相差一天的情况下kappa部分出现了明显的变化，signal并没有出现显著
变化。图A3kappa靠近起始的部分出现了一段跌落为负值的现象。

![](img/000681_18.png)

B1

![](img/000681_26.png)

B2

Figure B: 000681在第18,26窗口的 signal，price,kappa，return的变化
图B1是一个理想状态下参数的变化，图B2显示在第26个窗口时signal的数值持续降低导致交易无法关闭。

![](img/600611_8.png)

C1

![](img/600611_32.png)

C2

![](img/600611_56.png)

C3

![](img/600611_112.png)

C4

Figure C: 600611在第32,56,112窗口的 signal，price,kappa，return的变化C3,C2在训练阶段
有28天的数据是重叠的，C1图中的price包含了C3的训练阶段48天的price数据，能够大体上反映C3训练时
期的price状态，该阶段的数据覆盖了上升到回落的过程。在测试阶段的数据是在一定范围内变化的没有持续
的上涨或下跌，训练阶段的price稍高于测试阶段的price，尽管C3的交易周期稍长但收益是正向的。
C3图中的price基本上涵盖了C4训练期的price.训练期price高于测试阶段的price水平。C4的signal在
后期走势出现异常。其多因子拟合的$`\hat R_t`$与测试阶段的真实$`R_t`$呈负相关。

![](img/600611_20_9.png)

D1

![](img/600611_36_9.png)

D2

![](img/model1trading.png)

D21

Figure D:窗口长度为90时600611在20,36个窗口的signal， price, kappa，return的变化。
D21为model1的图。



# 5 问题
model0

1. 对于signal可能会出现持续下降，最终导致持续的买入，交易只能强行关闭。
1. Signal在某些情况下会出现错误的买入信号(如C4 的情况). 这个问题可能是因为测试阶段的数据发生了剧
烈的变化导致模型在多因子阶段的拟合出现问题，此时需要改变模型或及时止损。
1. 对于交易时间不定的问题可以考虑持续进行pca分解，再出现买入信号后固定 $`V_w`$ open交易直到交易
关闭。

model1计算过程的拟合问题，track signal阶段对AR模型进行拟合度检验优于对多因子模型检验

# 6 总结
model0模型总体收益为3.4%.120个窗口66个窗口收益为正。总共产生了1166笔交易633个为正，平均年化收益率16.1%.

model1解决了问题3交易时间不定的问题。每一个trade的生成时间，即为第一笔买入的时间。采用model1
模型剔除重复交易后120个窗口的收益43个为负，57个为正。总体收益率为6%。不剔除重复交易120窗口中119
个收益为正，总体收益率12%。共计242笔交易，134个为正，105个为负。每笔交易平均年化收益率65.3%。
对signal进行去中心化处理无显著影响。

![](img/firstsignal.png)

E1.首次买进信号分布图

![](img/annualize.png)

E2.年化收益率分布图


![](img/signal_profit.png)

E3.首次买进信号与绝对收益

![](img/signal_rate.png)

E4.首次买进信号与收益率

![](img/signal_annualize.png)

E5.首次买进信号与年化收益率

![](img/PcaTradingInd3.png)

F1.第3个窗口的交易股票pca图

![](img/PcaTradingInd6.png)

F2.第6个窗口的交易股票pca图

![](img/PcaTradingInd18.png)

F3.第18个窗口的交易股票pca图

![](img/pca_merge.png)

F3.全部股票pca图


