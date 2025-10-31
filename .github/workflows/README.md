# GitHub Actions 自动化工作流说明

## 完全自动化的 PR 流程

本仓库配置了完全自动化的 Pull Request 创建和合并流程，无需手动在 GitHub 网页上操作。

### 工作流程

当你推送代码到 `claude/**` 分支时，以下流程会自动执行：

1. **自动创建 PR** (`auto-create-pr.yml`)
   - 检测到 push 到 `claude/**` 分支
   - 自动创建 Pull Request 到默认分支
   - PR 标题使用第一个提交信息
   - PR 描述包含所有提交的变更列表

2. **自动批准和合并** (`auto-merge.yml`)
   - PR 创建后自动触发
   - 自动批准 PR
   - 尝试立即合并或启用自动合并
   - 如果有必需的检查，会在检查通过后自动合并

### 使用方法

只需要执行以下操作：

```bash
# 1. 在 claude/ 分支上开发
git checkout -b claude/your-feature-name

# 2. 提交你的更改
git add .
git commit -m "your changes"

# 3. 推送到远程仓库
git push -u origin claude/your-feature-name
```

**就这样！** 其余的（创建 PR、批准、合并）都会自动完成。

### 配置要求

确保你的 GitHub 仓库有以下配置：

1. **Personal Access Token (PAT)**
   - 在仓库设置中添加 Secret: `PAT_TOKEN`
   - Token 需要 `repo` 和 `workflow` 权限
   - 用于自动创建和合并 PR

2. **分支保护规则（可选）**
   - 如果你的默认分支有保护规则，确保启用了 "Allow auto-merge"
   - 如果需要检查通过才能合并，配置相应的 required checks

### 工作流文件

- `auto-create-pr.yml` - 自动创建 Pull Request
- `auto-merge.yml` - 自动批准和合并 PR

### 注意事项

- 只处理 `claude/**` 分支的 PR
- 只处理仓库所有者创建的 PR（`alexsu006`）
- 如果 PR 已存在，不会重复创建
- 合并方式为 squash merge，所有提交会被合并为一个提交
