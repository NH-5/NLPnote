# NLPnote

自然语言处理课程笔记，使用 Typst 编写。

## 内容

- `01-Entropy.typ`: 熵与最大熵原理
- `02-FormalLanguageAutomaton.typ`: 形式语言与自动机
- `03-HiddenMarkovModel.typ`: 隐马尔可夫模型
- `04-ConditionalRandomField.typ`: 条件随机场
- `05-LanguageModel.typ`: 语言模型
- `note.typ`: 总入口文件
- `template/`: Typst 模板资源

## 构建

需要本地安装 [Typst](https://typst.app/)。

```bash
typst compile note.typ
```

生成的 `note.pdf` 已在 `.gitignore` 中忽略。

## Release 发布

仓库已配置 GitHub Actions 自动发布。

- 推送标签 `v*` 时会自动编译 `note.pdf`
- 工作流会创建同名 GitHub Release
- `note.pdf` 会作为 Release 附件上传

示例：

```bash
git tag v0.1.0
git push origin v0.1.0
```
