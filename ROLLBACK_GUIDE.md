# 回滚指南

## 如何回滚到合并前的状态

如果合并后的配置出现问题，可以使用以下步骤回滚：

### 快速回滚（推荐）

```bash
# 切换到备份分支
git checkout backup/20260106

# 重新安装旧配置
cd ~/.dotfiles
make uninstall
make install

# 重启 shell
exec zsh
```

### 保留改进，仅回滚特定配置

如果你想保留大部分改进，但需要回滚某些特定配置：

```bash
# 回滚 ZSH 配置
git checkout backup/20260106 -- stow-packs/zsh/

# 回滚 Starship 配置
git checkout backup/20260106 -- stow-packs/system/.config/starship.toml

# 重新安装
make uninstall
make install
```

### 查看备份分支

```bash
# 查看备份分支的提交历史
git log backup/20260106 --oneline

# 查看备份分支的内容
git checkout backup/20260106
ls -la
```

### 合并后的改进清单

如果你想了解合并带来的改进，可以查看：

```bash
# 查看合并提交
git log main --grep="Merge remote improvements" --oneline

# 查看合并的变更
git show 6538d2f --stat
```

## 备份说明

- **备份分支**: `backup/20260106`
- **备份内容**: 包含合并前的所有本地更改
- **备份时间**: 2026-01-06
- **备份提交**: `ea67f6b`

## 常见问题

### Q: 我如何知道新配置是否正常工作？

A: 运行以下命令验证：

```bash
# 检查符号链接
ls -la ~/.zshrc ~/.zshenv ~/.config/starship.toml

# 测试 ZSH 配置
zsh -c 'source ~/.zshrc && echo "ZSH OK"'

# 检查模块加载
ls ~/.config/zsh/*.zsh
```

### Q: 我发现某个工具不工作了，怎么办？

A: 检查对应的配置模块：

```bash
# 如果 FZF 不工作，检查 fzf.zsh
cat ~/.config/zsh/fzf.zsh

# 如果开发工具不工作，检查 dev.zsh
cat ~/.config/zsh/dev.zsh

# 如果本地工具（LM Studio等）不工作，检查 local.zsh
cat ~/.config/zsh/local.zsh
```

### Q: 如何重新应用合并？

A: 如果回滚后想重新合并：

```bash
# 切换回 main
git checkout main

# 如果已经回滚了提交，先重置
git reset --hard origin/main

# 重新合并（如果需要）
git merge origin/main
```

## 联系支持

如果遇到无法解决的问题：

1. 检查日志文件：`~/.dotfiles-backup-*/`
2. 查看文档：`docs/` 目录
3. 查看远程仓库：https://github.com/nehcuh/dotfiles
