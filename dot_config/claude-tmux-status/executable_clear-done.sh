#!/usr/bin/env bash
# 由 tmux hook（session-window-changed / client-session-changed）在用户切换 window
# 时调用，$1 = 切入的 window id（run-shell 里由 format 展开）。
# 若该 window 处于 done 状态（✓ 常驻提醒），说明用户已经看到了 → 清除。

WIN="${1:-}"
[ -n "$WIN" ] || exit 0

STATE="$(tmux show-options -w -t "$WIN" -v "@claude_state" 2>/dev/null || true)"
[ "$STATE" = "done" ] || exit 0

tmux set-option -w -t "$WIN" -u "@claude_state" 2>/dev/null || true
tmux set-option -w -t "$WIN" -u "@claude_state_ts" 2>/dev/null || true
tmux set-option -w -t "$WIN" -u "@claude_icon" 2>/dev/null || true

exit 0
