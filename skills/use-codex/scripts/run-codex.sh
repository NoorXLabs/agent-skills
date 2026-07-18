#!/usr/bin/env bash

set -u

worker_cwd=
artifact_dir=
codex_model=
codex_effort=
access_profile=
session_id=
prepare_only=false
artifact_safe=false
child_pid=
cancel_exit=0

usage() {
  cat <<'EOF'
Usage:
  run-codex.sh --prepare --cwd DIR
  run-codex.sh --cwd DIR --artifacts DIR --model MODEL --effort EFFORT
               --access PROFILE [--resume SESSION_ID]

Profiles: read-only, workspace-write-no-shell-network,
          workspace-write-network, full
The complete worker prompt must already exist at ARTIFACTS/prompt.md.
EOF
}

record_setup_failure() {
  local message=$1
  if [[ "$artifact_safe" != true && "$worker_cwd" == /* && -d "$worker_cwd" &&
        "$artifact_dir" == /* && -d "$artifact_dir" ]]; then
    local possible_cwd possible_repo possible_artifacts
    possible_cwd=$(canonical_dir "$worker_cwd") || possible_cwd=
    possible_repo=$(repository_root "$possible_cwd") || possible_repo=
    possible_artifacts=$(canonical_dir "$artifact_dir") || possible_artifacts=
    if [[ -n "$possible_repo" && -n "$possible_artifacts" ]] &&
       ! path_within "$possible_artifacts" "$possible_repo"; then
      artifact_dir=$possible_artifacts
      artifact_safe=true
    fi
  fi
  [[ "$artifact_safe" == true ]] || return 0
  [[ -e "$artifact_dir/events.jsonl" ]] ||
    printf '%s\n' '{"type":"runner.error"}' >"$artifact_dir/events.jsonl"
  [[ -e "$artifact_dir/progress.log" ]] ||
    printf 'run-codex: %s\n' "$message" >"$artifact_dir/progress.log"
  [[ -e "$artifact_dir/final.md" ]] ||
    printf 'Runner setup failed: %s\n' "$message" >"$artifact_dir/final.md"
  [[ -e "$artifact_dir/exit-code" ]] ||
    printf '%s\n' 2 >"$artifact_dir/exit-code"
  printf '%s\n' "$artifact_dir"
}

fail() {
  local message=$*
  printf 'run-codex: %s\n' "$message" >&2
  record_setup_failure "$message"
  exit 2
}

canonical_dir() {
  (cd -P -- "$1" 2>/dev/null && pwd -P)
}

repository_root() {
  local start=$1 root
  root=$(git -C "$start" rev-parse --show-toplevel 2>/dev/null) || root=$start
  canonical_dir "$root"
}

path_within() {
  local child=$1 parent=$2
  if [[ "$parent" == / ]]; then
    [[ "$child" == /* ]]
  else
    [[ "$child" == "$parent" || "$child" == "$parent/"* ]]
  fi
}

prepare_artifacts() {
  local cwd_real repo_real prepared_real
  cwd_real=$(canonical_dir "$worker_cwd") || fail 'cannot resolve cwd'
  repo_real=$(repository_root "$cwd_real") || fail 'cannot resolve repository root'
  artifact_dir=$(mktemp -d) ||
    fail 'cannot create artifact directory'
  prepared_real=$(canonical_dir "$artifact_dir") || fail 'cannot resolve artifact directory'
  if path_within "$prepared_real" "$repo_real"; then
    rmdir -- "$prepared_real" 2>/dev/null || true
    artifact_dir=
    fail 'system temporary directory resolves inside the repository; set TMPDIR to an external directory'
  fi
  printf '%s\n' "$prepared_real"
}

process_group_alive() {
  [[ -n "$child_pid" ]] && kill -0 -- "-$child_pid" 2>/dev/null
}

terminate_process_group() {
  local attempt
  process_group_alive || return 0
  kill -s TERM -- "-$child_pid" 2>/dev/null || true
  for (( attempt=0; attempt<20; attempt++ )); do
    process_group_alive || return 0
    sleep 0.05
  done
  kill -s KILL -- "-$child_pid" 2>/dev/null || true
  for (( attempt=0; attempt<40; attempt++ )); do
    process_group_alive || return 0
    sleep 0.05
  done
  return 1
}

forward_signal() {
  local signal=$1 status=$2
  (( cancel_exit == 0 )) && cancel_exit=$status
  [[ -n "$child_pid" ]] || return 0
  kill -s "$signal" -- "-$child_pid" 2>/dev/null ||
    kill -s "$signal" "$child_pid" 2>/dev/null || true
}

while (( $# > 0 )); do
  case "$1" in
    --prepare)
      prepare_only=true
      shift
      ;;
    --resume)
      (( $# >= 2 )) || fail 'missing value for --resume'
      [[ -n "$2" && "$2" != -* ]] || fail 'resume requires an explicit session ID'
      session_id=$2
      shift 2
      ;;
    --cwd|--artifacts|--model|--effort|--access)
      (( $# >= 2 )) || fail "missing value for $1"
      case "$1" in
        --cwd) worker_cwd=$2 ;;
        --artifacts) artifact_dir=$2 ;;
        --model) codex_model=$2 ;;
        --effort) codex_effort=$2 ;;
        --access) access_profile=$2 ;;
      esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *) fail "unknown argument: $1" ;;
  esac
done

[[ -n "$worker_cwd" ]] || fail 'missing --cwd'
[[ "$worker_cwd" == /* && -d "$worker_cwd" ]] ||
  fail 'cwd must be an existing absolute directory'
if [[ "$prepare_only" == true ]]; then
  prepare_artifacts
  exit 0
fi

[[ -n "$artifact_dir" ]] || fail 'missing --artifacts'
[[ -n "$codex_model" ]] || fail 'missing --model'
[[ -n "$codex_effort" ]] || fail 'missing --effort'
[[ -n "$access_profile" ]] || fail 'missing --access'
[[ "$artifact_dir" == /* && -d "$artifact_dir" ]] ||
  fail 'artifacts must be an existing absolute directory'

cwd_real=$(canonical_dir "$worker_cwd") || fail 'cannot resolve cwd'
repo_real=$(repository_root "$cwd_real") || fail 'cannot resolve repository root'
artifact_real=$(canonical_dir "$artifact_dir") || fail 'cannot resolve artifacts'
path_within "$artifact_real" "$repo_real" &&
  fail 'artifacts must be outside the repository root'
worker_cwd=$cwd_real
artifact_dir=$artifact_real
artifact_safe=true

[[ -f "$artifact_dir/prompt.md" ]] || fail 'missing artifacts/prompt.md'
command -v codex >/dev/null 2>&1 || fail 'codex is not on PATH'
for output in events.jsonl progress.log final.md exit-code; do
  [[ ! -e "$artifact_dir/$output" ]] ||
    fail "refusing to overwrite artifacts/$output"
done

case "$access_profile" in
  read-only)
    new_access=(--sandbox read-only)
    resume_access=(--config sandbox_mode=read-only)
    ;;
  workspace-write-no-shell-network)
    new_access=(--sandbox workspace-write --config sandbox_workspace_write.network_access=false)
    resume_access=(--config sandbox_mode=workspace-write --config sandbox_workspace_write.network_access=false)
    ;;
  workspace-write-network)
    new_access=(--sandbox workspace-write --config sandbox_workspace_write.network_access=true)
    resume_access=(--config sandbox_mode=workspace-write --config sandbox_workspace_write.network_access=true)
    ;;
  full)
    new_access=(--sandbox danger-full-access)
    resume_access=(--config sandbox_mode=danger-full-access)
    ;;
  *) fail "unknown access profile: $access_profile" ;;
esac

isolation_args=(
  --ignore-user-config
  --disable plugins
  --disable apps
  --disable browser_use
  --disable browser_use_external
  --disable browser_use_full_cdp_access
  --disable computer_use
  --disable in_app_browser
  --disable image_generation
  --disable hooks
  --disable multi_agent
)
common_args=(
  "${isolation_args[@]}"
  --ignore-rules
  --strict-config
  --model "$codex_model"
  --config "model_reasoning_effort=$codex_effort"
  --json
  --output-last-message "$artifact_dir/final.md"
)

trap 'forward_signal HUP 129' HUP
trap 'forward_signal INT 130' INT
trap 'forward_signal TERM 143' TERM
set -m
set +e
if [[ -n "$session_id" ]]; then
  codex -C "$worker_cwd" exec resume "${resume_access[@]}" \
    "${common_args[@]}" "$session_id" - \
    <"$artifact_dir/prompt.md" >"$artifact_dir/events.jsonl" \
    2>"$artifact_dir/progress.log" &
else
  codex -C "$worker_cwd" exec "${new_access[@]}" \
    "${common_args[@]}" - \
    <"$artifact_dir/prompt.md" >"$artifact_dir/events.jsonl" \
    2>"$artifact_dir/progress.log" &
fi
child_pid=$!
wait "$child_pid"
codex_exit=$?

if (( cancel_exit != 0 )); then
  if ! terminate_process_group; then
    codex_exit=125
    printf '%s\n' 'run-codex: cancellation could not confirm process-group termination' \
      >>"$artifact_dir/progress.log"
  else
    wait "$child_pid" 2>/dev/null || true
    codex_exit=$cancel_exit
    printf 'run-codex: cancelled with status %s; process-group termination confirmed\n' \
      "$codex_exit" >>"$artifact_dir/progress.log"
  fi
elif process_group_alive; then
  if terminate_process_group; then
    printf '%s\n' 'run-codex: Codex exited with a live descendant; process group terminated' \
      >>"$artifact_dir/progress.log"
  else
    printf '%s\n' 'run-codex: Codex exited with a live descendant; termination unconfirmed' \
      >>"$artifact_dir/progress.log"
  fi
  (( codex_exit == 0 )) && codex_exit=125
fi
trap - HUP INT TERM
set +m

if ! printf '%s\n' "$codex_exit" >"$artifact_dir/exit-code"; then
  printf 'run-codex: failed to persist exit status in %s\n' "$artifact_dir" >&2
  (( codex_exit == 0 )) && codex_exit=125
fi
printf '%s\n' "$artifact_dir"
exit "$codex_exit"
