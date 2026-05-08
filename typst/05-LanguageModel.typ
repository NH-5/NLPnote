= 语言模型

== 语言模型

语言模型(language model, LM)的任务是为一个词序列赋予概率, 即估计一句话“出现得有多自然”.  
设句子为
$
  W = (w_1, w_2, dots, w_m)
$
则语言模型要估计
$
  P(W) = P(w_1, w_2, dots, w_m)
$

由概率链式法则可展开为:
$
  P(W) = product_(i=1)^m P(w_i | w_1, dots, w_(i-1))
$

这一定义非常基础, 但直接建模困难: 条件历史会随着$i$增长而不断变长, 参数空间巨大.  
因此实际模型通常会引入近似假设, 例如后面的 n-gram 假设.

语言模型在 NLP 中的典型用途包括:

- 机器翻译中的目标句流畅性建模.
- 语音识别中的候选句打分.
- 输入法与拼写纠错中的候选排序.
- 文本生成中的下一个词预测.

为了评估语言模型, 常用困惑度(perplexity, PPL):
$
  "PPL"(W) = P(W)^(-1/m)
$
在测试集$D$上常写作:
$
  "PPL"(D)
  = exp(
      - 1/N sum_(k=1)^N log P(w_k | "history")
    )
$
其中$N$是测试集中词的总数. 困惑度越小, 一般表示模型对数据拟合越好.

== n-gram模型

n-gram 模型通过$(n-1)$阶马尔可夫假设简化链式法则:
$
  P(w_i | w_1, dots, w_(i-1))
  approx
  P(w_i | w_(i-n+1), dots, w_(i-1))
$

于是句子概率近似为:
$
  P(W) approx product_(i=1)^m P(w_i | w_(i-n+1), dots, w_(i-1))
$

常见特例:

- 一元模型(unigram): $P(w_i)$, 忽略上下文.
- 二元模型(bigram): $P(w_i|w_(i-1))$.
- 三元模型(trigram): $P(w_i|w_(i-2),w_(i-1))$.

实际实现时常在句首加入`<BOS>`, 句尾加入`<EOS>`, 统一处理不同长度句子.

n 取值越大, 上下文越长, 表达能力越强, 但:

- 参数数量指数增长.
- 训练数据需求更高.
- 稀疏问题更严重.

因此 n-gram 的核心矛盾是“上下文信息量”与“可估计性”的平衡.

== 模型参数的估计方法---极大似然估计

给定训练语料, n-gram 参数最直接的估计是极大似然估计(maximum likelihood estimation, MLE).

若记计数函数$C(h,w)$为历史$h$与词$w$拼接后字符串在语料中的出现次数,  
对于 bigram:
$
  hat(P)_("MLE")(w_i | w_(i-1))
  = C(w_(i-1), w_i) / C(w_(i-1))
$

对一般 n-gram:
$
  hat(P)_("MLE")(w_i | w_(i-n+1)^(i-1))
  = C(w_(i-n+1)^i) / C(w_(i-n+1)^(i-1))
$
其中$w_a^b$表示从$a$到$b$的词序列.

MLE直观且计算简单: 条件概率就是“在某个历史下, 某词出现的相对频率”.  
但它有一个关键问题: 若某个 n-gram 在训练集中未出现, 估计概率直接为$0$,  
会使包含该 n-gram 的整句概率为$0$.

训练时常通过最大化对数似然:
$
  L(theta) = sum_(W in "Train") log P_theta(W)
$
对于 n-gram 模型, 其解正是上述计数比值形式.

这里有一个例子, 可以更好展示如何计算概率.
假设我们有3个句子作为语料:
```text
[B]The cat is walking[E]
[B]The dog is swimming[E]
[B]The dog is running[E]
```
现在我们计算句子`The dog is walking`和句子`The dog is watching`的概率.  
这里把`[B]`看作句首标记, `[E]`看作句尾标记, 并采用 bigram 模型.

先统计本例会用到的 bigram 计数:

- $C("B", "The") = 3$, $C("The") = 3$
- $C("The", "dog") = 2$
- $C("dog", "is") = 2$, $C("dog") = 2$
- $C("is", "walking") = 1$, $C("is", "watching") = 0$, $C("is") = 3$
- $C("walking", "E") = 1$, $C("walking") = 1$

按 MLE 公式
$
  hat(P)_("MLE")(w_t | w_(t-1)) = C(w_(t-1), w_t) / C(w_(t-1))
$

1. 句子`The dog is walking`的概率
$
  P("The dog is walking")
  = P("The"|"[B]") P("dog"|"The") P("is"|"dog") P("walking"|"is") P("[E]"|"walking")
$
逐项代入:
$
  P("The"|"[B]") = 3/3 = 1
$
$
  P("dog"|"The") = 2/3
$
$
  P("is"|"dog") = 2/2 = 1
$
$
  P("walking"|"is") = 1/3
$
$
  P("[E]"|"walking") = 1/1 = 1
$
相乘得到:
$
  P("The dog is walking") = 1 times 2/3 times 1 times 1/3 times 1 = 2/9
$

2. 句子`The dog is watching`的概率
$
  P("The dog is watching")
  = P("The"|"[B]") P("dog"|"The") P("is"|"dog") P("watching"|"is") P("[E]"|"watching")
$
其中关键项:
$
  P("watching"|"is") = C("is","watching") / C("is") = 0/3 = 0
$
所以整句概率立刻为:
$
  P("The dog is watching") = 0
$
这就是 MLE 在数据稀疏场景中的零概率问题.


== 数据稀疏问题

自然语言满足长尾分布: 高频词很少, 低频词非常多.  
即使语料很大, 也会有大量“合理但未见”的 n-gram.

数据稀疏带来的直接后果:

- 零概率问题: 未见组合概率为$0$.
- 估计不稳定: 低频计数方差大, 易过拟合.
- 泛化能力差: 测试域稍有变化就性能下降.

例如在 trigram 中, 若训练语料未出现`机器 学习 方法`, 则
$
  hat(P)_("MLE")("方法" | "机器", "学习") = 0
$
这并不表示该短语不可能, 只是“样本没覆盖到”.

应对稀疏问题常配套使用:

- 词表裁剪与`<unk>`机制.
- 回退(back-off)到低阶模型.
- 插值(interpolation)融合多阶信息.
- 平滑(smoothing)重新分配概率质量.

== n-gram模型的平滑

平滑的目标是: 在不破坏整体概率分布的前提下,  
从高频事件中“拿出一点概率质量”, 分配给低频或未见事件.

理想的平滑应同时满足:

- 见过的高频 n-gram 概率仍然较高.
- 低频 n-gram 被适度下调而非清零.
- 未见 n-gram 获得非零概率.
- 条件分布仍满足归一化.

=== 加法平滑法

加法平滑(add-k smoothing)对每个计数统一加常数$k > 0$:
$
  hat(P)_(+k)(w | h)
  = (C(h, w) + k) / (C(h) + k |V|)
$
其中:

- $h$表示历史上下文.
- $|V|$是词表大小.

当$k=1$时称为 Laplace 平滑(加一平滑).

优点:

- 形式简单, 实现方便.
- 能保证任何词在任一上下文下概率非零.

缺点:

- 对所有词一刀切加同样的量, 偏差较大.
- 对大词表任务通常会过度惩罚高频事件.

因此在实际语言建模中, 加一平滑一般只用于教学或基线.

现在我们用加一平滑对前文那个例子再做一次计算.

设$k=1$, 并把候选词表取为
$
  V = {"The","cat","dog","is","walking","swimming","running"}
$
故$|V| = 7$.
对词的加一平滑公式为:
$
  hat(P)_(+1)(w|h) = (C(h,w)+1)/(C(h)+|V|)
$

下面计算两句的每一项条件概率.

1. 句子`The dog is walking`
$
  P_(+1)("The dog is walking")
  = P("The"|"[B]") P("dog"|"The") P("is"|"dog") P("walking"|"is") P("[E]"|"walking")
$
$
  P("The"|"[B]") = (3+1)/(3+7) = 4/10 = 2/5
$
$
  P("dog"|"The") = (2+1)/(3+7) = 3/10
$
$
  P("is"|"dog") = (2+1)/(2+7) = 3/9 = 1/3
$
$
  P("walking"|"is") = (1+1)/(3+7) = 2/10 = 1/5
$
$
  P("[E]"|"walking") = (1+1)/(1+7) = 2/8 = 1/4
$
所以:
$
  P_(+1)("The dog is walking")
  = 2/5 times 3/10 times 1/3 times 1/5 times 1/4
  = 1/500
  = 2.0 times 10^(-3)
$

2. 句子`The dog is watching`
$
  P_(+1)("The dog is watching")
  = P("The"|"[B]") P("dog"|"The") P("is"|"dog") P("watching"|"is") P("[E]"|"watching")
$
前3项与上面相同, 只需算后两项(此处将`watching`视为未见词, 即$C("is","watching")=0$):
$
  P("watching"|"is") = (0+1)/(3+7) = 1/10
$
$
  P("E"|"watching") = (0+1)/(0+7) = 1/7
$
故:
$
  P_(+1)("The dog is watching")
  = 2/5 times 3/10 times 1/3 times 1/10 times 1/7
  = 1/1750
  approx 5.71 times 10^(-4)
$

可以看到, 加一平滑后未见组合不再是$0$,  
且该例中`walking`句仍比`watching`句概率更高.


=== 减值平滑法

减值(discounting)思想是:  
先把已见事件的计数或概率按规则“减小”, 再把腾出的质量分给未见事件.

与简单加法平滑相比, 减值法通常更符合词频分布规律, 实践效果更好.

==== Good-Turing法

Good-Turing基于“频次的频次”(counts of counts).  
记$N_r$为“出现次数恰好为$r$的 n-gram 类型数”, 则把原始计数$r$调整为:
$
  r^* = (r+1) N_(r+1) / N_r
$

据此可得到调整后的概率估计:
$
  P_("GT") "prop.to" r^*
$

其核心意义在于:

- 不直接看某个 n-gram 本身, 而看“同频组”的统计规律.
- 能较合理估计低频事件, 尤其是$r=0,1$附近.

一个常用结论是未见事件总概率质量约为:
$
  P_("unseen") approx N_1 / N
$
其中$N$是总 token 数.

Good-Turing 常作为其他平滑方法(如 Katz)中的折扣来源.

==== Katz回退法

Katz back-off 的做法是分段处理:

- 对高频 n-gram 使用 MLE 或轻微折扣.
- 对低频 n-gram 使用 Good-Turing 折扣.
- 对未见 n-gram 回退到低阶模型并乘回退系数.

形式上可写为:
$
  P_("Katz")(w|h) = d_(c(h,w)) * C(h,w) / C(h), quad "if" C(h,w) > 0
$
$
  P_("Katz")(w|h) = alpha(h) P_("Katz")(w|h'), quad "if" C(h,w) = 0
$
其中$h'$是去掉最左词后的低阶历史, $alpha(h)$保证归一化.

Katz 的优势在于:

- 充分利用高阶上下文.
- 对未见事件用低阶分布兜底.
- 通常显著优于简单加法平滑.

==== 绝对减值法

绝对减值(absolute discounting)对所有已见事件统一减去常数$d$:
$
  C^*(h,w) = max(C(h,w)-d, 0), quad 0 < d < 1
$

对应条件概率可写为:
$
  P_("AD")(w|h)
  = (max(C(h,w)-d, 0))/C(h)
    + alpha(h) P_("AD")(w|h')
$

其中$alpha(h)$用于把减去的总质量分配到未见事件.  
如果记$T(h)$为历史$h$后出现过的不同词个数(types),  
则从该历史释放出的概率质量约为:
$
  gamma(h) = d T(h) / C(h)
$

绝对减值结构简单且效果稳定, 是很多实用平滑方法的基础.

==== 线形减值法

这里通常指线性插值(linear interpolation):  
不再“只在缺失时回退”, 而是同时混合多阶模型:
$
  P_("interp")(w_i | w_(i-2), w_(i-1))
  = lambda_3 P(w_i | w_(i-2), w_(i-1))
  + lambda_2 P(w_i | w_(i-1))
  + lambda_1 P(w_i)
$
$
  lambda_1 + lambda_2 + lambda_3 = 1, quad lambda_j >= 0
$

优点:

- 不依赖“是否见过”这一硬切换, 更平滑.
- 低阶模型可持续提供稳健概率支撑.

插值权重$lambda_j$通常在开发集上估计, 方法包括:

- 网格搜索.
- EM估计.
- 按上下文频次自适应设权.

线性插值与绝对减值结合后, 可进一步得到效果很强的改进模型(如 Kneser-Ney 系列方法).
