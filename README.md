# Moyum's dotfiles

使用 [chezmoi](https://www.chezmoi.io/) 管理

## 使用

```bash
# 安装 chezomi
brew install chezmoi

# 下载 dotfiles
chezmoi init https://github.com/MoYuM/dotfiles.git

# 应用 dotfiles
chezmoi apply

# 更新 dotfiles
chezmoi update
chezmoi apply
```

## 常用命令

```base
# 更新 fish config
source ~/.config/fish/config.fish

# 根据 brewfile 安装包
chezmoi cd
brew bundle install

# 整理 brewfile
chezmoi cd
brew bundle dump

# 清理其他 brew 包
brew bundle cleanup
# 使用 --force 确定清理
brew bundle cleanup --force
```

## tmux tab 显示 Claude Code 状态

`dot_config/tmux/tmux.conf` + `dot_config/claude-tmux-status/` 实现了 tmux tab 上显示 Claude Code
运行状态（跑动图标 / 等待输入 / 完成 ✓）。`chezmoi apply` 会自动落地配置和脚本，并通过
`.chezmoiscripts/run_onchange_after_install-claude-tmux-status-hooks.sh.tmpl` 把对应的 5 个 hook
增量合并进 `~/.claude/settings.json`（不覆盖其他字段或已有 hook）。

## 依赖

- `jq`
- `tmux`
- `tpm`
