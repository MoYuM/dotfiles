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

# 整理 brewfile
chezmoi cd
brew bundle dump

# 清理其他 brew 包
brew bundle cleanup
# 使用 --force 确定清理
brew bundle cleanup --force
```
