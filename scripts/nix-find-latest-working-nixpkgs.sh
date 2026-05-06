#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Walk backward from the currently locked nixpkgs revision and stop at the first
revision that builds successfully.

This is a newest-first rollback helper:
  current locked rev -> parent -> parent -> ...

It keeps concise terminal output, writes a full log per revision, and maintains
state in .nix-rollback/state.json so progress can be inspected without copying
the entire build output.

Usage:
  scripts/nix-find-latest-working-nixpkgs.sh [options] [-- build command ...]

Options:
  --bad <rev>            Start from this revision. Defaults to current lockfile rev.
  --input <name>         Flake input to override (default: nixpkgs)
  --owner <owner>        GitHub owner for the input (default: NixOS)
  --repo <repo>          GitHub repo for the input (default: nixpkgs)
  --host <host>          Host passed to nh os build -H (default: current hostname)
  --build-cmd <cmd>      Shell command to run for each candidate.
  --quiet                Hide build output in terminal; keep it in the per-revision log.
  --heartbeat <seconds>  Progress heartbeat interval (default: 30)
  --max-steps <n>        Stop after testing N revisions.
  --state-dir <path>     Directory for state and logs (default: .nix-rollback)
  --keep-broken-lock     Do not restore the original flake.lock if no working rev is found.
  -h, --help             Show this help.

Examples:
  scripts/nix-find-latest-working-nixpkgs.sh

  scripts/nix-find-latest-working-nixpkgs.sh \
    --bad 549bd84d6279f9852cae6225e372cc67fb91a4c1

  scripts/nix-find-latest-working-nixpkgs.sh \
    --build-cmd 'nh os build -H predabook'

  scripts/nix-find-latest-working-nixpkgs.sh \
    --heartbeat 15 \
    --max-steps 20

  scripts/nix-find-latest-working-nixpkgs.sh \
    --quiet
EOF
}

log() {
  printf '[nix-find-latest-working] %s\n' "$*"
}

die() {
  printf '[nix-find-latest-working] ERROR: %s\n' "$*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

format_duration() {
  local total=${1:-0}
  printf '%02d:%02d:%02d' $((total / 3600)) $(((total % 3600) / 60)) $((total % 60))
}

json_escape() {
  jq -Rn --arg v "$1" '$v'
}

write_state() {
  local status=$1
  local rev=${2:-}
  local log_file=${3:-}
  local started_at=${4:-}
  local tested_count=${5:-0}
  local message=${6:-}

  jq -n \
    --arg status "$status" \
    --arg input "$input_name" \
    --arg owner "$github_owner" \
    --arg repo "$github_repo" \
    --arg rev "$rev" \
    --arg bad_rev "$bad_rev" \
    --arg log_file "$log_file" \
    --arg started_at "$started_at" \
    --arg build_cmd "$build_cmd" \
    --arg message "$message" \
    --arg state_dir "$state_dir" \
    --argjson heartbeat "$heartbeat_seconds" \
    --argjson tested_count "$tested_count" \
    --arg updated_at "$(date -Is)" \
    '{
      status: $status,
      input: $input,
      source: { owner: $owner, repo: $repo },
      bad_rev: $bad_rev,
      current_rev: $rev,
      current_log: $log_file,
      started_at: $started_at,
      updated_at: $updated_at,
      heartbeat_seconds: $heartbeat,
      tested_count: $tested_count,
      build_cmd: $build_cmd,
      state_dir: $state_dir,
      message: $message
    }' > "$state_file"
}

current_commit_json() {
  local rev=$1
  curl -fsSL \
    -H 'Accept: application/vnd.github+json' \
    "https://api.github.com/repos/${github_owner}/${github_repo}/commits/${rev}"
}

parent_rev() {
  local rev=$1
  current_commit_json "$rev" | jq -r '.parents[0].sha // empty'
}

show_log_tail() {
  local log_file=$1
  if [[ -f "$log_file" ]]; then
    printf '%s\n' '----- log tail -----'
    tail -n 20 "$log_file" || true
    printf '%s\n' '--------------------'
  fi
}

run_build() {
  local rev=$1
  local log_file=$2
  local started_epoch=$3
  local tested_count=$4

  : > "$log_file"

  log "testing revision $rev"
  log "log: $log_file"

  write_state "running" "$rev" "$log_file" "$(date -Is)" "$tested_count" "build in progress"

  (
    set +e
    set -o pipefail
    if (( quiet_mode == 1 )); then
      bash -lc "$build_cmd" >> "$log_file" 2>&1
      printf '%s' $? > "${log_file}.exit"
    else
      bash -lc "$build_cmd" 2>&1 | tee -a "$log_file"
      printf '%s' "${PIPESTATUS[0]}" > "${log_file}.exit"
    fi
  ) &
  local build_pid=$!

  while kill -0 "$build_pid" >/dev/null 2>&1; do
    sleep "$heartbeat_seconds"
    if kill -0 "$build_pid" >/dev/null 2>&1; then
      local elapsed=$(( $(date +%s) - started_epoch ))
      log "still building $rev ($(format_duration "$elapsed"))"
      write_state "running" "$rev" "$log_file" "$(date -Is -d "@${started_epoch}")" "$tested_count" "build running for $(format_duration "$elapsed")"
    fi
  done

  wait "$build_pid" || true
  local exit_code
  exit_code=$(cat "${log_file}.exit")
  rm -f "${log_file}.exit"

  if [[ "$exit_code" == "0" ]]; then
    log "PASS $rev"
    write_state "passed" "$rev" "$log_file" "$(date -Is -d "@${started_epoch}")" "$tested_count" "found working revision"
    return 0
  fi

  log "FAIL $rev"
  write_state "failed" "$rev" "$log_file" "$(date -Is -d "@${started_epoch}")" "$tested_count" "build failed with exit code $exit_code"
  show_log_tail "$log_file"
  return 1
}

bad_rev=""
input_name="nixpkgs"
github_owner="NixOS"
github_repo="nixpkgs"
host="$(hostname -s 2>/dev/null || hostname 2>/dev/null || true)"
build_cmd=""
keep_broken_lock=0
heartbeat_seconds=30
max_steps=0
state_dir=".nix-rollback"
quiet_mode=0

while (($# > 0)); do
  case "$1" in
    --bad)
      bad_rev=${2-}
      shift 2
      ;;
    --input)
      input_name=${2-}
      shift 2
      ;;
    --owner)
      github_owner=${2-}
      shift 2
      ;;
    --repo)
      github_repo=${2-}
      shift 2
      ;;
    --host)
      host=${2-}
      shift 2
      ;;
    --build-cmd)
      build_cmd=${2-}
      shift 2
      ;;
    --heartbeat)
      heartbeat_seconds=${2-}
      shift 2
      ;;
    --max-steps)
      max_steps=${2-}
      shift 2
      ;;
    --state-dir)
      state_dir=${2-}
      shift 2
      ;;
    --quiet)
      quiet_mode=1
      shift
      ;;
    --keep-broken-lock)
      keep_broken_lock=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      build_cmd="$*"
      break
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

require_cmd jq
require_cmd nix
require_cmd git
require_cmd curl

[[ "$heartbeat_seconds" =~ ^[0-9]+$ ]] || die "--heartbeat must be an integer"
[[ "$max_steps" =~ ^[0-9]+$ ]] || die "--max-steps must be an integer"

if [[ -z "$build_cmd" ]]; then
  require_cmd nh
  [[ -n "$host" ]] || die "could not determine current hostname; pass --host explicitly"
  build_cmd="nh os build -H ${host}"
fi

repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root"

[[ -f flake.lock ]] || die "flake.lock not found at repo root"

mkdir -p "$state_dir/logs"
state_file="$state_dir/state.json"

backup_lock=$(mktemp "${TMPDIR:-/tmp}/flake.lock.backup.XXXXXX")
cp flake.lock "$backup_lock"
original_lock_rev=$(jq -r --arg input "$input_name" '.nodes[.nodes.root.inputs[$input]].locked.rev // empty' flake.lock)

restore_original_lock() {
  if [[ -f "$backup_lock" ]]; then
    cp "$backup_lock" flake.lock
  fi
}

cleanup() {
  rm -f "$backup_lock"
}

on_exit() {
  local exit_code=$?
  if (( exit_code != 0 )) && (( keep_broken_lock == 0 )); then
    log "restoring original flake.lock"
    restore_original_lock
    write_state "restored" "$original_lock_rev" "" "$(date -Is)" 0 "restored original flake.lock after failure"
  fi
  cleanup
  exit "$exit_code"
}

trap on_exit EXIT
trap 'die "interrupted"' INT TERM

current_input_node=$(jq -r --arg input "$input_name" '.nodes.root.inputs[$input] // empty' flake.lock)
[[ -n "$current_input_node" ]] || die "input '$input_name' not found in flake.lock root inputs"

if [[ -z "$bad_rev" ]]; then
  bad_rev=$(jq -r --arg node "$current_input_node" '.nodes[$node].locked.rev // empty' flake.lock)
fi

[[ -n "$bad_rev" ]] || die "could not determine current bad revision for input '$input_name'"

log "starting from revision $bad_rev"
log "build command: $build_cmd"
log "state file: $state_file"

tested_count=0
current_rev="$bad_rev"

while [[ -n "$current_rev" ]]; do
  tested_count=$((tested_count + 1))

  if (( max_steps > 0 && tested_count > max_steps )); then
    die "reached --max-steps limit ($max_steps) without finding a working revision"
  fi

  log_file="$state_dir/logs/${tested_count}-$(printf '%.12s' "$current_rev").log"
  started_epoch=$(date +%s)

  nix flake lock --override-input "$input_name" "github:${github_owner}/${github_repo}/${current_rev}" >/dev/null

  if run_build "$current_rev" "$log_file" "$started_epoch" "$tested_count"; then
    log "kept working revision in flake.lock: $current_rev"
    exit 0
  fi

  next_rev=$(parent_rev "$current_rev")
  [[ -n "$next_rev" ]] || die "revision $current_rev has no parent; no working revision found"
  current_rev="$next_rev"
done

die "no working revision found"
