#import "template/template/third-lib-config/commute.typ": node, arr, commutative-diagram

= 句法分析

句法分析(syntactic parsing)是在句子层面上进行的形式化分析.  
它关心的不是一句话在现实世界中是否合理, 而是这句话在语法形式上如何由词语、短语和句子成分组成.

在一个典型的 NLP 流水线中, 句法分析位于词法分析之后、语义分析之前:

```text
字符串 -> 词法分析 -> 句法分析 -> 语义分析
```

#figure(
  align(center,
    commutative-diagram(
      node-padding: (42pt, 24pt),
      padding: 8pt,

      node((0, 0), [原始字符串], "pipe-raw"),
      node((0, 2), [词法分析], "pipe-lex"),
      node((0, 4), [句法分析], "pipe-syn"),
      node((0, 6), [语义分析], "pipe-sem"),

      node((1, 2), [词、词性、实体], "pipe-lex-out"),
      node((1, 4), [结构树或依存树], "pipe-syn-out"),

      arr("pipe-raw", "pipe-lex", []),
      arr("pipe-lex", "pipe-syn", []),
      arr("pipe-syn", "pipe-sem", []),
      arr("pipe-lex", "pipe-lex-out", []),
      arr("pipe-syn", "pipe-syn-out", []),
    )
  ),
  caption: [句法分析在 NLP 流水线中的位置]
)

句法分析的核心目标可以概括为两类:

- 确定句子的句法结构, 即构成式结构或句法分析树.
- 确定词汇之间的依存关系, 即哪个词支配哪个词.

课件把这个概念拆成三个角度理解:

- 定义: 句子层面上的形式化分析.
- 特点: 以整个句子为分析单位, 只处理语法形式, 不直接处理语义真假.
- 目的: 输出句法结构, 或输出词汇之间的依存关系.

例如句子“亚里士多德吃了一个地球。”从语法形式上看是一个合格句子,  
虽然它在常识语义上不合理.  
这说明句法分析主要处理形式层面的语法结构, 不直接判断句子的真实语义.

== 句法分析概述

=== 句法分析的主要任务

课件中将句法分析分为三类任务:

#figure(
  table(
    columns: (auto, auto, auto),
    [任务], [关注对象], [典型输出],
    [句法结构分析], [完整句子的层次结构], [句法分析树],
    [浅层句法分析], [局部短语块], [Base NP、VG、PP 等语块],
    [依存句法分析], [词与词之间的支配关系], [依存图或依存树]
  )
)

其中句法结构分析也常称为完全句法分析(full parsing).  
如果不作特别说明, “句法分析树”通常指完全句法分析得到的树状结构.

=== 句法结构与依存关系

句法结构分析和依存句法分析看待句子的角度不同.

句法结构分析把句子看作由短语逐层组成的结构, 例如:

```text
S
├── NP
└── VP
```

依存句法分析则把句子看作词与词之间的支配关系网络, 例如:

```text
讲话 -> 汤姆
讲话 -> 在
```

前者强调“短语如何组成句子”, 后者强调“词语之间谁支配谁”.  
二者都属于句法层面的形式化描述.

#figure(
  table(
    columns: (auto, auto, auto),
    [输入句子], [成分句法视角], [依存句法视角],
    [`汤姆 在 讲话`], [`S -> NP VP`], [`讲话 -> 汤姆`, `讲话 -> 在`],
    [核心问题], [哪些词组成短语, 短语怎样组成句子], [哪个词支配哪个词],
    [结构中心], [短语与层级], [词与词之间的边]
  ),
  caption: [成分结构与依存结构的观察角度]
)

== 句法结构分析

=== 基本概念

句法结构分析(syntactic structure parsing)是指:  
给定一个输入单词序列, 判断它是否符合给定语法规则, 并确定符合这些规则的句法结构.

句法分析树(syntactic parsing tree)是用树状数据结构表示的句法结构.  
树中通常包含:

- 根节点: 整个句子, 常记为$S$.
- 内部节点: 短语或非终结符, 如`NP`、`VP`、`PP`.
- 叶节点: 输入句子中的词或终结符.

例如句子:

```text
The can can hold the water
```

其中第一个 `can` 可作名词, 第二个 `can` 可作助动词.  
在一种合理分析中, 句法树可表示为:

#figure(
  align(center,
    commutative-diagram(
      node-padding: (32pt, 24pt),
      padding: 8pt,

      node((0, 4), [$S$], "s"),

      node((1, 2), [$"NP"$], "np1"),
      node((1, 6), [$"VP"$], "vp1"),

      node((2, 1), [The], "the1"),
      node((2, 3), [can], "can1"),
      node((2, 5), [can], "can2"),
      node((2, 7), [$"VP"$], "vp2"),

      node((3, 6), [hold], "hold"),
      node((3, 8), [$"NP"$], "np2"),

      node((4, 7), [the], "the2"),
      node((4, 9), [water], "water"),

      arr("s", "np1", []),
      arr("s", "vp1", []),
      arr("np1", "the1", []),
      arr("np1", "can1", []),
      arr("vp1", "can2", []),
      arr("vp1", "vp2", []),
      arr("vp2", "hold", []),
      arr("vp2", "np2", []),
      arr("np2", "the2", []),
      arr("np2", "water", []),
    )
  ),
  caption: [句子 `The can can hold the water` 的一种句法结构]
)

从这个例子可以看出, 句法结构分析需要两类语言知识:

- 语法规则库, 如 `S -> NP VP`、`VP -> V NP`.
- 词典或词法信息, 如 `can` 可以是名词、助动词或动词.

句法分析的本质就是:  
从语法规则库中搜索一组能够合理解释输入句子的规则, 并把这些规则组织成树.

=== 人工规则方法与统计方法

构建句法结构分析器时, 关键问题有两个:

- 如何构建语法规则库.
- 如何设计基于规则库的搜索或推理算法.

更具体地说, 一个好的规则库需要把语言中的语法规律写成可计算的规则模板:  
人能够解释清楚, 计算机也能够根据模板存储、匹配和推理.  
推理算法则本质上是在规则库中搜索一条解释链:  
从底层词语或词性出发, 按规则逐步合成为短语, 最后合成为完整句子.

按规则库来源, 可分为两种基本路线.

#figure(
  align(center,
    commutative-diagram(
      node-padding: (34pt, 22pt),
      padding: 8pt,

      node((0, 3), [语法规则库], "rules"),

      node((1, 1), [人工编写], "manual-rules"),
      node((1, 5), [机器学习], "stat-rules"),

      node((2, 1), [CFG 模板], "cfg-template"),
      node((2, 5), [PCFG 模板], "pcfg-template"),

      node((3, 1), [CYK 等穷举式搜索], "cyk-search"),
      node((3, 5), [Viterbi / 改进 CYK], "vit-search"),

      node((4, 3), [句法分析树], "tree-out"),

      arr("rules", "manual-rules", []),
      arr("rules", "stat-rules", []),
      arr("manual-rules", "cfg-template", []),
      arr("stat-rules", "pcfg-template", []),
      arr("cfg-template", "cyk-search", []),
      arr("pcfg-template", "vit-search", []),
      arr("cyk-search", "tree-out", []),
      arr("vit-search", "tree-out", []),
    )
  ),
  caption: [句法结构分析器的两条典型路线]
)

==== 基于人工规则的方法

人工规则方法由人手工组织语法规则, 建立语法知识库, 再根据规则穷举式地推导句法分析树.

常见框架是:

```text
人工编写 CFG 规则库 -> 输入句子 -> 搜索算法 -> 句法分析树
```

其中 CFG 常作为人工编写规则的模板, CYK 等算法则用于在规则库中高效搜索可行结构.

优点:

- 原理简单, 规则含义直观.
- 容易用于教学和小规模封闭领域.

缺点:

- 规则有限时, 长句和复杂句难以分析.
- 句子有多种结构时, 难以判断哪一棵树最好.
- 人工规则具有主观性.
- 编制和维护规则的工作量巨大.

==== 基于统计的方法

统计方法使用训练数据自动抽取语法规则, 并给规则或分析结果附加概率.  
典型模型包括 PCFG 及其改进模型.

常见框架是:

```text
标注树库 -> 规则抽取与参数估计 -> 输入句子 -> 动态规划搜索 -> 最优句法树
```

这里 PCFG 常作为机器从树库中抽取规则的模板;
Viterbi、改进 CYK 等动态规划算法则用于在多个候选结构中寻找最优结构.

课件中把这种搜索称为启发式搜索:
它不是盲目枚举所有可能树, 而是用概率或得分引导搜索方向,
在保留可解释结构的同时尽量减少无效展开.

优点:

- 降低人工编制规则的工作量和主观性.
- 学到的规则更贴近训练语料中的真实语言现象.
- 能在多个候选结构中选择概率最高的结构.

== CFG 文法模型回顾

=== CFG 的定义

上下文无关文法(context-free grammar, CFG)通常写作四元组:
$
  G = (N, Sigma, P, S)
$
其中:

- $N$是非终结符集合, 如`S`、`NP`、`VP`.
- $Sigma$是终结符集合, 即句子中最终出现的词或符号.
- $P$是产生式规则集合.
- $S$是开始符号, 表示句子起点.

CFG 的产生式具有形式:
$
  A -> gamma
$
其中$A in N$, $gamma in (N union Sigma)^*$.

“上下文无关”的含义是:  
规则左侧只有一个非终结符, 因而展开$A$时不需要查看它前后出现了什么符号.

例如:

```text
S  -> NP VP
NP -> Art N
VP -> Aux VP
VP -> V NP
```

这些规则描述的是短语如何组合成更大的短语或句子.

=== 用 CFG 生成句法树

用 CFG 生成句法树的一般过程是:

1. 用开始符号$S$初始化句子.
2. 若当前符号串中仍有非终结符, 就选择一个非终结符继续展开.
3. 从规则集合$P$中找出左侧匹配的规则, 替换该非终结符.
4. 重复直到所有符号都变成终结符.

例如:

```text
S
=> NP VP
=> Art N VP
=> The can VP
=> The can Aux VP
=> The can can V NP
=> The can can hold Art N
=> The can can hold the water
```

这个过程可以看作从根节点向叶节点生长句法树.  
如果用深度优先搜索枚举所有可能规则, 方法直观但效率很低,  
因此实际句法分析常使用动态规划算法, 例如 CYK.

== CFG + CYK 算法

=== 乔姆斯基范式

CYK(Cocke-Younger-Kasami)算法要求文法满足乔姆斯基范式(Chomsky Normal Form, CNF).  
在 CNF 中, 产生式通常只有两种形式:

```text
A -> B C
A -> w
```

其中$A, B, C$是非终结符, $w$是终结符.  
这种形式使得任意非叶节点都恰好有两个子节点, 方便用区间动态规划处理.

若原始 CFG 中存在三元规则、长规则或单位规则, 需要先进行范式化.  
例如:

```text
S -> VP Aux NP
```

可以引入新符号$X_("AuxNP")$:

```text
S           -> VP X_AuxNP
X_AuxNP    -> Aux NP
```

范式化不会改变文法能生成的终结符串, 只是改变中间非终结符的组织方式.

#figure(
  align(center,
    commutative-diagram(
      node-padding: (42pt, 24pt),
      padding: 8pt,

      node((0, 2), [`S -> VP Aux NP`], "cnf-old"),
      node((1, 0), [`S -> VP X_AuxNP`], "cnf-new-1"),
      node((1, 4), [`X_AuxNP -> Aux NP`], "cnf-new-2"),
      node((2, 2), [每条规则右侧至多两个符号], "cnf-goal"),

      arr("cnf-old", "cnf-new-1", []),
      arr("cnf-old", "cnf-new-2", []),
      arr("cnf-new-1", "cnf-goal", []),
      arr("cnf-new-2", "cnf-goal", []),
    )
  ),
  caption: [把三元产生式二叉化为 CNF 友好的形式]
)

=== CYK 的核心思想

CYK 把句法分析转化为三角表填充问题.  
给定句子:
$
  W = w_1 w_2 dots w_n
$
定义表项$T[i,j]$表示能够推出子串$w_i dots w_j$的非终结符集合.

算法自底向上填表:

1. 初始化长度为 1 的子串:
$
  T[i,i] = {A | A -> w_i}
$

2. 按子串长度从短到长递推.  
   对每个区间$[i,j]$, 枚举切分点$k$:
$
  [i,j] = [i,k] + [k+1,j]
$

3. 若存在规则$A -> B C$, 且
$
  B in T[i,k], quad C in T[k+1,j]
$
则把$A$加入$T[i,j]$.

4. 若最终$S in T[1,n]$, 则句子可由文法生成.

伪代码如下:

```text
for i = 1..n:
  T[i,i] = {A | A -> w_i}

for length = 2..n:
  for i = 1..n-length+1:
    j = i + length - 1
    for k = i..j-1:
      for each rule A -> B C:
        if B in T[i,k] and C in T[k+1,j]:
          add A to T[i,j]
          record backpointer (A, k, B, C)
```

其中 backpointer 用于最后回溯得到具体的句法树.  
如果一个格子中同一个非终结符有多个来源, 就可能对应多棵分析树.

课件中三角表的“取值规律”可以理解为对切分点枚举的可视化记忆:

- 横向从目标格左侧可组合的子区间取值.
- 纵向从与横向跨度配对的位置向下取值.
- 每一对横纵取值都对应一个切分点$k$, 本质上仍是在检查$T[i,k]$和$T[k+1,j]$能否通过某条规则合成父节点.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    [递推对象], [左半区间], [右半区间], [得到的父节点],
    [$T[i,j]$], [$T[i,k]$], [$T[k+1,j]$], [$A$],
    [条件], [$B in T[i,k]$], [$C in T[k+1,j]$], [存在规则$A -> B C$],
    [记录], [子树$B$], [子树$C$], [backpointer: $(A,k,B,C)$]
  ),
  caption: [CYK 的一个格子由所有可能切分点共同决定]
)

=== CYK 的特点

CYK 算法有三个重要特点:

- 要求文法先转为 CNF 或近似 CNF.
- 使用自底向上的动态规划, 避免重复分析同一子串.
- 既可以判断句子是否符合文法, 也可以通过回溯得到一棵或多棵句法树.

动画页中的“记住分叉点”和“倒退回分叉点”对应的就是 backpointer:  
填表时记录候选来源, 回溯时沿这些来源恢复所有可能结构.  
课件中把表格逆时针旋转 90 度, 只是为了让区间组合过程更接近树的视觉形状.

朴素实现的主要复杂度为:
$
  O(n^3 |G|)
$
其中$n$是句子长度, $|G|$可理解为可枚举的二元产生式数量.

=== CYK 示例: 课后句子

课件作业给出的句子是:

```text
咬 死 了 猎人 的 狗
```

原始文法为:

```text
S   -> VC NP | VP Aux NP
VC  -> v a | VC utl
NP  -> n | NP Aux NP | NP NP
VP  -> VC NP
v   -> 咬
a   -> 死
n   -> 猎人 | 狗
utl -> 了
Aux -> 的
```

为了使用 CYK, 可把三元规则二叉化, 例如:

```text
S        -> VP X_AuxNP
NP       -> NP X_AuxNP
X_AuxNP -> Aux NP
```

其余二元规则保持不变.  
若保留词性预终结符, 初始化时可对单位规则做闭包, 即把`n -> 猎人`和`NP -> n`合并理解为`猎人`可对应`NP`.

表中关键项如下:

```text
T[1,1] = {v}
T[2,2] = {a}
T[3,3] = {utl}
T[4,4] = {n, NP}
T[5,5] = {Aux}
T[6,6] = {n, NP}

T[1,2] = {VC}              # VC -> v a
T[1,3] = {VC}              # VC -> VC utl
T[5,6] = {X_AuxNP}         # X_AuxNP -> Aux NP
T[4,6] = {NP}              # NP -> NP X_AuxNP
T[1,4] = {S, VP}           # S/VP -> VC NP
T[1,6] = {S}               # 两种来源
```

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    [跨度], [1 咬], [2 死], [3 了], [4 猎人], [5 的], [6 狗],
    [1], [`{v}`], [`{a}`], [`{utl}`], [`{n, NP}`], [`{Aux}`], [`{n, NP}`],
    [2], [`{VC}`], [], [], [], [`{X_AuxNP}`], [],
    [3], [`{VC}`], [], [], [`{NP}`], [], [],
    [4], [`{S, VP}`], [], [], [], [], [],
    [5], [], [], [], [], [], [],
    [6], [`{S}`], [], [], [], [], []
  ),
  caption: [“咬 死 了 猎人 的 狗”的 CYK 三角表关键填充结果]
)

$T[1,6]$中$S$至少有两种来源:

```text
S -> VC NP
VC -> 咬 死 了
NP -> 猎人 的 狗
```

以及:

```text
S -> VP X_AuxNP
VP -> VC NP
X_AuxNP -> 的 狗
```

这说明同一句子可产生不同结构解释.  
CYK 表不仅能判断句子可分析, 还可以通过回溯保留这种句法歧义.

#figure(
  align(center,
    commutative-diagram(
      node-padding: (32pt, 24pt),
      padding: 8pt,

      node((0, 4), [$S$], "hw-s1"),
      node((1, 2), [$"VC"$], "hw-vc1"),
      node((1, 6), [$"NP"$], "hw-np1"),
      node((2, 1), [咬], "hw-yao1"),
      node((2, 3), [死了], "hw-si1"),
      node((2, 5), [猎人], "hw-hunter1"),
      node((2, 7), [的狗], "hw-dog1"),

      arr("hw-s1", "hw-vc1", []),
      arr("hw-s1", "hw-np1", []),
      arr("hw-vc1", "hw-yao1", []),
      arr("hw-vc1", "hw-si1", []),
      arr("hw-np1", "hw-hunter1", []),
      arr("hw-np1", "hw-dog1", []),
    )
  ),
  caption: [结构解释一: “咬死了”作谓词, “猎人的狗”作名词短语]
)

#figure(
  align(center,
    commutative-diagram(
      node-padding: (32pt, 24pt),
      padding: 8pt,

      node((0, 4), [$S$], "hw-s2"),
      node((1, 2), [$"VP"$], "hw-vp2"),
      node((1, 6), [$"X_AuxNP"$], "hw-x2"),
      node((2, 1), [$"VC"$], "hw-vc2"),
      node((2, 3), [猎人], "hw-hunter2"),
      node((2, 5), [的], "hw-de2"),
      node((2, 7), [狗], "hw-dog2"),
      node((3, 0), [咬], "hw-yao2"),
      node((3, 2), [死了], "hw-si2"),

      arr("hw-s2", "hw-vp2", []),
      arr("hw-s2", "hw-x2", []),
      arr("hw-vp2", "hw-vc2", []),
      arr("hw-vp2", "hw-hunter2", []),
      arr("hw-x2", "hw-de2", []),
      arr("hw-x2", "hw-dog2", []),
      arr("hw-vc2", "hw-yao2", []),
      arr("hw-vc2", "hw-si2", []),
    )
  ),
  caption: [结构解释二: “咬死了猎人”先组成 VP, 再与“的狗”组合]
)

== PCFG 模型

=== 从 CFG 到 PCFG

CFG 只回答“某条规则能不能用”, 不能回答“哪条规则更可能”.
这也是课件中说“CFG 模型的拟合能力不足”的直接原因:
它能给出语法硬约束, 但不能刻画真实语料中不同结构的偏好差异.

概率上下文无关文法(probabilistic context-free grammar, PCFG)在 CFG 规则上引入概率参数.

一条规则写作:
$
  A -> beta [theta_(A -> beta)]
$
其中$theta_(A -> beta)$表示从$A$展开为$beta$的概率.

对同一个左侧非终结符$A$, 所有候选展开概率之和为 1:
$
  sum_beta theta_(A -> beta) = 1
$

例如:

```text
VP -> V NP     [0.65]
VP -> Aux VP   [0.25]
VP -> V        [0.10]
```

PCFG 与 CFG 的两点关键差异是:

- 规则带有概率参数.
- 规则和概率通常可从标注树库中自动估计.

加入概率后, PCFG 的最大变化不是把规则写得更复杂,  
而是让文法变成一个适合机器从数据中自动学习的模型.  
概率参数还提供了结构偏好: 当一个句子有多棵可行句法树时,  
模型可以比较这些树的好坏程度.

=== 语法树概率

在 PCFG 中, 一棵句法树的概率等于树中所有规则概率的乘积:
$
  P(T | G) = product_(r in T) theta_r
$

若一个句子$W$有多棵候选树, 则最优句法分析通常取概率最大的树:
$
  T^* = "arg max"_(T in "Trees"(W)) P(T | G)
$

这正是 PCFG 相比普通 CFG 的重要优势:  
它不仅能找出“可行结构”, 还能在多个可行结构中选出“更可能的结构”.

#figure(
  align(center,
    commutative-diagram(
      node-padding: (38pt, 26pt),
      padding: 8pt,

      node((0, 3), [$S$], "pcfg-s"),
      node((1, 1), [$"NP"$], "pcfg-np"),
      node((1, 5), [$"VP"$], "pcfg-vp"),
      node((2, 0), [The can], "pcfg-can"),
      node((2, 4), [can], "pcfg-aux"),
      node((2, 6), [$"VP"$], "pcfg-vp2"),
      node((3, 5), [hold], "pcfg-hold"),
      node((3, 7), [the water], "pcfg-water"),

      arr("pcfg-s", "pcfg-np", [$0.9$]),
      arr("pcfg-s", "pcfg-vp", [$0.9$]),
      arr("pcfg-np", "pcfg-can", [$0.4$]),
      arr("pcfg-vp", "pcfg-aux", [$0.25$]),
      arr("pcfg-vp", "pcfg-vp2", [$0.25$]),
      arr("pcfg-vp2", "pcfg-hold", [$0.65$]),
      arr("pcfg-vp2", "pcfg-water", [$0.65$]),
    )
  ),
  caption: [PCFG 通过规则概率给候选句法树打分]
)

=== PCFG 参数估计

若训练语料是带句法树标注的树库, 参数可以用极大似然估计:
$
  theta_(A -> beta)
    = C(A -> beta) / C(A)
$

其中:

- $C(A -> beta)$表示规则$A -> beta$在树库中出现的次数.
- $C(A)$表示所有左侧为$A$的规则出现次数之和.

如果训练数据只有句子而没有树, 则需要把句法树看作隐变量,  
常用 EM 思想或内向-外向算法(inside-outside algorithm)估计规则期望计数.

=== PCFG 的三个基本问题

从模型训练和模型使用角度看, PCFG 常对应三个问题:

1. 概率计算: 给定句子和文法, 计算句子或部分结构的概率.
2. 句法分析: 给定句子, 求概率最大的句法树.
3. 模型学习: 给定训练语料, 估计规则概率参数.

其中$P(W | G)$可以类比语言模型中的句子概率:  
把文法$G$看作一个能够生成句子的模型,  
则$P(W | G)$表示这个模型生成词串$W$的概率.  
若句法树未观测到, 这个概率需要把所有可能句法树的概率加总起来.

与 HMM、CRF 等模型类似, 这些问题分别对应概率计算、最优结构推断和参数学习.

课件对学习要求的划分也可以这样记:

- EM 算法: 需要理解其“在隐变量存在时反复估计期望计数并更新参数”的思想.
- 内向算法: 主要用于计算或优化$P(W | G)$, 作为扩展了解即可.
- 内向-外向算法: 可看作 PCFG 参数学习中的 EM 实现方式.

=== PCFG 系统框架

基于统计方法的句法分析系统通常分成训练和分析两条线:

#figure(
  align(center,
    commutative-diagram(
      node-padding: (38pt, 24pt),
      padding: 8pt,

      node((0, 0), [标注树库], "pcfg-train-treebank"),
      node((0, 2), [规则抽取], "pcfg-rule-extract"),
      node((0, 4), [参数估计], "pcfg-param"),
      node((0, 6), [PCFG 模型], "pcfg-model"),

      node((1, 2), [输入句子], "pcfg-input"),
      node((1, 4), [PCFG + CYK / Viterbi], "pcfg-parser"),
      node((1, 6), [最优句法树], "pcfg-output"),

      arr("pcfg-train-treebank", "pcfg-rule-extract", []),
      arr("pcfg-rule-extract", "pcfg-param", []),
      arr("pcfg-param", "pcfg-model", []),
      arr("pcfg-model", "pcfg-parser", []),
      arr("pcfg-input", "pcfg-parser", []),
      arr("pcfg-parser", "pcfg-output", []),
    )
  ),
  caption: [PCFG 句法分析器的训练与分析框架]
)

训练阶段回答“规则和概率从哪里来”, 分析阶段回答“怎样从候选结构中选最优”.

== PCFG + CYK 算法

普通 CYK 的表项只记录某个非终结符能否推出某段子串.  
PCFG + CYK 进一步在表中记录最佳概率和回溯指针.

设$V[i,j,A]$表示非终结符$A$推出子串$w_i dots w_j$的最大概率.  
初始化:
$
  V[i,i,A] = theta_(A -> w_i)
$

递推:
$
  V[i,j,A]
  =
  max_(A -> B C, i <= k < j)
  theta_(A -> B C) V[i,k,B] V[k+1,j,C]
$

若要得到最优句法树, 对每个最大值保存对应的切分点$k$和子节点$B,C$.  
最后从$V[1,n,S]$回溯即可.

这个递推本质上是 Viterbi 思想在 PCFG 句法分析中的应用.  
若把递推中的`max`换成求和, 则得到所有可能分析树概率总和, 对应内向概率计算.

#figure(
  table(
    columns: (auto, auto, auto),
    [CYK 表项], [CFG 版本], [PCFG 版本],
    [存储内容], [可推出该子串的非终结符集合], [每个非终结符的最佳概率],
    [组合规则], [`A -> B C` 可用即可], [`theta(A -> B C) * left * right` 最大],
    [回溯目标], [枚举可行树], [取概率最大的树],
    [最终判断], [`S in T[1,n]`], [`V[1,n,S]` 是否存在且最大]
  ),
  caption: [普通 CYK 与 PCFG + CYK 的表项差异]
)

=== 动态规划剪枝思想

课件中 PCFG + CYK 的动画页强调了一个关键思想:  
如果一个表格中存在多种可能, 只需要保留概率最大的那种, 因为后续组合都会继续乘以非负概率.

也就是说, 对同一个区间和同一个非终结符$A$, 若有两种来源:

```text
A => ...  概率 0.40
A => ...  概率 0.12
```

在求最优句法树时, 后者可以被剪掉.  
这就是动态规划避免指数级搜索的核心原因.

=== PCFG 的局限与改进

PCFG 的基本独立性假设较强:  
同一个非终结符的展开概率只由该非终结符决定, 不考虑它出现的父节点、兄弟节点、词汇中心等上下文.

因此基础 PCFG 容易出现拟合能力不足:

- 同一个`NP`在主语位置和宾语位置可能有不同展开偏好, 基础 PCFG 无法区分.
- 同一个`VP`内部的动词不同, 其后接成分可能明显不同.
- 只看非终结符类别时, 很难利用词汇语义和搭配信息.

常见改进包括:

- 父节点标注(parent annotation): 把`NP`拆成`NP^S`、`NP^VP`等上下文化符号.
- 水平和垂直 Markov 化: 限制但保留部分祖先或兄弟上下文.
- 词汇化 PCFG: 在短语节点上记录中心词, 让规则概率依赖词汇信息.
- 平滑与回退: 处理稀疏规则和低频组合.

这些改进的目标是提高拟合能力, 同时避免参数空间过大.

== 句法结构分析器的性能评价

句法结构分析器通常与人工标注的标准树(gold tree)比较.

若把一棵句法树看成一组成分(constituent), 每个成分由跨度和标签确定,  
例如`NP[2,4]`表示第 2 到第 4 个词构成一个名词短语, 则可以计算:

$
  P = N_("correct") / N_("pred")
$
$
  R = N_("correct") / N_("gold")
$
$
  F_1 = (2 P R) / (P + R)
$

其中:

- $N_("pred")$是系统预测的成分数.
- $N_("gold")$是人工标准树中的成分数.
- $N_("correct")$是预测正确的成分数.

若比较时要求标签和跨度都正确, 称为 labeled precision/recall.  
若只比较跨度, 不比较标签, 称为 unlabeled precision/recall.

对依存句法分析, 常见指标是:

- UAS(unlabeled attachment score): head 预测正确的词比例.
- LAS(labeled attachment score): head 和依存关系标签都正确的词比例.

== 浅层句法分析

=== 基本概念

浅层句法分析(shallow parsing)只关注局部范围内的语法属性,  
不试图恢复完整句法树, 也不重点处理远距离依存关系.

换句话说, 它关注的是:

```text
把句子拆成若干相对独立的局部块, 并识别每个局部块的类型
```

这种局部块通常称为语块(chunk).

与完全句法分析相比:

#figure(
  table(
    columns: (auto, auto, auto),
    [比较维度], [完全句法分析], [浅层句法分析],
    [目标], [恢复完整层次树], [识别局部语块],
    [结构深度], [递归、层次化], [通常非递归],
    [输出], [完整句法树], [Base NP、VG、PP 等],
    [难度], [更高], [更低],
    [用途], [深层理解与结构推理], [信息抽取、实体识别前处理等]
  )
)

=== 语块类型

根据 Abney 对语块的定义, 浅层句法分析常识别如下类型:

- Base NP: 非递归的名词短语.
- VG: 动词词组.
- PP: 介词短语.
- DP: 副词短语.

其中 Base NP 是最常见的浅层句法分析对象.

=== Base NP

Base NP(base noun phrase)是非递归的基本名词短语.  
它本身是一个名词短语, 但内部不再包含另一个名词短语.

例如:

```text
[the water]
[a good student]
[自然语言处理 课程]
```

都可以看作 Base NP.  
而包含更复杂嵌套结构的名词短语, 需要在浅层分析中拆成更小的局部块.

Base NP 识别常被转化为序列标注问题.  
给定词序列, 对每个词预测其在语块中的位置标签.

常见 IOB 标注如下:

```text
B-NP  名词短语开始
I-NP  名词短语内部
O     不属于当前目标语块
```

例如:

```text
the/B-NP can/I-NP can/O hold/O the/B-NP water/I-NP
```

#figure(
  table(
    columns: (auto, auto, auto, auto, auto, auto, auto),
    [词], [the], [can], [can], [hold], [the], [water],
    [IOB 标签], [`B-NP`], [`I-NP`], [`O`], [`O`], [`B-NP`], [`I-NP`],
    [语块], [`NP` 开始], [`NP` 内部], [语块外], [语块外], [第二个 `NP` 开始], [第二个 `NP` 内部]
  ),
  caption: [Base NP 识别可以转化为 IOB 序列标注]
)

这类任务需要回答三个问题:

- 当前词是否在某个语块内.
- 如果在语块内, 它属于哪类语块.
- 它位于语块的开始、中间还是外部.

常用方法包括基于规则的方法、HMM、CRF、SVM 和神经网络序列标注模型.

== 依存句法分析

=== 依存句法理论

依存句法理论源自法国语言学家 Tesniere 的结构句法理论.  
该理论认为, 句子中的词并不是孤立堆放的, 而是通过“关联”形成整体意义.

例如句子:

```text
汤姆在讲话
```

它不是同时表达“有一个人叫汤姆”和“有人在讲话”两个彼此独立的信息,  
而是表达“讲话这个动作由汤姆发出”.  
这种把词联系起来形成整体意义的句法信息, 就是依存关系.

依存关系可写作:

```text
支配者 -> 被支配者
```

在传统成分句法中, 主语常被突出;  
而依存句法更强调动词中心地位, 关注其他词如何依附于中心动词.

#figure(
  align(center,
    commutative-diagram(
      node-padding: (34pt, 22pt),
      padding: 8pt,

      node((0, 3), [讲话], "talk"),
      node((1, 1), [汤姆], "tom"),
      node((1, 5), [在], "zai"),

      arr("talk", "tom", [SBV]),
      arr("talk", "zai", [ADV]),
    )
  ),
  caption: [句子“汤姆在讲话”的简化依存关系]
)

=== 依存句法理论基础与优势

课件把依存句法理论的基础理解为对“关联”的约束化描述.
对于一个句子, 依存分析不再先构造一层层短语, 而是直接回答每个词依附于哪个中心词.

这种描述通常隐含几个基本约束:

- 中心性: 句子通常围绕谓词或核心动词组织.
- 单支配: 除根节点外, 每个词通常只依存于一个支配词.
- 整体性: 所有词通过依存边连成一个整体结构.
- 有向性: 每条边都有 head 到 dependent 的方向.

因此依存句法的优势在于:

- 直接刻画词与词之间的语法关系, 便于连接到关系抽取、问答等下游任务.
- 结构比完整成分树更扁平, 输出更接近“谁修饰谁、谁支配谁”的使用需求.
- 对词序较自由的语言也比较友好, 因为它重点描述支配关系而不只是连续短语边界.

=== 依存树的约束

一个句子的依存结构通常表示为有向树:

- 每个词是一个节点.
- 每条边表示一个 head 到 dependent 的关系.
- 除根节点外, 每个词通常只有一个支配词.
- 整体结构连通且无环.

这些约束对分析器设计很重要:  
它们把“任意词之间都可能连边”的巨大搜索空间,  
缩小为“每个词选择一个支配词并满足树约束”的结构空间.

若所有依存弧画在词序上方时不交叉, 称为投射依存树(projective dependency tree).  
若存在交叉依存弧, 称为非投射结构(non-projective structure).

依存句法结构可以用三种形式描述:

- 有向图方法: 直接把词作为节点, 依存关系作为有向边.
- 依存树方法: 强调整体满足树约束.
- 依存投射树方法: 在依存树基础上增加无交叉约束.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    [词序], [汤姆], [在], [讲话], [。],
    [head], [讲话], [讲话], [ROOT], [讲话],
    [关系], [SBV], [ADV], [HED], [WP]
  ),
  caption: [依存分析结果也可表示成每个词的 head 与关系标签]
)

=== 常见依存关系标签

课件作业中列出了一些常见标签:

#figure(
  table(
    columns: (auto, auto, auto),
    [标签], [含义], [例子],
    [SBV], [主谓关系], [“我/吃饭”中 `吃 -> 我`],
    [VOB], [动宾关系], [“吃/苹果”中 `吃 -> 苹果`],
    [ATT], [定中关系], [“红色/苹果”中 `苹果 -> 红色`],
    [DE], [结构助词关系], [“猎人/的/狗”中 `狗 -> 的` 或依存体系中的相应助词关系]
  )
)

不同语料库的标签体系不完全相同, 因此实际使用时要以对应标注规范为准.

=== 依存句法分析算法

依存句法分析的目标是为输入句子寻找最合理的依存结构.  
常见方法可以分为四类:

#figure(
  table(
    columns: (auto, auto, auto),
    [方法类型], [基本思想], [典型例子],
    [生成式方法], [学习语言结构的生成过程, 再求最可能结构], [PCFG 等概率生成模型],
    [判别式方法], [直接学习从输入句子到结构或标签的决策函数], [SVM、RNN 等分类或序列模型],
    [转移式方法], [通过一系列 shift/reduce 等动作逐步构建依存树], [基于栈和缓冲区的动作系统],
    [约束式方法], [定义结构约束, 搜索满足约束且得分最高的解], [图搜索、整数规划等]
  )
)

这四类方法的差异主要在于“结构从哪里来”:

- 生成式方法先假设语言结构如何生成, 再寻找最可能生成当前句子的结构.
- 判别式方法不显式建模生成过程, 而是直接学习从输入到结构或标签的映射.
- 转移式方法把构树过程拆成一连串动作, 例如移动词、建立左弧或右弧.
- 约束式方法先定义合法依存树应满足的约束, 再在约束空间中寻找最优解.

#figure(
  align(center,
    commutative-diagram(
      node-padding: (34pt, 22pt),
      padding: 8pt,

      node((0, 0), [输入词序列], "dep-input"),
      node((1, 0), [候选 head / 关系], "dep-cand"),
      node((1, 3), [模型打分或动作决策], "dep-score"),
      node((1, 6), [树约束检查], "dep-constraint"),
      node((2, 3), [依存树], "dep-tree"),

      arr("dep-input", "dep-cand", []),
      arr("dep-cand", "dep-score", []),
      arr("dep-score", "dep-constraint", []),
      arr("dep-constraint", "dep-tree", []),
    )
  ),
  caption: [依存分析可以看作在候选关系中搜索合法且得分高的树]
)

依存句法分析的输出更适合表达词级关系,  
因此在信息抽取、关系抽取、问答和语义角色分析中经常作为上游特征.

== 课后作业要点

=== 三类句法分析概念对比

句法结构分析、浅层句法分析和依存句法分析的区别可以概括为:

- 句法结构分析: 输出完整句法树, 关注短语层级结构.
- 浅层句法分析: 输出局部语块, 关注非递归短语块.
- 依存句法分析: 输出词间依存关系, 关注 head-dependent 结构.

=== 术语说明

#figure(
  table(
    columns: (auto, auto),
    [术语], [含义],
    [S], [sentence, 句子],
    [VP], [verb phrase, 动词短语],
    [NP], [noun phrase, 名词短语],
    [PP], [prepositional phrase, 介词短语],
    [SBV], [subject-verb, 主谓关系],
    [VOB], [verb-object, 动宾关系],
    [ATT], [attribute, 定中修饰关系],
    [DE], [结构助词“的”等相关依存关系]
  )
)

=== PCFG 的特点与优势

PCFG 的特点:

- 在 CFG 规则上增加概率参数.
- 每个非终结符的候选展开概率归一化.
- 一棵树的概率由其使用规则的概率乘积给出.
- 规则和参数可以从树库中统计学习.

采用 PCFG 进行句法分析的优势:

- 能从训练数据自动获得规则和偏好.
- 能在多棵候选树中选择概率最大的树.
- 可以与 CYK、Viterbi 等动态规划算法结合, 提高搜索效率.
- 比纯人工 CFG 更容易适应真实语料中的结构分布.
