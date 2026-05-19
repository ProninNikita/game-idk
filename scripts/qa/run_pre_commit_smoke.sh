#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
SMOKE_TIMEOUT_SECONDS="${HEARTHLINE_SMOKE_TIMEOUT_SECONDS:-${SMOKE_TIMEOUT_SECONDS:-120}}"

if [[ "${SKIP_HEARTHLINE_SMOKE:-}" == "1" ]]; then
  echo "[smoke] Skipping Project Hearthline smoke test because SKIP_HEARTHLINE_SMOKE=1"
  exit 0
fi

if ! [[ "${SMOKE_TIMEOUT_SECONDS}" =~ ^[0-9]+$ ]] || (( SMOKE_TIMEOUT_SECONDS <= 0 )); then
  echo "[smoke] Invalid timeout '${SMOKE_TIMEOUT_SECONDS}'. Use a positive number of seconds." >&2
  exit 2
fi

_run_with_timeout() {
  local seconds="$1"
  shift

  local timeout_bin=""
  if command -v timeout >/dev/null 2>&1; then
    timeout_bin="$(command -v timeout)"
  elif command -v gtimeout >/dev/null 2>&1; then
    timeout_bin="$(command -v gtimeout)"
  fi

  if [[ -n "${timeout_bin}" ]]; then
    "${timeout_bin}" "${seconds}s" "$@"
    return $?
  fi

  "$@" &
  local command_pid=$!
  local started_at=${SECONDS}

  while kill -0 "${command_pid}" >/dev/null 2>&1; do
    if (( SECONDS - started_at >= seconds )); then
      echo "[smoke] Godot timed out after ${seconds}s; terminating PID ${command_pid}" >&2
      kill -TERM "${command_pid}" >/dev/null 2>&1 || true

      local attempt
      for attempt in 1 2 3 4 5; do
        if ! kill -0 "${command_pid}" >/dev/null 2>&1; then
          break
        fi
        sleep 1
      done

      if kill -0 "${command_pid}" >/dev/null 2>&1; then
        echo "[smoke] Godot did not stop after SIGTERM; killing PID ${command_pid}" >&2
        kill -KILL "${command_pid}" >/dev/null 2>&1 || true
      fi

      wait "${command_pid}" >/dev/null 2>&1 || true
      return 124
    fi

    sleep 1
  done

  wait "${command_pid}"
}

_can_check_untracked_files() {
  command -v git >/dev/null 2>&1 && git -C "${PROJECT_ROOT}" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

_snapshot_untracked_files() {
  git -C "${PROJECT_ROOT}" ls-files --others --exclude-standard | LC_ALL=C sort
}

_snapshot_worktree_diff() {
  {
    echo "## unstaged"
    git -C "${PROJECT_ROOT}" diff --no-ext-diff --binary
    echo "## staged"
    git -C "${PROJECT_ROOT}" diff --cached --no-ext-diff --binary
  }
}

_print_lines() {
  local content="${1:-}"
  if [[ -n "${content}" ]]; then
    printf '%s\n' "${content}"
  fi
}

GODOT_BIN="${GODOT_BIN:-}"
if [[ -z "${GODOT_BIN}" ]]; then
  for candidate in \
    "/Users/likit/Desktop/Godot.app/Contents/MacOS/Godot" \
    "/Applications/Godot.app/Contents/MacOS/Godot" \
    "godot"; do
    if command -v "${candidate}" >/dev/null 2>&1; then
      GODOT_BIN="${candidate}"
      break
    fi
  done
fi

if [[ -z "${GODOT_BIN}" ]]; then
  echo "[smoke] Godot binary not found. Set GODOT_BIN=/path/to/Godot." >&2
  exit 127
fi

echo "[smoke] Running Project Hearthline pre-commit smoke test with ${GODOT_BIN} (timeout ${SMOKE_TIMEOUT_SECONDS}s)"

check_untracked_files=0
untracked_before=""
worktree_diff_before=""
if _can_check_untracked_files; then
  check_untracked_files=1
  untracked_before="$(_snapshot_untracked_files)"
  worktree_diff_before="$(_snapshot_worktree_diff)"
else
  echo "[smoke] Git unavailable; skipping generated untracked file check"
fi

set +e
_run_with_timeout \
  "${SMOKE_TIMEOUT_SECONDS}" \
  "${GODOT_BIN}" \
  --headless \
  --path "${PROJECT_ROOT}" \
  --script "res://scripts/qa/pre_commit_smoke_test.gd"
status=$?
set -e

if [[ "${status}" -eq 124 ]]; then
  echo "[smoke] Godot smoke test timed out after ${SMOKE_TIMEOUT_SECONDS}s" >&2
fi

if [[ "${check_untracked_files}" == "1" ]]; then
  untracked_after="$(_snapshot_untracked_files)"
  new_untracked="$(comm -13 <(_print_lines "${untracked_before}") <(_print_lines "${untracked_after}"))"
  if [[ -n "${new_untracked}" ]]; then
    echo "[smoke] Smoke test created untracked file(s):" >&2
    printf '%s\n' "${new_untracked}" | sed 's/^/[smoke]   /' >&2
    if [[ "${status}" -eq 0 ]]; then
      status=1
    fi
  fi

  worktree_diff_after="$(_snapshot_worktree_diff)"
  if [[ "${worktree_diff_after}" != "${worktree_diff_before}" ]]; then
    echo "[smoke] Smoke test changed tracked working tree or staged diff state." >&2
    echo "[smoke] Revert generated changes or add them intentionally before committing." >&2
    if [[ "${status}" -eq 0 ]]; then
      status=1
    fi
  fi
fi

exit "${status}"
