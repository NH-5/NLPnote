# NLPnote

自然语言处理课程笔记，提供 Typst 和 LaTeX 两个版本。

## 内容

- `01-Entropy.typ`: 熵与最大熵原理
- `02-FormalLanguageAutomaton.typ`: 形式语言与自动机
- `03-HiddenMarkovModel.typ`: 隐马尔可夫模型
- `04-ConditionalRandomField.typ`: 条件随机场
- `05-LanguageModel.typ`: 语言模型
- `06-Corpus.typ`: 语料库与语言知识库
- `07-LMwithNeuralNetwork.typ`: 神经网络语言模型
- `08-InformationRetrieval.typ`: 信息检索
- `09-LexicalAnalysis.typ`: 词法分析
- `10-SyntaxAnalysis.typ`: 句法分析
- `11-SemanticAnalysis.typ`: 语义分析
- `12-PretrainedWordVectors.typ`: 预训练词向量
- `13-Exercises.typ`: 课后题与答案
- `note.typ`: 总入口文件
- `template/`: Typst 模板资源
- `latex/`: LaTeX 版本源码

## 构建

Typst 版本需要本地安装 [Typst](https://typst.app/)。

```bash
typst compile typst/note.typ NatureLanguageProcess-typst.pdf
```

LaTeX 版本需要本地安装 TeX Live 或 MacTeX，并使用 XeLaTeX 构建。

```bash
cd latex
latexmk -xelatex note.tex
```

生成的 PDF 和 LaTeX 辅助文件已在 `.gitignore` 中忽略。

## Release 发布

仓库已配置 GitHub Actions 自动发布。

- Pull Request 和 `main` 分支推送会自动编译两个版本作为 CI 检查
- 推送标签 `v*` 时会自动编译 Typst 和 LaTeX 两个 PDF
- 工作流会创建同名 GitHub Release
- `NatureLanguageProcess-typst.pdf` 和 `NatureLanguageProcess-latex.pdf` 会作为 Release 附件上传

示例：

```bash
git tag v0.1.0
git push origin v0.1.0
```
