#!/usr/bin/env bash
# 动画 ticker：由 hook.sh 拉起，高频把当前帧写进 window option @claude_icon，
# 并用 refresh-client -S 强制重画状态栏（绕开 tmux status-interval 最低 1 秒的限制）。
# tab 格式里引用 #{@claude_icon} 变量渲染，不走 #() 缓存。
#
# 生命周期：state 为 running/needs-input 时持续动画；done 显示 10 秒后自动清理退出；
# state 被清（SessionEnd）时清屏退出。每个 window 只允许一个实例：启动时把自己的
# PID 写进 @claude_ticker_pid，每个 tick 校验，被新实例顶替则自行退出。

WIN="${1:-}"
[ -n "$WIN" ] || exit 0

tmux set-option -w -t "$WIN" "@claude_ticker_pid" "$$" 2>/dev/null || exit 0

# 帧字符必须满足：East Asian Width = N/Na 且非 emoji 候选，否则部分终端按 2 格宽
# 渲染导致 tab 抖动。踩过的坑：✳(U+2733) 是 emoji 候选；·(U+00B7) ✽(U+273D) 是 EAW=A。
FRAMES=(∙ ✻ ✼ ✶ ✲ ✢)
TICK=0
MAX_TICKS=96000   # 约 4 小时（按 150ms/tick），防泄漏兜底
DONE_TTL=10

refresh_all() {
  while read -r C; do
    tmux refresh-client -S -t "$C" 2>/dev/null
  done < <(tmux list-clients -F '#{client_name}' 2>/dev/null)
}

draw() {
  tmux set-option -w -t "$WIN" "@claude_icon" "$1" 2>/dev/null || exit 0
  refresh_all
}

cleanup_exit() {
  tmux set-option -w -t "$WIN" -u "@claude_icon" 2>/dev/null
  tmux set-option -w -t "$WIN" -u "@claude_ticker_pid" 2>/dev/null
  refresh_all
  exit 0
}

while :; do
  STATE=""; TS=0; OWNER=""
  while read -r KEY VAL; do
    case "$KEY" in
      "@claude_state")      STATE="$VAL" ;;
      "@claude_state_ts")   TS="$VAL" ;;
      "@claude_ticker_pid") OWNER="$VAL" ;;
    esac
  done < <(tmux show-options -w -t "$WIN" 2>/dev/null)

  # window 已消失 / tmux 已退出 / 被新 ticker 顶替 → 退出
  [ "$OWNER" = "$$" ] || exit 0

  # 配色跟随 Tokyo Night（tab 底色为深色，图标用亮色前景）。
  # 图标始终位于 tab 内容末尾，故不需要恢复前景色；禁用 #[default]（会破坏 tab 底色）。
  case "$STATE" in
    running)
      draw " #[fg=#ff9e64]${FRAMES[$(( TICK % ${#FRAMES[@]} ))]}"
      SLEEP=0.15
      ;;
    needs-input)
      # 显/隐闪烁（当前 tab 整体加粗，bold 交替会失效；空格保持宽度稳定）
      if (( TICK % 2 == 0 )); then
        draw " #[fg=#f7768e]?"
      else
        draw "  "
      fi
      SLEEP=0.5
      ;;
    done)
      if (( $(date +%s) - TS < DONE_TTL )); then
        draw " #[fg=#9ece6a]✓"
        SLEEP=0.5
      else
        tmux set-option -w -t "$WIN" -u "@claude_state" 2>/dev/null
        tmux set-option -w -t "$WIN" -u "@claude_state_ts" 2>/dev/null
        cleanup_exit
      fi
      ;;
    *)
      cleanup_exit
      ;;
  esac

  TICK=$(( TICK + 1 ))
  (( TICK >= MAX_TICKS )) && cleanup_exit
  sleep "$SLEEP"
done
