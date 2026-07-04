#!/usr/bin/env bash
# 被 Claude Code hooks 调用，把状态写进当前 tmux window 的 user option，
# 并确保动画 ticker（ticker.sh）在运行。
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

# 用 $TMUX_PANE 精确定位所在 window，不依赖 client 上下文
WIN="$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}' 2>/dev/null || true)"
[ -n "$WIN" ] || exit 0

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$STATE" ]; then
  # SessionEnd：清状态。ticker 下个 tick 发现 state 为空会自行清屏退出；
  # 这里再兜底清一次 icon，覆盖 ticker 已死的情况。
  tmux set-option -w -t "$WIN" -u "@claude_state" 2>/dev/null || true
  tmux set-option -w -t "$WIN" -u "@claude_state_ts" 2>/dev/null || true
  tmux set-option -w -t "$WIN" -u "@claude_icon" 2>/dev/null || true
else
  tmux set-option -w -t "$WIN" "@claude_state" "$STATE" 2>/dev/null || true
  tmux set-option -w -t "$WIN" "@claude_state_ts" "$(date +%s)" 2>/dev/null || true

  # 确保 ticker 在跑（不在则拉起；重复拉起由 ticker 自己的 PID 仲裁解决）
  PID="$(tmux show-options -w -t "$WIN" -v "@claude_ticker_pid" 2>/dev/null || true)"
  if [ -z "$PID" ] || ! kill -0 "$PID" 2>/dev/null; then
    nohup "$DIR/ticker.sh" "$WIN" >/dev/null 2>&1 &
  fi
fi

exit 0
