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
运行状态（跑动图标 / 等待输入 / 完成 ✓）。`chezmoi apply` 会自动做完以下事：

- 落地 `~/.config/tmux/tmux.conf`、`~/.config/claude-tmux-status/{hook.sh,ticker.sh}`
- 通过 `.chezmoiscripts/run_onchange_after_install-claude-tmux-status-hooks.sh.tmpl` 把对应的
  5 个 hook（`UserPromptSubmit`/`PreToolUse`/`Notification`/`Stop`/`SessionEnd`）**增量合并**进
  `~/.claude/settings.json`（用 jq，只新增缺失的 hook，不覆盖该文件里其他字段或已有的 hook）

新机器上唯一还需要手动做的：

```bash
# 装 tpm（插件管理器本身不归 chezmoi 管，是手动 clone 的）
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# 进 tmux 后按 prefix + I 装 tmux.conf 里声明的插件（如 tmux-which-key）
```

以及确认终端开启了真彩色（truecolor）支持，否则 Tokyo Night 配色会显示不对。
