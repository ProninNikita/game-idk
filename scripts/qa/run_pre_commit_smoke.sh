#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [[ "${SKIP_HEARTHLINE_SMOKE:-}" == "1" ]]; then
  echo "[smoke] Skipping Project Hearthline smoke test because SKIP_HEARTHLINE_SMOKE=1"
  exit 0
fi

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

echo "[smoke] Running Project Hearthline pre-commit smoke test with ${GODOT_BIN}"
"${GODOT_BIN}" --headless --path "${PROJECT_ROOT}" --script "res://scripts/qa/pre_commit_smoke_test.gd"
