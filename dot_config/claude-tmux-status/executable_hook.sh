#!/usr/bin/env bash
# 被 Claude Code hooks 调用，把状态写进当前 tmux window 的 user option，
# 并确保动画 ticker（ticker.sh）在运行。
# 注意：PreToolUse 每次工具调用都触发（热路径），tmux 调用已用 \; 链合并为单次 fork。
set -euo pipefail

EVENT="${1:-}"

[ -n "${TMUX:-}" ] || exit 0
[ -n "${TMUX_PANE:-}" ] || exit 0

case "$EVENT" in
  UserPromptSubmit|PreToolUse) STATE="running" ;;
  Notification)                 STATE="needs-input" ;;
  Stop)                          STATE="done" ;;
  SessionEnd)                    STATE="" ;;
  *)                              exit 0 ;;
esac

# $TMUX_PANE 直接作 -w 目标（tmux 解析到其所在 window），不依赖 client 上下文
if [ -z "$STATE" ]; then
  # SessionEnd：清状态。ticker 下个 tick 发现 state 为空会自行清屏退出；
  # 这里再兜底清一次 icon，覆盖 ticker 已死的情况。
  tmux set-option -w -t "$TMUX_PANE" -u "@claude_state" \; \
       set-option -w -t "$TMUX_PANE" -u "@claude_icon" 2>/dev/null || true
else
  # 单次 fork：写状态 + 读回 ticker PID
  PID="$(tmux set-option -w -t "$TMUX_PANE" "@claude_state" "$STATE" \; \
              show-options -w -t "$TMUX_PANE" -v "@claude_ticker_pid" 2>/dev/null || true)"

  # ticker 不在则拉起。只有这条罕见路径才需要解析 window id / 脚本目录；
  # 传 window id 而非 pane id 给 ticker——pane 可能先于 window 消失。
  # 重复拉起由 ticker 自己的 PID 仲裁解决。
  if [ -z "$PID" ] || ! kill -0 "$PID" 2>/dev/null; then
    WIN="$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null || true)"
    [ -n "$WIN" ] || exit 0
    DIR="${BASH_SOURCE[0]%/*}"   # hooks 以绝对路径调用本脚本
    nohup "$DIR/ticker.sh" "$WIN" >/dev/null 2>&1 &
  fi
fi

exit 0
