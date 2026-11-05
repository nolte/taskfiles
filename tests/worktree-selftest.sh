#!/usr/bin/env bash
# Regression guard for `worktree:add` (nolte/taskfiles#50, #53).
#
# Exercises `worktree:add` against a throwaway origin/clone pair for every
# branch prefix the module allows, plus negative cases that must be rejected
# (missing/unknown prefix, unsafe slug, existing destination, missing
# arguments). The module is driven both directly (`task -t <module> add`) and
# through a consumer-style Taskfile that includes it (`task worktree:add`).
#
# The prefix list is the value Task itself resolves for
# WORKTREE_ALLOWED_PREFIXES (read from a `--dry --verbose` render of the
# task), so the guard can never drift from the source of truth — whether the
# module declares it as a plain literal or as a `| default "…"` template.
#
# Usage: tests/worktree-selftest.sh [path/to/taskfile-include-worktree.yaml]
#   Defaults to src/taskfile-include-worktree.yaml in this repository. Pass
#   another file to check a different revision, e.g.:
#     git show origin/develop:src/taskfile-include-worktree.yaml > /tmp/old.yaml
#     tests/worktree-selftest.sh /tmp/old.yaml
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
module="${1:-$script_dir/../src/taskfile-include-worktree.yaml}"

if [ ! -f "$module" ]; then
  echo "✖ Module under test not found: $module" >&2
  exit 2
fi
module="$(cd "$(dirname "$module")" && pwd)/$(basename "$module")"

command -v task >/dev/null || { echo "✖ go-task CLI not on PATH" >&2; exit 2; }
command -v git >/dev/null || { echo "✖ git not on PATH" >&2; exit 2; }

work="$(mktemp -d "${TMPDIR:-/tmp}/worktree-selftest.XXXXXX")"
cleanup() { rm -rf "$work"; }
trap cleanup EXIT

# Hermetic git: ignore the caller's global/system config (signing, hooks,
# templates) and supply a fixed identity. Module overrides that may arrive
# through the environment are dropped so only the module's own values count.
export GIT_CONFIG_GLOBAL=/dev/null
export GIT_CONFIG_NOSYSTEM=1
export GIT_AUTHOR_NAME=selftest GIT_AUTHOR_EMAIL=selftest@example.invalid
export GIT_COMMITTER_NAME=selftest GIT_COMMITTER_EMAIL=selftest@example.invalid
export GIT_TERMINAL_PROMPT=0
unset NOLTE_WORKTREE_ROOT WORKTREE_ALLOWED_PREFIXES WORKTREE_ROOT_DEFAULT \
  WORKTREE_BASE_REF WORKTREE_FETCH_REMOTE WORKTREE_FETCH_BRANCH

# Source of truth: the value Task resolves for WORKTREE_ALLOWED_PREFIXES. A
# dry, verbose run renders the templated script without executing it; the
# rendered `allowed_prefixes="…"` assignment carries the resolved value.
mkdir -p "$work/probe"
allowed="$(cd "$work/probe" && task -t "$module" add --dry --verbose -- probe/probe 2>&1 </dev/null |
  sed -n 's/^\(task: \[[^]]*\] \)\{0,1\}[[:space:]]*allowed_prefixes="\([^"]*\)"[[:space:]]*$/\2/p' |
  head -n 1)" || true
if [ -z "${allowed// /}" ]; then
  echo "✖ Could not resolve WORKTREE_ALLOWED_PREFIXES from $module" >&2
  exit 2
fi
read -r -a prefixes <<<"$allowed"

# Bare origin with a `develop` branch carrying one commit, plus a clone of it.
# `git init` + `symbolic-ref` instead of `git init -b` keeps git < 2.28 working.
git init -q "$work/seed"
git -C "$work/seed" symbolic-ref HEAD refs/heads/develop
git -C "$work/seed" commit -q --allow-empty -m "selftest seed"
git init -q --bare "$work/origin.git"
git -C "$work/seed" push -q "$work/origin.git" develop
git -C "$work/origin.git" symbolic-ref HEAD refs/heads/develop
git clone -q "$work/origin.git" "$work/clone"

# Consumer-style wrapper: how downstream projects wire the module in.
cat >"$work/clone/Taskfile.yml" <<EOF
version: '3'

includes:
  worktree: $module
EOF

pass=0
fail=0
report() { # <status> <case> [detail]
  if [ "$1" = PASS ]; then
    pass=$((pass + 1))
    echo "PASS  $2"
  else
    fail=$((fail + 1))
    echo "FAIL  $2${3:+ — $3}"
  fi
}

# run_add <root-id> <direct|consumer> [args...]: runs `worktree:add` in the
# clone with the worktree root $work/roots/<root-id> (reused across calls with
# the same id). `task -x` passes the script's own exit status through instead
# of go-task's generic 201. Sets rc, out, err, root.
runs=0
run_add() {
  local id="$1" mode="$2"
  shift 2
  root="$work/roots/$id"
  runs=$((runs + 1))
  local log="$work/logs/$runs"
  mkdir -p "$root" "$work/logs"
  set +e
  if [ "$mode" = consumer ]; then
    (cd "$work/clone" && NOLTE_WORKTREE_ROOT="$root" \
      task -x worktree:add -- "$@" >"$log.out" 2>"$log.err" </dev/null)
  else
    (cd "$work/clone" && NOLTE_WORKTREE_ROOT="$root" \
      task -x -t "$module" add -- "$@" >"$log.out" 2>"$log.err" </dev/null)
  fi
  rc=$?
  set -e
  out="$(cat "$log.out")"
  err="$(cat "$log.err")"
}

# check_created <case> <slug>: asserts the last run_add created a worktree
# with its plan stub under "$root/origin/<slug>".
check_created() {
  local dest="$root/origin/$2"
  if [ "$rc" -ne 0 ]; then
    report FAIL "$1" "exit $rc${err:+, stderr: $err}"
  elif [[ "$out" != *"→ Worktree root"* ]]; then
    report FAIL "$1" "output lacks '→ Worktree root'"
  elif [ ! -d "$dest" ]; then
    report FAIL "$1" "worktree dir missing: $dest"
  elif [ ! -f "$dest/.resume/$2/plan.md" ]; then
    report FAIL "$1" "plan stub missing: $dest/.resume/$2/plan.md"
  else
    report PASS "$1"
  fi
}

# check_rejected <case> <expected-stderr-fragment> [expected-exit]: asserts
# the last run_add failed with the given stderr message (and exit status).
check_rejected() {
  if [ "$rc" -eq 0 ]; then
    report FAIL "$1" "expected non-zero exit, got 0"
  elif [ -n "${3:-}" ] && [ "$rc" -ne "$3" ]; then
    report FAIL "$1" "expected exit $3, got $rc${err:+, stderr: $err}"
  elif [[ "$err" != *"$2"* ]]; then
    report FAIL "$1" "exit $rc but stderr lacks '$2'${err:+: $err}"
  else
    report PASS "$1"
  fi
}

# --- positive: every allowed prefix, directly and via the consumer wrapper --
i=0
for p in "${prefixes[@]}"; do
  i=$((i + 1))
  run_add "pos-$i" direct "$p/selftest"
  check_created "positive: $p/selftest" selftest
done

# Branches live in the one shared clone, so each further case needs its own name.
run_add pos-consumer consumer "${prefixes[0]}/selftest-consumer"
check_created "positive (consumer): ${prefixes[0]}/selftest-consumer" selftest-consumer

run_add pos-slug direct "${prefixes[0]}/selftest-slug" custom-slug
check_created "positive: ${prefixes[0]}/selftest-slug custom-slug" custom-slug

# --- negative: branch prefix ------------------------------------------------
i=0
for branch in "${prefixes[0]}" /selftest; do
  i=$((i + 1))
  run_add "neg-noprefix-$i" direct "$branch"
  check_rejected "negative: $branch (no prefix)" "has no prefix"
done

run_add neg-badprefix direct nope/selftest
check_rejected "negative: nope/selftest (unknown prefix)" "lacks an allowed prefix"

run_add neg-consumer consumer nope/selftest
check_rejected "negative (consumer): nope/selftest (unknown prefix)" "lacks an allowed prefix"

# --- negative: unsafe slug --------------------------------------------------
i=0
for slug in a/b ..x; do
  i=$((i + 1))
  run_add "neg-slug-$i" direct "${prefixes[0]}/selftest" "$slug"
  check_rejected "negative: ${prefixes[0]}/selftest $slug (unsafe slug)" "must be a single kebab-case path segment"
done

# --- negative: destination already exists -----------------------------------
# Same branch and slug twice in one root: the destination check runs before
# `git worktree add`, so the second call must fail on the existing directory.
run_add neg-exists direct "${prefixes[0]}/selftest-exists"
if [ "$rc" -ne 0 ]; then
  report FAIL "negative: destination exists (setup)" "first add failed: exit $rc${err:+, stderr: $err}"
else
  run_add neg-exists direct "${prefixes[0]}/selftest-exists"
  check_rejected "negative: destination exists" "Destination already exists"
fi

# --- negative: missing arguments -> usage, exit 2 ---------------------------
run_add neg-usage direct
check_rejected "negative: no arguments (usage)" "Usage: task worktree:add" 2

echo
echo "worktree selftest ($module): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
